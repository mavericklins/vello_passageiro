import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const db = admin.firestore();

// Util genérica de push (substitua por FCM/gateway real)
async function sendPush(toUserId: string, payload: any) {
  console.log('PUSH →', toUserId, payload?.titulo);
}

// 1) Nova corrida → notificar motoristas próximos
export const onCorridaCreate = functions.firestore
  .document('corridas/{corridaId}')
  .onCreate(async (snap, ctx) => {
    const corrida: any = snap.data();
    const geoPrefix: string = (corrida.origem?.geohashPrefix || '').slice(0, 5);

    const candidatos = await db.collection('motoristas')
      .where('status', '==', 'online')
      .where('localizacaoAtual.geohash', '>=', geoPrefix)
      .where('localizacaoAtual.geohash', '<', geoPrefix + '\uf8ff')
      .limit(50)
      .get();

    const batch = db.batch();
    const agora = admin.firestore.Timestamp.now();

    candidatos.forEach(doc => {
      const notifRef = db.collection('notificacoes_motorista').doc();
      batch.set(notifRef, {
        motoristaId: doc.id,
        corridaId: snap.id,
        tipo: 'nova_corrida',
        titulo: 'Nova corrida disponível',
        mensagem: `${corrida.origem?.endereco} → ${corrida.destino?.endereco}`,
        dados: {
          corridaId: snap.id,
          origem: corrida.origem?.endereco,
          destino: corrida.destino?.endereco,
          valor: corrida.valor,
          distancia: corrida.distanciaEstimada,
          tempoEstimado: corrida.tempoEstimado
        },
        lida: false,
        criadaEm: agora,
        expiresAt: admin.firestore.Timestamp.fromMillis(agora.toMillis() + 60_000 * 3) // 3 min
      });
      sendPush(doc.id, { titulo: 'Nova corrida', body: 'Toque para ver' });
    });

    await batch.commit();
  });

// 2) Corrida atualizada → notificar passageiro/motorista
export const onCorridaUpdate = functions.firestore
  .document('corridas/{corridaId}')
  .onUpdate(async (change, ctx) => {
    const before: any = change.before.data();
    const after: any = change.after.data();
    const agora = admin.firestore.Timestamp.now();

    if (before.status !== after.status) {
      const eventos: Record<string, string> = {
        'aceita': 'motorista_aceito',
        'motorista_a_caminho': 'motorista_a_caminho',
        'motorista_chegou': 'motorista_chegou',
        'em_andamento': 'corrida_iniciada',
        'concluida': 'corrida_concluida',
        'cancelada_passageiro': 'corrida_cancelada',
        'cancelada_motorista': 'corrida_cancelada'
      };
      const tipo = eventos[after.status] || 'sistema';

      const batch = db.batch();

      // passageiro
      const nPass = db.collection('notificacoes_passageiro').doc();
      batch.set(nPass, {
        passageiroId: after.passageiroId,
        corridaId: change.after.id,
        tipo,
        titulo: 'Atualização da sua corrida',
        mensagem: `Status: ${after.status}`,
        lida: false,
        visualizada: false,
        criadaEm: agora,
        expiresAt: admin.firestore.Timestamp.fromMillis(agora.toMillis() + 86_400_000) // 24h
      });

      // motorista
      if (after.motoristaId) {
        const nMot = db.collection('notificacoes_motorista').doc();
        batch.set(nMot, {
          motoristaId: after.motoristaId,
          corridaId: change.after.id,
          tipo: 'sistema',
          titulo: 'Atualização de corrida',
          mensagem: `Status: ${after.status}`,
          lida: false,
          criadaEm: agora,
          expiresAt: admin.firestore.Timestamp.fromMillis(agora.toMillis() + 86_400_000)
        });
      }

      await batch.commit();
    }
  });

// 3) Chat: ao inserir mensagem, atualiza "ultimaMensagem" em /corridas/{id}
export const onChatMensagemCreate = functions.firestore
  .document('corridas/{corridaId}/mensagens/{msgId}')
  .onCreate(async (snap, ctx) => {
    const m: any = snap.data();
    await db.doc(`corridas/${ctx.params.corridaId}`).set({
      ultimaMensagem: {
        conteudo: (m.conteudo?.slice(0, 160) || ''),
        remetente: m.remetenteId,
        timestamp: m.timestamp || admin.firestore.Timestamp.now()
      },
      atualizadoEm: admin.firestore.Timestamp.now()
    }, { merge: true });
  });

// 4) Link público de compartilhamento (gera token simples)
export const createShareLink = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login requerido');
  const corridaId = data.corridaId as string;
  const token = Math.random().toString(36).slice(2);
  const expires = Date.now() + 6 * 60 * 60 * 1000; // 6h
  await db.collection('compartilhamento_viagem').doc(token).set({
    corridaId,
    passageiroId: context.auth.uid,
    linkCompartilhamento: `https://app.vello.com/share/${token}`,
    ativo: true,
    configuracoes: { compartilharLocalizacao: true, compartilharMotorista: true, compartilharRota: true, notificarInicio: true, notificarFim: true },
    criadoEm: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromMillis(expires)
  });
  return { token };
});

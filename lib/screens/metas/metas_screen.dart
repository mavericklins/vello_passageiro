import 'package:flutter/material.dart';
import '../../models/passenger_goals.dart';
import '../../services/passenger_goals_service.dart';
import '../../widgets/goal_progress_widget.dart';
import '../../models/passenger_meta_inteligente.dart';
import '../../theme/vello_tokens.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  _MetasScreenState createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PassengerGoalsService _goalsService = PassengerGoalsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _goalsService.carregarMetas();
    _goalsService.gerarMetasPersonalizadas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.darkSurface,
      appBar: AppBar(
        title: Text('Metas e Conquistas', style: TextStyle(color: VelloTokens.white)),
        backgroundColor: VelloTokens.brandBlue,
        iconTheme: IconThemeData(color: VelloTokens.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _goalsService.carregarMetas();
              _goalsService.atualizarProgressoMetas();
            },
            tooltip: 'Atualizar metas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Hoje', icon: Icon(Icons.today)),
            Tab(text: 'Semana', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Mês', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Conquistas', icon: Icon(Icons.emoji_events)),
          ],
          labelColor: VelloTokens.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: VelloTokens.brandBlueDark,
        ),
      ),
      body: StreamBuilder<PassengerGoals?>(
        stream: _goalsService.getPassengerGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brandBlueDark,
              ),
            );
          }

          final goals = snapshot.data;
          if (goals == null) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDailyGoals(goals),
              _buildWeeklyGoals(goals),
              _buildMonthlyGoals(goals),
              _buildAchievements(goals),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Suas metas serão criadas\napós a primeira corrida',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _goalsService.gerarMetasPersonalizadas(),
            style: ElevatedButton.styleFrom(
              backgroundColor: VelloTokens.brandBlueDark,
              foregroundColor: VelloTokens.white,
            ),
            child: Text('Gerar Metas'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoals(PassengerGoals goals) {
    return StreamBuilder<List<PassengerMetaInteligente>>(
      stream: _goalsService.getMetasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final metas = snapshot.data ?? [];
        final metasDiarias = metas.where((meta) {
          final diff = meta.dataFim.difference(meta.dataInicio);
          return diff.inDays <= 1;
        }).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelCard(goals),
              SizedBox(height: 16),
              Text(
                'Metas de Hoje',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              if (metasDiarias.isEmpty)
                _buildNoGoalsMessage('Nenhuma meta diária ativa')
              else
                ...metasDiarias.map((meta) => GoalProgressWidget(meta: meta)),
              SizedBox(height: 16),
              _buildDailyStats(goals),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyGoals(PassengerGoals goals) {
    return StreamBuilder<List<PassengerMetaInteligente>>(
      stream: _goalsService.getMetasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final metas = snapshot.data ?? [];
        final metasSemanais = metas.where((meta) {
          final diff = meta.dataFim.difference(meta.dataInicio);
          return diff.inDays > 1 && diff.inDays <= 7;
        }).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metas da Semana',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              if (metasSemanais.isEmpty)
                _buildNoGoalsMessage('Nenhuma meta semanal ativa')
              else
                ...metasSemanais.map((meta) => GoalProgressWidget(meta: meta)),
              SizedBox(height: 16),
              _buildWeeklyRanking(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyGoals(PassengerGoals goals) {
    return StreamBuilder<List<PassengerMetaInteligente>>(
      stream: _goalsService.getMetasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final metas = snapshot.data ?? [];
        final metasMensais = metas.where((meta) {
          final diff = meta.dataFim.difference(meta.dataInicio);
          return diff.inDays > 7;
        }).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metas do Mês',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              if (metasMensais.isEmpty)
                _buildNoGoalsMessage('Nenhuma meta mensal ativa')
              else
                ...metasMensais.map((meta) => GoalProgressWidget(meta: meta)),
              SizedBox(height: 16),
              _buildMonthlyStats(goals),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievements(PassengerGoals goals) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suas Conquistas',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${goals.conquistas.length} conquistas',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (goals.conquistas.isEmpty)
            _buildEmptyAchievements()
          else
            ...goals.conquistas.map((achievement) =>
                _buildAchievementCard(achievement)),
          SizedBox(height: 16),
          _buildAvailableAchievements(goals),
        ],
      ),
    );
  }

  Widget _buildNoGoalsMessage(String message) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _goalsService.gerarMetasPersonalizadas(),
            style: ElevatedButton.styleFrom(
              backgroundColor: VelloTokens.brandBlueDark,
              foregroundColor: VelloTokens.white,
            ),
            child: Text('Gerar Metas'),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(PassengerGoals goals) {
    final nextLevelPoints = _getNextLevelPoints(goals.nivel);
    final progressToNext = goals.pontuacao / nextLevelPoints;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [VelloTokens.brandBlueDark, VelloTokens.brandBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível ${goals.nivel}',
                    style: TextStyle(
                      color: VelloTokens.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${goals.pontuacao} pontos',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${goals.nivel}',
                  style: TextStyle(
                    color: VelloTokens.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressToNext.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          SizedBox(height: 8),
          Text(
            'Próximo nível: ${nextLevelPoints - goals.pontuacao} pontos',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.brandBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              achievement.icone,
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.titulo,
                  style: TextStyle(
                    color: VelloTokens.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  achievement.descricao,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '${achievement.pontos} pontos • ${_formatDate(achievement.conquistadoEm)}',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAchievements() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma conquista ainda',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Use o app e complete corridas para desbloquear conquistas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableAchievements(PassengerGoals goals) {
    final conquistas = [
      {'id': 'primeira_corrida', 'titulo': 'Primeira Viagem', 'descricao': 'Complete sua primeira corrida', 'icone': '🚗', 'pontos': 50},
      {'id': 'avaliador', 'titulo': 'Avaliador', 'descricao': 'Avalie 10 corridas', 'icone': '⭐', 'pontos': 25},
      {'id': 'economizador', 'titulo': 'Economizador', 'descricao': 'Economize R\$ 50 em promoções', 'icone': '💰', 'pontos': 75},
      {'id': 'eco_friendly', 'titulo': 'Eco-Friendly', 'descricao': 'Use 5 corridas compartilhadas', 'icone': '🌱', 'pontos': 100},
      {'id': 'frequente', 'titulo': 'Usuário Frequente', 'descricao': 'Complete 20 corridas', 'icone': '🎯', 'pontos': 150},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas Disponíveis',
          style: TextStyle(
            color: VelloTokens.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...conquistas.map((achievement) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VelloTokens.brandBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(achievement['icone'] as String, style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['titulo'] as String,
                        style: TextStyle(color: VelloTokens.white, fontSize: 14),
                      ),
                      Text(
                        achievement['descricao'] as String,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${achievement['pontos']} pts',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDailyStats(PassengerGoals goals) {
    final stats = goals.estatisticas;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.brandBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas Gerais',
            style: TextStyle(
              color: VelloTokens.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Corridas',
                '${stats['totalRides'] ?? 0}',
                Icons.directions_car,
              ),
              _buildStatItem(
                'Total Gastos',
                'R\$ ${(stats['totalSpent'] ?? 0.0).toStringAsFixed(2)}',
                Icons.attach_money,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Avaliação Média',
                '${(stats['averageRating'] ?? 0.0).toStringAsFixed(1)} ⭐',
                Icons.star,
              ),
              _buildStatItem(
                'Economia Total',
                'R\$ ${(stats['totalSavings'] ?? 0.0).toStringAsFixed(2)}',
                Icons.savings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: VelloTokens.white, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: VelloTokens.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWeeklyRanking() {
    // Simulação de ranking semanal de passageiros
    final ranking = [
      {'nome': 'Ana Silva', 'nivel': 3, 'corridas': 12, 'economia': 45.50, 'posicao': 1},
      {'nome': 'João Santos', 'nivel': 2, 'corridas': 8, 'economia': 32.75, 'posicao': 2},
      {'nome': 'Maria Costa', 'nivel': 4, 'corridas': 15, 'economia': 67.25, 'posicao': 3},
      {'nome': 'Pedro Lima', 'nivel': 2, 'corridas': 6, 'economia': 28.40, 'posicao': 4},
      {'nome': 'Você', 'nivel': 1, 'corridas': 4, 'economia': 15.60, 'posicao': 5},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.brandBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ranking Semanal - Economia',
            style: TextStyle(
              color: VelloTokens.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          ...ranking.map((passenger) => _buildRankingItem(passenger)),
        ],
      ),
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> passenger) {
    final isCurrentUser = passenger['nome'] == 'Você';
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankingColor(passenger['posicao']),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${passenger['posicao']}',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger['nome'],
                  style: TextStyle(
                    color: isCurrentUser ? Colors.blue : VelloTokens.white, 
                    fontSize: 14,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  'Nível ${passenger['nivel']} • ${passenger['corridas']} corridas',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${passenger['economia'].toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(PassengerGoals goals) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.brandBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Mês',
            style: TextStyle(
              color: VelloTokens.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildMonthlyChart(goals),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(PassengerGoals goals) {
    // Simular gráfico mensal
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Gráfico de Uso Mensal',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              '(Em desenvolvimento)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankingColor(int posicao) {
    switch (posicao) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  int _getNextLevelPoints(int nivel) {
    if (nivel == 1) return 100;
    if (nivel == 2) return 300;
    if (nivel == 3) return 600;
    if (nivel == 4) return 1000;
    if (nivel == 5) return 1500;
    return 1500 + ((nivel - 5) * 500);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
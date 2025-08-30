import 'package:flutter/material.dart';

class SobreAppScreen extends StatelessWidget {
  const SobreAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Aplicativo')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vello Mobilidade',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Bem-vindo ao Vello Mobilidade! Nosso aplicativo foi desenvolvido para oferecer a você uma experiência de transporte urbano eficiente, segura e confortável. Conectamos passageiros a motoristas parceiros de forma rápida e intuitiva, garantindo que você chegue ao seu destino com tranquilidade.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Nossa missão é transformar a mobilidade urbana, proporcionando liberdade e flexibilidade para motoristas e passageiros. Acreditamos que a tecnologia pode simplificar o dia a dia e criar novas oportunidades para todos.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Com o Vello Mobilidade, você tem acesso a:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '- Viagens seguras e monitoradas.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '- Motoristas parceiros verificados e qualificados.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '- Preços justos e transparentes.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '- Diversas opções de pagamento.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '- Suporte dedicado ao usuário.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Estamos constantemente trabalhando para melhorar sua experiência e adicionar novas funcionalidades. Sua opinião é muito importante para nós!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Versão do Aplicativo: 1.0.0',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Desenvolvido por: Equipe Vello Mobilidade',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/passenger_gamification_service.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/achievement_card.dart';

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({Key? key}) : super(key: key);

  @override
  _ConquistasScreenState createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PassengerGamificationService _gamificationService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _gamificationService = PassengerGamificationService();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _gamificationService.initialize();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Conquistas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: VelloTokens.white,
          ),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: VelloTokens.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar conquistas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : ChangeNotifierProvider.value(
              value: _gamificationService,
              child: Consumer<PassengerGamificationService>(
                builder: (context, service, child) {
                  return Column(
                    children: [
                      _buildStatsHeader(service),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAchievementsTab(service),
                            _buildRankingTab(service),
                            _buildChallengesTab(service),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              decoration: BoxDecoration(
                color: VelloTokens.white,
                boxShadow: VelloTokens.elevationLow,
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: VelloTokens.brand,
                unselectedLabelColor: VelloTokens.gray400,
                indicatorColor: VelloTokens.brand,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.emoji_events),
                    text: 'Conquistas',
                  ),
                  Tab(
                    icon: Icon(Icons.leaderboard),
                    text: 'Ranking',
                  ),
                  Tab(
                    icon: Icon(Icons.flag),
                    text: 'Desafios',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsHeader(PassengerGamificationService service) {
    final completedCount = service.achievements.where((c) => c['unlocked'] == true).length;
    final totalCount = service.achievements.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.all(VelloTokens.spaceM),
      child: VelloCard.gradient(
        gradient: const LinearGradient(
          colors: [VelloTokens.brand, VelloTokens.brandLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: VelloTokens.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: VelloTokens.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${service.currentLevel}',
                      style: const TextStyle(
                        color: VelloTokens.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'NÍVEL',
                      style: TextStyle(
                        color: VelloTokens.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suas Conquistas',
                      style: TextStyle(
                        color: VelloTokens.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${service.currentXP} XP • ${completedCount}/$totalCount conquistas',
                      style: const TextStyle(
                        color: VelloTokens.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: service.levelProgress,
                        backgroundColor: VelloTokens.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(VelloTokens.white),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Faltam ${service.xpToNextLevel} XP para o próximo nível',
                      style: const TextStyle(
                        color: VelloTokens.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(PassengerGamificationService service) {
    return ListView.builder(
      padding: const EdgeInsets.all(VelloTokens.spaceM),
      itemCount: service.achievements.length,
      itemBuilder: (context, index) {
        final achievement = service.achievements[index];
        return AchievementCard(
          achievement: achievement,
          onTap: () => _showAchievementDetails(achievement),
        );
      },
    );
  }

  Widget _buildRankingTab(PassengerGamificationService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VelloTokens.spaceM),
      child: Column(
        children: [
          // Posição atual
          VelloCard(
            child: Padding(
              padding: const EdgeInsets.all(VelloTokens.spaceL),
              child: Column(
                children: [
                  const Text(
                    'Sua Posição',
                    style: TextStyle(
                      fontSize: 16,
                      color: VelloTokens.gray600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.currentRank > 0 ? '#${service.currentRank}' : '-',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.brand,
                    ),
                  ),
                  Text(
                    'de ${service.totalPassengers} passageiros',
                    style: const TextStyle(
                      color: VelloTokens.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: VelloTokens.spaceL),

          // Top 10
          const Text(
            'Top 10 Passageiros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: VelloTokens.gray700,
            ),
          ),
          const SizedBox(height: VelloTokens.spaceM),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: service.topPassengers.length,
            itemBuilder: (context, index) {
              final passenger = service.topPassengers[index];
              return _buildRankingCard(passenger);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> passenger) {
    final position = passenger['rank'] ?? 0;
    Color? rankColor;
    IconData? rankIcon;

    switch (position) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey[400];
        rankIcon = Icons.workspace_premium;
        break;
      case 3:
        rankColor = Colors.orange[300];
        rankIcon = Icons.military_tech;
        break;
    }

    return VelloCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: rankColor ?? VelloTokens.brand,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: rankIcon != null
                ? Icon(rankIcon, color: VelloTokens.white, size: 20)
                : Text(
                    '$position',
                    style: const TextStyle(
                      color: VelloTokens.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        title: Text(
          passenger['nome'] ?? 'Passageiro',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${passenger['trips'] ?? 0} viagens'),
        trailing: Text(
          '${passenger['xp'] ?? 0} XP',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: VelloTokens.brand,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengesTab(PassengerGamificationService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VelloTokens.spaceM),
      child: Column(
        children: [
          // Desafio diário
          VelloCard.gradient(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(VelloTokens.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.today, color: VelloTokens.white),
                      SizedBox(width: 8),
                      Text(
                        'Desafio Diário',
                        style: TextStyle(
                          color: VelloTokens.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.dailyChallenge['title'] ?? 'Nenhum desafio ativo',
                    style: const TextStyle(
                      color: VelloTokens.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: service.dailyChallenge['progress'] ?? 0.0,
                    backgroundColor: VelloTokens.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(VelloTokens.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${service.dailyChallenge['current'] ?? 0}/${service.dailyChallenge['target'] ?? 1}',
                        style: const TextStyle(color: VelloTokens.white70),
                      ),
                      Text(
                        '+${service.dailyChallenge['reward'] ?? 0} XP',
                        style: const TextStyle(
                          color: VelloTokens.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: VelloTokens.spaceL),

          // Desafios semanais
          const Text(
            'Desafios Semanais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: VelloTokens.gray700,
            ),
          ),
          const SizedBox(height: VelloTokens.spaceM),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: service.weeklyChallenges.length,
            itemBuilder: (context, index) {
              final challenge = service.weeklyChallenges[index];
              return _buildChallengeCard(challenge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return VelloCard(
      margin: const EdgeInsets.only(bottom: VelloTokens.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(VelloTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelloTokens.brand.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: VelloTokens.brand,
                    size: 20,
                  ),
                ),
                const SizedBox(width: VelloTokens.spaceS),
                Expanded(
                  child: Text(
                    challenge['title'] ?? 'Desafio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: VelloTokens.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge['reward'] ?? 0} XP',
                    style: const TextStyle(
                      color: VelloTokens.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: challenge['progress'] ?? 0.0,
              backgroundColor: VelloTokens.gray200,
              valueColor: const AlwaysStoppedAnimation<Color>(VelloTokens.brand),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge['current'] ?? 0}/${challenge['target'] ?? 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: VelloTokens.gray600,
                  ),
                ),
                Text(
                  '${((challenge['progress'] ?? 0.0) * 100).toInt()}% completo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: VelloTokens.gray600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(achievement['icone'] ?? '🏆', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(achievement['titulo'] ?? 'Conquista')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement['descricao'] ?? 'Descrição não disponível'),
            if (achievement['pontos'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: VelloTokens.brand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${achievement['pontos']} XP',
                  style: const TextStyle(
                    color: VelloTokens.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
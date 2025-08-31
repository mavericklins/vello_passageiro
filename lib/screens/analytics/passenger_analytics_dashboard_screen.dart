import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/passenger_analytics_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../theme/vello_tokens.dart';

class PassengerAnalyticsDashboardScreen extends StatefulWidget {
  const PassengerAnalyticsDashboardScreen({super.key});

  @override
  State<PassengerAnalyticsDashboardScreen> createState() => _PassengerAnalyticsDashboardScreenState();
}

class _PassengerAnalyticsDashboardScreenState extends State<PassengerAnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'semana';
  bool _isLoading = true;
  var _analyticsData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate fetching passenger data
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analyticsData = {
        'totalSpending': 'R\$ 456,30',
        'totalSpendingChange': '+8%',
        'totalTrips': '23',
        'totalTripsChange': '+12%',
        'averageRating': '4.9',
        'averageRatingChange': '+0.1',
        'spendingChartData': [
          FlSpot(0, 25), FlSpot(1, 38), FlSpot(2, 45), FlSpot(3, 32),
          FlSpot(4, 67), FlSpot(5, 78), FlSpot(6, 52),
        ],
        'hourlyTripsData': List.generate(24, (index) {
          final values = [0, 0, 0, 0, 0, 1, 3, 5, 6, 4, 3, 2,
                          1, 2, 3, 4, 6, 8, 7, 5, 4, 2, 1, 0];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                color: VelloTokens.brand,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        'performance': [
          {'title': 'Tempo médio por viagem', 'value': '22 min', 'icon': Icons.access_time, 'color': Colors.blue},
          {'title': 'Economia vs Uber/99', 'value': 'R\$ 87,20', 'icon': Icons.savings, 'color': VelloTokens.success},
          {'title': 'Distância média', 'value': '8.3 km', 'icon': Icons.route, 'color': Colors.green},
          {'title': 'Horário preferido', 'value': '17:00 - 18:00', 'icon': Icons.schedule, 'color': VelloTokens.brand},
        ],
        'scenarios': [
          {'title': 'E se eu usasse +1 viagem por dia?', 'daily': '+R\$ 18,50/dia', 'monthly': '+R\$ 555/mês', 'icon': Icons.add_circle, 'color': Colors.blue},
          {'title': 'E se eu sempre usasse nos horários de desconto?', 'daily': '-15% por viagem', 'monthly': '-R\$ 68/mês', 'icon': Icons.discount, 'color': Colors.green},
          {'title': 'E se eu compartilhasse mais viagens?', 'daily': '-25% custo médio', 'monthly': '-R\$ 114/mês', 'icon': Icons.group, 'color': VelloTokens.brandOrange},
          {'title': 'E se eu usasse apenas nos fins de semana?', 'daily': '+Conforto nos finais', 'monthly': 'R\$ 180/mês', 'icon': Icons.weekend, 'color': Colors.purple},
        ],
      };
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Meus Dados de Viagem',
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
            onPressed: _loadAnalytics,
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildInsightsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: VelloCard(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCard(
              'Total Gastos',
              _analyticsData?['totalSpending'] ?? 'R\$ ---',
              Icons.attach_money,
              VelloTokens.red500,
              _analyticsData?['totalSpendingChange'] ?? '+0%',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloCard(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCard(
              'Viagens',
              _analyticsData?['totalTrips'] ?? '0',
              Icons.directions_car,
              VelloTokens.brandOrange,
              _analyticsData?['totalTripsChange'] ?? '+0%',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloCard(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCard(
              'Avaliação',
              _analyticsData?['averageRating'] ?? '0.0',
              Icons.star,
              Colors.amber,
              _analyticsData?['averageRatingChange'] ?? '+0.0',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const Spacer(),
            Text(
              change,
              style: TextStyle(
                color: change.startsWith('+') ? VelloTokens.green500 : VelloTokens.red500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: VelloTokens.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: VelloTokens.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return VelloCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPeriodButton('Semana', 'semana'),
          _buildPeriodButton('Mês', 'mes'),
          _buildPeriodButton('Ano', 'ano'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? VelloTokens.brand : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? VelloTokens.white : VelloTokens.gray600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos ao Longo do Tempo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text('R\$ ${value.toInt()}', style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()], style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _analyticsData?['spendingChartData'] ?? [],
                    isCurved: true,
                    color: VelloTokens.brand,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: VelloTokens.brand.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyTripsChart() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Viagens por Horário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}', style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}h', style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _analyticsData?['hourlyTripsData'] ?? [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: 20),
        _buildSpendingChart(),
        const SizedBox(height: 20),
        _buildHourlyTripsChart(),
        const SizedBox(height: 20),
        _buildPerformanceAnalysis(),
        const SizedBox(height: 20),
        _buildScenarioSimulator(),
      ],
    );
  }

  Widget _buildPerformanceAnalysis() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análise de Padrões',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_analyticsData?['performance'] as List<Map<String, dynamic>>? ?? []).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildPerformanceItem(
              item['title'],
              item['value'],
              item['icon'],
              item['color'],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: VelloTokens.gray700),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: VelloTokens.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioSimulator() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulador de Economia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_analyticsData?['scenarios'] as List<Map<String, dynamic>>? ?? []).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildScenarioOption(
              item['title'],
              item['daily'],
              item['monthly'],
              item['icon'],
              item['color'],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildScenarioOption(String title, String dailyImpact, String monthlyImpact, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dailyImpact,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      monthlyImpact,
                      style: TextStyle(
                        fontSize: 11,
                        color: VelloTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
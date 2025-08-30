import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ride_request_screen.dart';
import '../screens/buscando_motoristas_screen.dart';
import '../screens/home/confirmacao_corrida.dart';
import '../screens/historico/historico_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/pagamentos/pagamentos_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/favoritos/favoritos_screen.dart';
import '../screens/suporte/suporte_screen.dart';
import '../screens/promocoes/promocoes_screen.dart';
import '../screens/conquistas/conquistas_screen.dart';
import '../screens/metas/metas_screen.dart';
import '../screens/analytics/passenger_analytics_dashboard_screen.dart';
import '../screens/wallet/wallet_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String rideRequest = '/ride_request';
  static const String buscandoMotoristas = '/buscando_motoristas';
  static const String confirmacaoCorrida = '/confirmacao_corrida';
  static const String historico = '/historico';
  static const String perfil = '/perfil';
  static const String pagamentos = '/pagamentos';
  static const String wallet = '/wallet';
  static const String configuracoes = '/configuracoes';
  static const String favoritos = '/favoritos';
  static const String suporte = '/suporte';
  static const String promocoes = '/promocoes';
  static const String conquistas = '/conquistas';
  static const String metas = '/metas';
  static const String stats = '/stats';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      mainNavigation: (context) => const MainNavigationScreen(),
      rideRequest: (context) => RideRequestScreen(),
      historico: (context) => const HistoricoScreen(),
      perfil: (context) => const PerfilScreen(),
      pagamentos: (context) => const PagamentosScreen(),
      wallet: (context) => const WalletScreen(),
      configuracoes: (context) => const ConfiguracoesScreen(),
      favoritos: (context) => const FavoritosScreen(),
      suporte: (context) => const SuporteScreen(),
      promocoes: (context) => const PromocoesScreen(),
      conquistas: (context) => const ConquistasScreen(),
      metas: (context) => const MetasScreen(),
      stats: (context) => const PassengerAnalyticsDashboardScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => RegisterScreen());
      case AppRoutes.mainNavigation:
        return MaterialPageRoute(builder: (context) => const MainNavigationScreen());
      case AppRoutes.rideRequest:
        return MaterialPageRoute(builder: (context) => RideRequestScreen());
      case AppRoutes.confirmacaoCorrida:
        final args = settings.arguments as Map<String, dynamic>?;
        final enderecoInicial = args?['enderecoInicial'] ?? 'Endereço não informado';
        return MaterialPageRoute(
          builder: (context) => ConfirmacaoCorridaScreen(enderecoInicial: enderecoInicial),
        );
      case AppRoutes.buscandoMotoristas:
        final args = settings.arguments as Map<String, dynamic>?;
        final corridaId = args?['corridaId']?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
        return MaterialPageRoute(
          builder: (context) => BuscandoMotoristasScreen(
            corridaId: corridaId,
            localizacaoPassageiro: args?['localizacaoPassageiro'],
          ),
        );
      case AppRoutes.home:
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['userName'] ?? 'Usuário';
        return MaterialPageRoute(
          builder: (context) => HomeScreen(userName: userName),
        );
      case AppRoutes.historico:
        return MaterialPageRoute(builder: (context) => const HistoricoScreen());
      case AppRoutes.perfil:
        return MaterialPageRoute(builder: (context) => const PerfilScreen());
      case AppRoutes.pagamentos:
        return MaterialPageRoute(builder: (context) => const PagamentosScreen());
      case AppRoutes.wallet:
        return MaterialPageRoute(builder: (context) => const WalletScreen());
      case AppRoutes.configuracoes:
        return MaterialPageRoute(builder: (context) => const ConfiguracoesScreen());
      case AppRoutes.favoritos:
        return MaterialPageRoute(builder: (context) => const FavoritosScreen());
      case AppRoutes.suporte:
        return MaterialPageRoute(builder: (context) => const SuporteScreen());
      case AppRoutes.promocoes:
        return MaterialPageRoute(builder: (context) => const PromocoesScreen());
      case AppRoutes.conquistas:
        return MaterialPageRoute(builder: (context) => const ConquistasScreen());
      case AppRoutes.metas:
        return MaterialPageRoute(builder: (context) => const MetasScreen());
      case AppRoutes.stats:
        return MaterialPageRoute(builder: (context) => const PassengerAnalyticsDashboardScreen());
      default:
        // Fallback para rotas desconhecidas
        return MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        );
    }
  }
}
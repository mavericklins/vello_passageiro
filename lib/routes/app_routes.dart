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
// Novos imports para rotas faltantes
import '../screens/configuracoes/alterar_senha_screen.dart';
import '../screens/configuracoes/privacidade_screen.dart';
import '../screens/configuracoes/sobre_app_screen.dart';
import '../screens/emergency/emergency_contacts_screen.dart';
import '../screens/emergency/emergency_screen.dart';
import '../screens/security/sos_screen.dart';
import '../screens/incidents/report_incident_screen.dart';
import '../screens/schedule/enhanced_schedule_screen.dart';
import '../screens/schedule/schedule_ride_screen.dart';
import '../screens/shared_ride/create_shared_ride_screen.dart';
import '../screens/profile/favorite_addresses_screen.dart';
import '../screens/profile/preferred_drivers_screen.dart';
import '../screens/profile/travel_preferences_screen.dart';
import '../screens/suporte/chatbot_support_screen.dart';
import '../models/address_model.dart';
import '../services/pricing_service.dart';

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
  
  // Novas rotas adicionadas
  static const String alterarSenha = '/alterar-senha';
  static const String privacidade = '/privacidade';
  static const String sobreApp = '/sobre-app';
  static const String emergency = '/emergency';
  static const String emergencyContacts = '/emergency-contacts';
  static const String sosScreen = '/sos';
  static const String reportIncident = '/report-incident';
  static const String scheduleEnhanced = '/schedule-enhanced';
  static const String scheduleRide = '/schedule-ride';
  static const String sharedRide = '/shared-ride';
  static const String favoriteAddresses = '/favorite-addresses';
  static const String preferredDrivers = '/preferred-drivers';
  static const String travelPreferences = '/travel-preferences';
  static const String chatbotSupport = '/chatbot-support';

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
      // Novas rotas
      alterarSenha: (context) => const AlterarSenhaScreen(),
      privacidade: (context) => const PrivacidadeScreen(),
      sobreApp: (context) => const SobreAppScreen(),
      emergency: (context) => const EmergencyScreen(),
      emergencyContacts: (context) => EmergencyContactsScreen(),
      sosScreen: (context) => SOSScreen(),
      reportIncident: (context) => const ReportIncidentScreen(),
      scheduleEnhanced: (context) => EnhancedScheduleScreen(
        origin: AddressModel(
          id: 'default_origin',
          fullAddress: 'Endereço padrão',
          street: 'Rua Exemplo',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          country: 'Brasil',
          postalCode: '00000-000',
          latitude: -23.5505,
          longitude: -46.6333,
        ),
        destination: AddressModel(
          id: 'default_destination',
          fullAddress: 'Destino padrão',
          street: 'Rua Destino',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          country: 'Brasil',
          postalCode: '00000-000',
          latitude: -23.5505,
          longitude: -46.6333,
        ),
        waypoints: const [],
        selectedVehicleType: VehicleType.economico,
        priceEstimate: PriceEstimate(
          basePrice: 15.0,
          finalPrice: 15.0,
          vehicleType: VehicleType.economico,
          distance: 5000.0,
          duration: 900.0,
          timeMultiplier: 1.0,
          hasWaypoints: false,
          formattedPrice: 'R\$ 15,00',
          formattedDistance: '5.0 km',
          formattedDuration: '15 min',
        ),
      ),
      scheduleRide: (context) => ScheduleRideScreen(
        origin: AddressModel(
          id: 'default_origin',
          fullAddress: 'Endereço padrão',
          street: 'Rua Exemplo',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          country: 'Brasil',
          postalCode: '00000-000',
          latitude: -23.5505,
          longitude: -46.6333,
        ),
        destination: AddressModel(
          id: 'default_destination',
          fullAddress: 'Destino padrão',
          street: 'Rua Destino',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          country: 'Brasil',
          postalCode: '00000-000',
          latitude: -23.5505,
          longitude: -46.6333,
        ),
        waypoints: const [],
        selectedVehicleType: VehicleType.economico,
        priceEstimate: PriceEstimate(
          basePrice: 15.0,
          finalPrice: 15.0,
          vehicleType: VehicleType.economico,
          distance: 5000.0,
          duration: 900.0,
          timeMultiplier: 1.0,
          hasWaypoints: false,
          formattedPrice: 'R\$ 15,00',
          formattedDistance: '5.0 km',
          formattedDuration: '15 min',
        ),
      ),
      sharedRide: (context) => CreateSharedRideScreen(),
      favoriteAddresses: (context) => const FavoriteAddressesScreen(),
      preferredDrivers: (context) => const PreferredDriversScreen(),
      travelPreferences: (context) => const TravelPreferencesScreen(),
      chatbotSupport: (context) => ChatbotSupportScreen(),
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
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => const PagamentosScreen(),
        );
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
      
      // Novas rotas
      case AppRoutes.alterarSenha:
        return MaterialPageRoute(builder: (context) => const AlterarSenhaScreen());
      case AppRoutes.privacidade:
        return MaterialPageRoute(builder: (context) => const PrivacidadeScreen());
      case AppRoutes.sobreApp:
        return MaterialPageRoute(builder: (context) => const SobreAppScreen());
      case AppRoutes.emergency:
        return MaterialPageRoute(builder: (context) => const EmergencyScreen());
      case AppRoutes.emergencyContacts:
        return MaterialPageRoute(builder: (context) => EmergencyContactsScreen());
      case AppRoutes.sosScreen:
        return MaterialPageRoute(builder: (context) => SOSScreen());
      case AppRoutes.reportIncident:
        return MaterialPageRoute(builder: (context) => const ReportIncidentScreen());
      case AppRoutes.scheduleEnhanced:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) => EnhancedScheduleScreen(
          origin: args?['origin'] ?? AddressModel(
            id: 'default_origin',
            fullAddress: 'Endereço padrão',
            street: 'Rua Exemplo',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            country: 'Brasil',
            postalCode: '00000-000',
            latitude: -23.5505,
            longitude: -46.6333,
          ),
          destination: args?['destination'] ?? AddressModel(
            id: 'default_destination',
            fullAddress: 'Destino padrão',
            street: 'Rua Destino',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            country: 'Brasil',
            postalCode: '00000-000',
            latitude: -23.5505,
            longitude: -46.6333,
          ),
          waypoints: args?['waypoints'] ?? const [],
          selectedVehicleType: args?['selectedVehicleType'] ?? VehicleType.economico,
          priceEstimate: args?['priceEstimate'] ?? PriceEstimate(
            basePrice: 15.0,
            finalPrice: 15.0,
            vehicleType: VehicleType.economico,
            distance: 5000.0,
            duration: 900.0,
            timeMultiplier: 1.0,
            hasWaypoints: false,
            formattedPrice: 'R\$ 15,00',
            formattedDistance: '5.0 km',
            formattedDuration: '15 min',
          ),
        ));
      case AppRoutes.scheduleRide:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) => ScheduleRideScreen(
          origin: args?['origin'] ?? AddressModel(
            id: 'default_origin',
            fullAddress: 'Endereço padrão',
            street: 'Rua Exemplo',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            country: 'Brasil',
            postalCode: '00000-000',
            latitude: -23.5505,
            longitude: -46.6333,
          ),
          destination: args?['destination'] ?? AddressModel(
            id: 'default_destination',
            fullAddress: 'Destino padrão',
            street: 'Rua Destino',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            country: 'Brasil',
            postalCode: '00000-000',
            latitude: -23.5505,
            longitude: -46.6333,
          ),
          waypoints: args?['waypoints'] ?? const [],
          selectedVehicleType: args?['selectedVehicleType'] ?? VehicleType.economico,
          priceEstimate: args?['priceEstimate'] ?? PriceEstimate(
            basePrice: 15.0,
            finalPrice: 15.0,
            vehicleType: VehicleType.economico,
            distance: 5000.0,
            duration: 900.0,
            timeMultiplier: 1.0,
            hasWaypoints: false,
            formattedPrice: 'R\$ 15,00',
            formattedDistance: '5.0 km',
            formattedDuration: '15 min',
          ),
        ));
      case AppRoutes.sharedRide:
        return MaterialPageRoute(builder: (context) => CreateSharedRideScreen());
      case AppRoutes.favoriteAddresses:
        return MaterialPageRoute(builder: (context) => const FavoriteAddressesScreen());
      case AppRoutes.preferredDrivers:
        return MaterialPageRoute(builder: (context) => const PreferredDriversScreen());
      case AppRoutes.travelPreferences:
        return MaterialPageRoute(builder: (context) => const TravelPreferencesScreen());
      case AppRoutes.chatbotSupport:
        return MaterialPageRoute(builder: (context) => ChatbotSupportScreen());
        
      default:
        // Fallback para rotas desconhecidas
        return MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        );
    }
  }
}
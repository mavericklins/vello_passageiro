/// Sistema de feature flags para funcionalidades premium do Passageiro
class FeatureFlags {
  // Funcionalidades premium
  static const bool enableVoiceAssistant = true;
  static const bool enableAdvancedSOS = true;
  static const bool enableTripSharing = true;
  static const bool enableEmergencyService = true;
  static const bool enableChatbotSupport = true;
  static const bool enableScheduledRides = true;
  static const bool enableRealTimeTracking = true;

  // Funcionalidades experimentais
  static const bool enableAdvancedAnalytics = true;
  static const bool enableGamification = true;

  /// Verifica se uma feature está habilitada
  static bool isEnabled(String feature) {
    switch (feature) {
      case 'voice_assistant':
        return enableVoiceAssistant;
      case 'advanced_sos':
        return enableAdvancedSOS;
      case 'trip_sharing':
        return enableTripSharing;
      case 'emergency_service':
        return enableEmergencyService;
      case 'chatbot_support':
        return enableChatbotSupport;
      case 'scheduled_rides':
        return enableScheduledRides;
      case 'real_time_tracking':
        return enableRealTimeTracking;
      case 'advanced_analytics':
        return enableAdvancedAnalytics;
      case 'gamification':
        return enableGamification;
      default:
        return false;
    }
  }
}
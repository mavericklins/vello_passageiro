import '../models/address_model.dart';
import 'address_search_service.dart';
import 'dart:math' as math;
import '../core/logger_service.dart';
import '../core/error_handler.dart';

enum VehicleType {
  economico('Econômico', 'Ideal para o dia a dia', 1.0, 'assets/car_economy.png'),
  executivo('Executivo', 'Conforto e pontualidade', 1.5, 'assets/car_executive.png'),
  premium('Premium', 'Máximo conforto e luxo', 2.0, 'assets/car_premium.png');

  const VehicleType(this.name, this.description, this.priceMultiplier, this.iconPath);

  final String name;
  final String description;
  final double priceMultiplier;
  final String iconPath;
}

class PricingService {
  // Valores base (podem vir de uma API ou configuração)
  static const double _basePrice = 3.50; // Preço base
  static const double _pricePerKm = 2.20; // Preço por km
  static const double _pricePerMinute = 0.45; // Preço por minuto
  static const double _minimumPrice = 8.00; // Preço mínimo

  // Multiplicadores por horário
  static const Map<int, double> _timeMultipliers = {
    6: 1.0,   // 06:00-07:59
    8: 1.2,   // 08:00-09:59 (rush matinal)
    10: 1.0,  // 10:00-11:59
    12: 1.1,  // 12:00-13:59 (almoço)
    14: 1.0,  // 14:00-17:59
    18: 1.3,  // 18:00-19:59 (rush vespertino)
    20: 1.0,  // 20:00-21:59
    22: 1.1,  // 22:00-05:59 (noturno)
  };

  // Calcular preço estimado
  static Future<PriceEstimate?> calculatePrice({
    required AddressModel origin,
    required AddressModel destination,
    required VehicleType vehicleType,
    List<AddressModel>? waypoints,
    DateTime? scheduledTime,
  }) async {
    try {
      // Calcular rota
      final routeInfo = await AddressSearchService.calculateRoute(
        origin,
        destination,
        waypoints: waypoints
      );

      // Se a API falhar, usar estimativa baseada em distância linear
      if (routeInfo == null) {
        LoggerService.info('API de rota falhou, usando estimativa linear', context: 'PricingService');
        return _createFallbackEstimate(origin, destination, vehicleType, scheduledTime);
      }

      // Calcular preço base
      double price = _basePrice;
      price += (routeInfo.distanceKm * _pricePerKm);
      price += (routeInfo.durationMinutes * _pricePerMinute);

      // Aplicar multiplicador do tipo de veículo
      price *= vehicleType.priceMultiplier;

      // Aplicar multiplicador de horário
      final hour = (scheduledTime ?? DateTime.now()).hour;
      final timeMultiplier = _getTimeMultiplier(hour);
      price *= timeMultiplier;

      // Garantir preço mínimo
      if (price < _minimumPrice) {
        price = _minimumPrice;
      }

      return PriceEstimate(
        basePrice: price,
        finalPrice: price,
        vehicleType: vehicleType,
        distance: routeInfo.distance,
        duration: routeInfo.duration,
        timeMultiplier: timeMultiplier,
        hasWaypoints: waypoints != null && waypoints.isNotEmpty,
        formattedPrice: 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
        formattedDistance: routeInfo.formattedDistance,
        formattedDuration: routeInfo.formattedDuration,
      );

    } catch (e) {
      LoggerService.info('Erro ao calcular preço: $e', context: 'PricingService');
      // Fallback em caso de erro
      return _createFallbackEstimate(origin, destination, vehicleType, scheduledTime);
    }
  }

  // Criar estimativa de fallback quando a API falha
  static PriceEstimate _createFallbackEstimate(
    AddressModel origin,
    AddressModel destination,
    VehicleType vehicleType,
    DateTime? scheduledTime
  ) {
    // Calcular distância linear aproximada
    final distanceKm = _calculateLinearDistance(origin, destination);
    final estimatedDurationMinutes = distanceKm * 2.5; // Estimativa: 2.5 min por km

    // Calcular preço base
    double price = _basePrice;
    price += (distanceKm * _pricePerKm);
    price += (estimatedDurationMinutes * _pricePerMinute);

    // Aplicar multiplicador do tipo de veículo
    price *= vehicleType.priceMultiplier;

    // Aplicar multiplicador de horário
    final hour = (scheduledTime ?? DateTime.now()).hour;
    final timeMultiplier = _getTimeMultiplier(hour);
    price *= timeMultiplier;

    // Garantir preço mínimo
    if (price < _minimumPrice) {
      price = _minimumPrice;
    }

    return PriceEstimate(
      basePrice: price,
      finalPrice: price,
      vehicleType: vehicleType,
      distance: distanceKm * 1000, // converter para metros
      duration: estimatedDurationMinutes * 60, // converter para segundos
      timeMultiplier: timeMultiplier,
      hasWaypoints: false,
      formattedPrice: 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
      formattedDistance: '~${distanceKm.toStringAsFixed(1)} km',
      formattedDuration: '~${estimatedDurationMinutes.round()} min',
    );
  }

  // Calcular distância linear entre dois pontos
  static double _calculateLinearDistance(AddressModel origin, AddressModel destination) {
    const double earthRadius = 6371; // Raio da Terra em km

    final lat1Rad = origin.latitude * (math.pi / 180);
    final lat2Rad = destination.latitude * (math.pi / 180);
    final deltaLatRad = (destination.latitude - origin.latitude) * (math.pi / 180);
    final deltaLonRad = (destination.longitude - origin.longitude) * (math.pi / 180);

    final a = math.pow(math.sin(deltaLatRad / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.pow(math.sin(deltaLonRad / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Calcular preços para todos os tipos de veículo
  static Future<List<PriceEstimate>> calculateAllPrices({
    required AddressModel origin,
    required AddressModel destination,
    List<AddressModel>? waypoints,
    DateTime? scheduledTime,
  }) async {
    List<PriceEstimate> estimates = [];

    for (VehicleType vehicleType in VehicleType.values) {
      final estimate = await calculatePrice(
        origin: origin,
        destination: destination,
        vehicleType: vehicleType,
        waypoints: waypoints,
        scheduledTime: scheduledTime,
      );

      if (estimate != null) {
        estimates.add(estimate);
      }
    }

    return estimates;
  }

  // Aplicar cupom de desconto
  static PriceEstimate applyCoupon(PriceEstimate estimate, CouponModel coupon) {
    double discount = 0;

    if (coupon.discountType == DiscountType.percentage) {
      discount = estimate.basePrice * (coupon.discountValue / 100);
    } else {
      discount = coupon.discountValue;
    }

    // Aplicar desconto máximo se houver
    if (coupon.maxDiscount != null && discount > coupon.maxDiscount!) {
      discount = coupon.maxDiscount!;
    }

    final finalPrice = (estimate.basePrice - discount).clamp(0, double.infinity);

    return estimate.copyWith(
      finalPrice: finalPrice.toDouble(),
      appliedCoupon: coupon,
      discount: discount,
      formattedPrice: 'R\$ ${finalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
    );
  }

  static double _getTimeMultiplier(int hour) {
    // Encontrar o multiplicador baseado na hora
    final keys = _timeMultipliers.keys.toList()..sort();

    for (int i = 0; i < keys.length; i++) {
      final currentHour = keys[i];
      final nextHour = i + 1 < keys.length ? keys[i + 1] : 24;

      if (hour >= currentHour && hour < nextHour) {
        return _timeMultipliers[currentHour]!;
      }
    }

    // Horário noturno (22:00-05:59)
    return _timeMultipliers[22]!;
  }
}

class PriceEstimate {
  final double basePrice;
  final double finalPrice;
  final VehicleType vehicleType;
  final double distance; // metros
  final double duration; // segundos
  final double timeMultiplier;
  final bool hasWaypoints;
  final String formattedPrice;
  final String formattedDistance;
  final String formattedDuration;
  final CouponModel? appliedCoupon;
  final double? discount;

  PriceEstimate({
    required this.basePrice,
    required this.finalPrice,
    required this.vehicleType,
    required this.distance,
    required this.duration,
    required this.timeMultiplier,
    required this.hasWaypoints,
    required this.formattedPrice,
    required this.formattedDistance,
    required this.formattedDuration,
    this.appliedCoupon,
    this.discount,
  });

  PriceEstimate copyWith({
    double? basePrice,
    double? finalPrice,
    VehicleType? vehicleType,
    double? distance,
    double? duration,
    double? timeMultiplier,
    bool? hasWaypoints,
    String? formattedPrice,
    String? formattedDistance,
    String? formattedDuration,
    CouponModel? appliedCoupon,
    double? discount,
  }) {
    return PriceEstimate(
      basePrice: basePrice ?? this.basePrice,
      finalPrice: finalPrice ?? this.finalPrice,
      vehicleType: vehicleType ?? this.vehicleType,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      timeMultiplier: timeMultiplier ?? this.timeMultiplier,
      hasWaypoints: hasWaypoints ?? this.hasWaypoints,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      formattedDistance: formattedDistance ?? this.formattedDistance,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discount: discount ?? this.discount,
    );
  }
}

enum DiscountType { percentage, fixed }

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final double? maxDiscount;
  final DateTime? expiryDate;
  final bool isActive;
  final int? usageLimit;
  final int usageCount;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.expiryDate,
    required this.isActive,
    this.usageLimit,
    required this.usageCount,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    return true;
  }

  String get formattedDiscount {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toInt()}% OFF';
    } else {
      return 'R\$ ${discountValue.toStringAsFixed(2).replaceAll('.', ',')} OFF';
    }
  }
}
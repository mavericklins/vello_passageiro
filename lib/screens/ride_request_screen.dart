import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/address_model.dart';
import '../services/address_search_service.dart';
import '../services/pricing_service.dart';
import '../services/favorites_service.dart';
import '../services/promotions_service.dart';
import '../widgets/address_search_widget.dart';
import '../widgets/vehicle_selection_widget.dart';
import 'schedule/schedule_ride_screen.dart';
import '../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class RideRequestScreen extends StatefulWidget {
  final String? initialDestination;
  
  const RideRequestScreen({Key? key, this.initialDestination}) : super(key: key);
  
  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  AddressModel? _origin;
  AddressModel? _destination;
  List<AddressModel> _waypoints = [];
  List<PriceEstimate> _priceEstimates = [];
  VehicleType _selectedVehicleType = VehicleType.economico;
  bool _isLoadingPrices = false;
  bool _isLoadingLocation = true;
  String? _appliedCouponCode;
  Promotion? _appliedCoupon;
  
  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    
    if (widget.initialDestination != null && widget.initialDestination!.isNotEmpty) {
      _searchInitialDestination();
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final originAddress = await AddressSearchService.getAddressDetails(
        position.latitude, 
        position.longitude
      );
      
      if (originAddress != null && mounted) {
        setState(() {
          _origin = originAddress;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao obter localização: $e', context: context ?? 'UNKNOWN');
      setState(() => _isLoadingLocation = false);
    }
  }
  
  Future<void> _searchInitialDestination() async {
    final results = await AddressSearchService.searchAddresses(widget.initialDestination!);
    if (results.isNotEmpty && mounted) {
      setState(() {
        _destination = results.first;
      });
      _calculatePrices();
    }
  }
  
  Future<void> _calculatePrices() async {
    if (_origin == null || _destination == null) return;
    
    setState(() {
      _isLoadingPrices = true;
    });
    
    try {
      final estimates = await PricingService.calculateAllPrices(
        origin: _origin!,
        destination: _destination!,
        waypoints: _waypoints.isNotEmpty ? _waypoints : null,
      );
      
      // Aplicar cupom se houver
      List<PriceEstimate> finalEstimates = estimates;
      if (_appliedCoupon != null) {
        finalEstimates = estimates.map((estimate) => 
          PricingService.applyCoupon(estimate, 
            CouponModel(
              id: _appliedCoupon!.id,
              code: _appliedCoupon!.code,
              title: _appliedCoupon!.title,
              description: _appliedCoupon!.description,
              discountType: _appliedCoupon!.discountType,
              discountValue: _appliedCoupon!.discountValue,
              maxDiscount: _appliedCoupon!.maxDiscount,
              expiryDate: _appliedCoupon!.endDate,
              isActive: _appliedCoupon!.isActive,
              usageLimit: _appliedCoupon!.usageLimit,
              usageCount: _appliedCoupon!.usageCount,
            )
          )
        ).toList();
      }
      
      if (mounted) {
        setState(() {
          _priceEstimates = finalEstimates;
          _isLoadingPrices = false;
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao calcular preços: $e', context: context ?? 'UNKNOWN');
      if (mounted) {
        setState(() {
          _isLoadingPrices = false;
        });
      }
    }
  }
  
  void _onOriginSelected(AddressModel address) {
    setState(() {
      _origin = address;
    });
    _calculatePrices();
  }
  
  void _onDestinationSelected(AddressModel address) {
    setState(() {
      _destination = address;
    });
    _calculatePrices();
  }
  
  void _onVehicleSelected(VehicleType vehicleType) {
    setState(() {
      _selectedVehicleType = vehicleType;
    });
  }
  
  void _addWaypoint() {
    // Implementar adição de paradas
    // Por simplicidade, vamos limitar a 2 paradas
    if (_waypoints.length < 2) {
      showDialog(
        context: context,
        builder: (context) => _WaypointDialog(
          onWaypointAdded: (address) {
            setState(() {
              _waypoints.add(address);
            });
            _calculatePrices();
          },
        ),
      );
    }
  }
  
  void _removeWaypoint(int index) {
    setState(() {
      _waypoints.removeAt(index);
    });
    _calculatePrices();
  }
  
  Future<void> _applyCoupon() async {
    showDialog(
      context: context,
      builder: (context) => _CouponDialog(
        onCouponApplied: (coupon) {
          setState(() {
            _appliedCoupon = coupon;
            _appliedCouponCode = coupon.code;
          });
          _calculatePrices();
        },
      ),
    );
  }
  
  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _appliedCouponCode = null;
    });
    _calculatePrices();
  }
  
  void _scheduleRide() {
    if (_origin == null || _destination == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleRideScreen(
          origin: _origin!,
          destination: _destination!,
          waypoints: _waypoints,
          selectedVehicleType: _selectedVehicleType,
          priceEstimate: _priceEstimates.firstWhere(
            (e) => e.vehicleType == _selectedVehicleType,
            orElse: () => _priceEstimates.first,
          ),
          appliedCoupon: _appliedCoupon,
        ),
      ),
    );
  }
  
  void _requestRideNow() {
    if (_origin == null || _destination == null) return;
    
    final selectedEstimate = _priceEstimates.firstWhere(
      (e) => e.vehicleType == _selectedVehicleType,
      orElse: () => _priceEstimates.first,
    );
    
    // Navegar para tela de busca de motorista
    Navigator.pushNamed(
      context,
      '/buscando_motoristas',
      arguments: {
        'origin': _origin!.toMap(),
        'destination': _destination!.toMap(),
        'waypoints': _waypoints.map((w) => w.toMap()).toList(),
        'vehicleType': _selectedVehicleType.name,
        'estimatedPrice': selectedEstimate.finalPrice,
        'couponCode': _appliedCouponCode,
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Solicitar Corrida',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: VelloTokens.white,
        elevation: 0,
        foregroundColor: velloBlue,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: velloOrange,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: velloBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.schedule,
                color: velloBlue,
                size: 20,
              ),
            ),
            onPressed: _scheduleRide,
            tooltip: 'Agendar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Origem
            _buildLocationCard(
              title: 'De onde você está saindo?',
              icon: Icons.my_location,
              iconColor: velloBlue,
              child: _isLoadingLocation
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: velloOrange),
                      ),
                    )
                  : AddressSearchWidget(
                      hint: 'Endereço de origem',
                      initialAddress: _origin,
                      onAddressSelected: _onOriginSelected,
                      prefixIcon: Icons.my_location,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Card de Destino
            _buildLocationCard(
              title: 'Para onde você vai?',
              icon: Icons.location_on,
              iconColor: velloOrange,
              child: AddressSearchWidget(
                hint: 'Endereço de destino',
                initialAddress: _destination,
                onAddressSelected: _onDestinationSelected,
                prefixIcon: Icons.location_on,
              ),
            ),
            
            // Paradas extras
            if (_waypoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildWaypointsCard(),
            ],
            
            // Botão adicionar parada
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addWaypoint,
              icon: Icon(Icons.add_location_alt, color: velloOrange),
              label: Text(
                'Adicionar parada',
                style: TextStyle(color: velloOrange),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Seleção de veículos
            if (_priceEstimates.isNotEmpty) ...[
              VehicleSelectionWidget(
                priceEstimates: _priceEstimates,
                selectedVehicleType: _selectedVehicleType,
                onVehicleSelected: _onVehicleSelected,
                isLoading: _isLoadingPrices,
              ),
              
              const SizedBox(height: 16),
              
              // Card de cupom
              _buildCouponCard(),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              _buildActionButtons(),
            ] else if (_isLoadingPrices) ...[
              VehicleSelectionWidget(
                priceEstimates: const [],
                selectedVehicleType: _selectedVehicleType,
                onVehicleSelected: _onVehicleSelected,
                isLoading: true,
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLocationCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaypointsCard() {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_location_alt,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Paradas extras',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(_waypoints.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: velloLightGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _waypoints[index].shortAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeWaypoint(index),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCouponCard() {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appliedCoupon != null
                        ? 'Cupom aplicado: ${_appliedCoupon!.code}'
                        : 'Cupom de desconto',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  if (_appliedCoupon != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _appliedCoupon!.formattedDiscount,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_appliedCoupon != null)
              IconButton(
                onPressed: _removeCoupon,
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
              )
            else
              TextButton(
                onPressed: _applyCoupon,
                child: Text(
                  'Aplicar',
                  style: TextStyle(color: velloOrange),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    final canRequestRide = _origin != null && _destination != null && _priceEstimates.isNotEmpty;
    
    return Column(
      children: [
        // Botão principal - Solicitar agora
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canRequestRide ? _requestRideNow : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRequestRide ? velloOrange : Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: canRequestRide ? 8 : 0,
            ),
            child: const Text(
              'Solicitar Agora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VelloTokens.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botão secundário - Agendar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: canRequestRide ? _scheduleRide : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: canRequestRide ? velloBlue : Colors.grey[400]!,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Agendar para mais tarde',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: canRequestRide ? velloBlue : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Dialog para adicionar parada
class _WaypointDialog extends StatefulWidget {
  final Function(AddressModel) onWaypointAdded;
  
  const _WaypointDialog({required this.onWaypointAdded});
  
  @override
  State<_WaypointDialog> createState() => _WaypointDialogState();
}

class _WaypointDialogState extends State<_WaypointDialog> {
  AddressModel? _selectedAddress;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Parada'),
      content: SizedBox(
        width: double.maxFinite,
        child: AddressSearchWidget(
          hint: 'Endereço da parada',
          onAddressSelected: (address) {
            setState(() {
              _selectedAddress = address;
            });
          },
          showFavorites: false,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedAddress != null
              ? () {
                  widget.onWaypointAdded(_selectedAddress!);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

// Dialog para aplicar cupom
class _CouponDialog extends StatefulWidget {
  final Function(Promotion) onCouponApplied;
  
  const _CouponDialog({required this.onCouponApplied});
  
  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isValidating = false;
  String? _errorMessage;
  
  Future<void> _validateCoupon() async {
    if (_codeController.text.trim().isEmpty) return;
    
    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });
    
    try {
      final coupon = await PromotionsService.validateCouponCode(_codeController.text.trim());
      
      if (coupon != null) {
        widget.onCouponApplied(coupon);
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Cupom inválido ou expirado';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao validar cupom';
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aplicar Cupom'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Código do cupom',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          if (_isValidating) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isValidating ? null : _validateCoupon,
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
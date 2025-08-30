import 'package:flutter/material.dart';
import '../services/pricing_service.dart';
import '../theme/vello_tokens.dart';

class VehicleSelectionWidget extends StatefulWidget {
  final List<PriceEstimate> priceEstimates;
  final VehicleType selectedVehicleType;
  final Function(VehicleType) onVehicleSelected;
  final bool isLoading;
  
  const VehicleSelectionWidget({
    Key? key,
    required this.priceEstimates,
    required this.selectedVehicleType,
    required this.onVehicleSelected,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  State<VehicleSelectionWidget> createState() => _VehicleSelectionWidgetState();
}

class _VehicleSelectionWidgetState extends State<VehicleSelectionWidget> {
  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: 180,
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: velloOrange,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Calculando preços...',
                style: TextStyle(
                  color: velloBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (widget.priceEstimates.isEmpty) {
      return Container(
        height: 120,
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.grey,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Não foi possível calcular o preço',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: velloOrange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Escolha seu veículo',
                  style: TextStyle(
                    color: velloBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    widget.priceEstimates.first.formattedDistance,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          ...widget.priceEstimates.map((estimate) => _buildVehicleOption(estimate)),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  Widget _buildVehicleOption(PriceEstimate estimate) {
    final isSelected = estimate.vehicleType == widget.selectedVehicleType;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => widget.onVehicleSelected(estimate.vehicleType),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? velloOrange : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? velloOrange.withOpacity(0.05) : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone do veículo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getVehicleColor(estimate.vehicleType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getVehicleIcon(estimate.vehicleType),
                    color: _getVehicleColor(estimate.vehicleType),
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Informações do veículo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            estimate.vehicleType.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? velloOrange : velloBlue,
                            ),
                          ),
                          if (estimate.timeMultiplier > 1.0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(estimate.timeMultiplier * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        estimate.vehicleType.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estimate.formattedDuration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Preço
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      estimate.formattedPrice,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? velloOrange : velloBlue,
                      ),
                    ),
                    if (estimate.discount != null && estimate.discount! > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'R\$ ${estimate.basePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(width: 8),
                
                // Indicador de seleção
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? velloOrange : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? velloOrange : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: VelloTokens.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getVehicleIcon(VehicleType vehicleType) {
    switch (vehicleType) {
      case VehicleType.economico:
        return Icons.directions_car;
      case VehicleType.executivo:
        return Icons.car_rental;
      case VehicleType.premium:
        return Icons.delivery_dining;
    }
  }
  
  Color _getVehicleColor(VehicleType vehicleType) {
    switch (vehicleType) {
      case VehicleType.economico:
        return const VelloTokens.success; // Verde
      case VehicleType.executivo:
        return const VelloTokens.info; // Azul
      case VehicleType.premium:
        return const VelloTokens.info; // Roxo
    }
  }
}
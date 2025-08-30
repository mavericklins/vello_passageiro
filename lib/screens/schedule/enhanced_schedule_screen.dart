import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/pricing_service.dart';
import '../../services/schedule_service.dart';
import '../../services/promotions_service.dart';
import '../../theme/vello_tokens.dart';

class EnhancedScheduleScreen extends StatefulWidget {
  final AddressModel origin;
  final AddressModel destination;
  final List<AddressModel> waypoints;
  final VehicleType selectedVehicleType;
  final PriceEstimate priceEstimate;
  final Promotion? appliedCoupon;
  
  const EnhancedScheduleScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.selectedVehicleType,
    required this.priceEstimate,
    this.appliedCoupon,
  }) : super(key: key);
  
  @override
  State<EnhancedScheduleScreen> createState() => _EnhancedScheduleScreenState();
}

class _EnhancedScheduleScreenState extends State<EnhancedScheduleScreen> {
  DateTime _selectedDate = DateTime.now().add(Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _notesController = TextEditingController();
  bool _isScheduling = false;
  bool _isRecurring = false;
  String _recurringFrequency = 'weekly';
  int _recurringDuration = 4; // semanas
  List<int> _selectedWeekdays = [];
  bool _notifyInAdvance = true;
  int _notificationMinutes = 15;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  
  final List<String> weekdayNames = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    // Definir horário mínimo como próxima hora
    final now = DateTime.now();
    _selectedTime = TimeOfDay(hour: now.hour + 1, minute: 0);
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  DateTime get _scheduledDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }
  
  bool get _canSchedule {
    final now = DateTime.now();
    return _scheduledDateTime.isAfter(now.add(Duration(minutes: 30))) &&
           (!_isRecurring || _selectedWeekdays.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Agendar Corrida Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: VelloTokens.white,
        elevation: 2,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo da corrida
            _buildRideSummaryCard(),
            
            const SizedBox(height: 16),
            
            // Seleção de data e hora
            _buildDateTimeCard(),
            
            const SizedBox(height: 16),
            
            // Opções de recorrência
            _buildRecurringCard(),
            
            const SizedBox(height: 16),
            
            // Notificações
            _buildNotificationCard(),
            
            const SizedBox(height: 16),
            
            // Observações
            _buildNotesCard(),
            
            const SizedBox(height: 24),
            
            // Botão de confirmar
            _buildConfirmButton(),
            
            const SizedBox(height: 16),
            
            // Prévia dos agendamentos
            if (_isRecurring && _selectedWeekdays.isNotEmpty)
              _buildSchedulePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildRideSummaryCard() {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: velloBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.route,
                    color: velloBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumo da Corrida',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Origem
            _buildLocationRow(
              icon: Icons.my_location,
              iconColor: velloBlue,
              label: 'Origem',
              address: widget.origin.shortAddress,
            ),
            
            const SizedBox(height: 12),
            
            // Paradas
            if (widget.waypoints.isNotEmpty) ...[
              ...widget.waypoints.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLocationRow(
                    icon: Icons.add_location_alt,
                    iconColor: Colors.green,
                    label: 'Parada ${entry.key + 1}',
                    address: entry.value.shortAddress,
                  ),
                );
              }),
            ],
            
            // Destino
            _buildLocationRow(
              icon: Icons.location_on,
              iconColor: velloOrange,
              label: 'Destino',
              address: widget.destination.shortAddress,
            ),
            
            const SizedBox(height: 16),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            // Detalhes do veículo e preço
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedVehicleType.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: velloBlue,
                        ),
                      ),
                      Text(
                        widget.selectedVehicleType.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.priceEstimate.formattedDistance,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.priceEstimate.formattedPrice,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: velloOrange,
                      ),
                    ),
                    if (widget.appliedCoupon != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          widget.appliedCoupon!.formattedDiscount,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: velloOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: velloOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Data e Horário',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeSelector(
                    title: 'Data',
                    value: '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    icon: Icons.calendar_today,
                    onTap: _selectDate,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildDateTimeSelector(
                    title: 'Horário',
                    value: _selectedTime.format(context),
                    icon: Icons.access_time,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            
            if (!_canSchedule && !_isRecurring) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O agendamento deve ser feito com pelo menos 30 minutos de antecedência.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringCard() {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.repeat,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Agendamento Recorrente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                ),
                Switch(
                  value: _isRecurring,
                  activeColor: velloOrange,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                      if (!value) {
                        _selectedWeekdays.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            
            if (_isRecurring) ...[
              const SizedBox(height: 20),
              
              Text(
                'Repetir em quais dias?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final isSelected = _selectedWeekdays.contains(index);
                  return FilterChip(
                    label: Text(
                      weekdayNames[index],
                      style: TextStyle(
                        color: isSelected ? VelloTokens.white : velloBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: velloBlue,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedWeekdays.add(index);
                        } else {
                          _selectedWeekdays.remove(index);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[100],
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frequência',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _recurringFrequency,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                            DropdownMenuItem(value: 'biweekly', child: Text('Quinzenal')),
                            DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _recurringFrequency = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duração (semanas)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _recurringDuration,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: List.generate(12, (index) {
                            final weeks = index + 1;
                            return DropdownMenuItem(
                              value: weeks,
                              child: Text('$weeks semana${weeks > 1 ? 's' : ''}'),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _recurringDuration = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Notificações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                ),
                Switch(
                  value: _notifyInAdvance,
                  activeColor: velloOrange,
                  onChanged: (value) {
                    setState(() {
                      _notifyInAdvance = value;
                    });
                  },
                ),
              ],
            ),
            
            if (_notifyInAdvance) ...[
              const SizedBox(height: 16),
              
              Text(
                'Notificar quantos minutos antes?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 30, 60].map((minutes) {
                  final isSelected = _notificationMinutes == minutes;
                  return FilterChip(
                    label: Text(
                      '$minutes min',
                      style: TextStyle(
                        color: isSelected ? VelloTokens.white : velloBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: velloBlue,
                    onSelected: (selected) {
                      setState(() {
                        _notificationMinutes = minutes;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulePreview() {
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
        padding: const EdgeInsets.all(20),
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
                    Icons.preview,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Prévia dos Agendamentos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: velloLightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suas corridas serão agendadas para:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...List.generate(
                    _recurringDuration.clamp(1, 4),
                    (weekIndex) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• Semana ${weekIndex + 1}: ${_selectedWeekdays.map((day) => weekdayNames[day]).join(', ')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: velloBlue,
                        ),
                      ),
                    ),
                  ),
                  
                  if (_recurringDuration > 4) ...[
                    Text(
                      '... e mais ${_recurringDuration - 4} semanas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Total: ${_selectedWeekdays.length * _recurringDuration} corridas agendadas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: velloBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: velloLightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: velloBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note_add,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Observações (opcional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Adicione observações para o motorista...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: velloOrange, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                filled: true,
                fillColor: velloLightGray,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_canSchedule && !_isScheduling) ? _scheduleRide : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: (_canSchedule && !_isScheduling) ? velloOrange : Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: (_canSchedule && !_isScheduling) ? 8 : 0,
        ),
        child: _isScheduling
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: VelloTokens.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isRecurring 
                    ? 'Confirmar ${_selectedWeekdays.length * _recurringDuration} Agendamentos'
                    : 'Confirmar Agendamento',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VelloTokens.white,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: velloOrange,
              onPrimary: VelloTokens.white,
              surface: VelloTokens.white,
              onSurface: velloBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: velloOrange,
              onPrimary: VelloTokens.white,
              surface: VelloTokens.white,
              onSurface: velloBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleRide() async {
    if (!_canSchedule) return;
    
    setState(() {
      _isScheduling = true;
    });
    
    try {
      if (_isRecurring && _selectedWeekdays.isNotEmpty) {
        // Agendar múltiplas corridas
        await _scheduleRecurringRides();
      } else {
        // Agendar corrida única
        await _scheduleSingleRide();
      }
      
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar corrida: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScheduling = false;
        });
      }
    }
  }

  Future<void> _scheduleSingleRide() async {
    final rideId = await ScheduleService.scheduleRide(
      origin: widget.origin,
      destination: widget.destination,
      waypoints: widget.waypoints,
      scheduledTime: _scheduledDateTime,
      vehicleType: widget.selectedVehicleType,
      estimatedPrice: widget.priceEstimate.finalPrice,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      couponCode: widget.appliedCoupon?.code,
    );
    
    if (rideId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Corrida agendada com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      throw Exception('Falha ao agendar corrida');
    }
  }

  Future<void> _scheduleRecurringRides() async {
    int successCount = 0;
    int totalRides = _selectedWeekdays.length * _recurringDuration;
    
    // Agendar para cada semana
    for (int week = 0; week < _recurringDuration; week++) {
      // Para cada dia da semana selecionado
      for (int weekday in _selectedWeekdays) {
        // Calcular a data específica
        DateTime rideDate = _scheduledDateTime;
        
        // Ajustar para a semana e dia corretos
        int daysToAdd = (weekday - rideDate.weekday + 7) % 7 + (week * 7);
        rideDate = rideDate.add(Duration(days: daysToAdd));
        
        final rideId = await ScheduleService.scheduleRide(
          origin: widget.origin,
          destination: widget.destination,
          waypoints: widget.waypoints,
          scheduledTime: DateTime(
            rideDate.year,
            rideDate.month,
            rideDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
          vehicleType: widget.selectedVehicleType,
          estimatedPrice: widget.priceEstimate.finalPrice,
          notes: _notesController.text.trim().isNotEmpty 
              ? '${_notesController.text.trim()} (Recorrente - Semana ${week + 1})' 
              : 'Corrida recorrente - Semana ${week + 1}',
          couponCode: widget.appliedCoupon?.code,
        );
        
        if (rideId != null) {
          successCount++;
        }
      }
    }
    
    if (successCount == totalRides) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$totalRides corridas agendadas com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount de $totalRides corridas agendadas'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      throw Exception('Nenhuma corrida foi agendada');
    }
  }
}
import 'package:flutter/material.dart';
import '../../../models/vehicle.dart';

class RentModal extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onClose;
  final Function(int) onConfirm;

  const RentModal({
    super.key,
    required this.vehicle,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  State<RentModal> createState() => _RentModalState();
}

class _RentModalState extends State<RentModal> {
  final _formKey = GlobalKey<FormState>();
  final _daysController = TextEditingController(text: '30');
  String? _error;

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final days = int.tryParse(_daysController.text);
    if (days == null || days <= 0 || days > 365) {
      setState(() {
        _error = 'Количество дней должно быть от 1 до 365';
      });
      return;
    }

    widget.onConfirm(days);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF404040)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Аренда машины',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFb0b0b0)),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d2d),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF404040)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF404040),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: Color(0xFF8a2be2),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Госномер: ${widget.vehicle.licensePlate}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildVehicleDetail('Модель', widget.vehicle.model ?? 'N/A'),
                        _buildVehicleDetail('Тип', widget.vehicle.vehicleType ?? 'N/A'),
                        _buildVehicleDetail('Статус', widget.vehicle.isAvailable ? 'Доступна' : 'Арендована'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _daysController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Срок аренды (дней) *',
                      labelStyle: const TextStyle(color: Color(0xFFb0b0b0)),
                      helperText: 'Минимум 1 день, максимум 365 дней',
                      helperStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF404040)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF404040)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF8a2be2),
                          width: 2,
                        ),
                      ),
                      fillColor: const Color(0xFF2d2d2d),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите количество дней';
                      }
                      final days = int.tryParse(value);
                      if (days == null || days <= 0 || days > 365) {
                        return 'Количество дней должно быть от 1 до 365';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _error = null;
                      });
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3a1f1f),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFff6b6b)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: const Color(0xFFff6b6b),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFff6b6b),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onClose,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFb0b0b0),
                          backgroundColor: const Color(0xFF2d2d2d),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF404040)),
                          ),
                        ),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8a2be2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF8a2be2).withOpacity(0.4),
                        ),
                        child: const Text('Арендовать'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFFb0b0b0),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8), // <-- Добавлена эта строка
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ), // <-- Закрывающая скобка для Padding
    ); // <-- Точка с запятой и закрывающая скобка для метода
  }
} // <-- Закрывающая скобка для класса
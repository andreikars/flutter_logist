import 'package:flutter/material.dart';
import '../../../models/vehicle.dart';

class VehicleForm extends StatefulWidget {
  final Vehicle? vehicle;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const VehicleForm({
    super.key,
    this.vehicle,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licensePlateController;
  late TextEditingController _modelController;
  late TextEditingController _vehicleTypeController;

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController(text: widget.vehicle?.licensePlate ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _vehicleTypeController = TextEditingController(text: widget.vehicle?.vehicleType ?? '');
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _modelController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicleData = {
      'licensePlate': _licensePlateController.text.trim(),
      'isAvailable': true,
    };

    if (_modelController.text.isNotEmpty) {
      vehicleData['model'] = _modelController.text.trim();
    }
    if (_vehicleTypeController.text.isNotEmpty) {
      vehicleData['vehicleType'] = _vehicleTypeController.text.trim();
    }

    widget.onSave(vehicleData);
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
                  Text(
                    widget.vehicle == null ? 'Добавить машину' : 'Редактировать машину',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _licensePlateController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Госномер *',
                      labelStyle: const TextStyle(color: Color(0xFFb0b0b0)),
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
                        Icons.confirmation_number,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите госномер';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Модель',
                      labelStyle: const TextStyle(color: Color(0xFFb0b0b0)),
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
                        Icons.directions_car,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleTypeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Тип',
                      labelStyle: const TextStyle(color: Color(0xFFb0b0b0)),
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
                        Icons.category,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onCancel,
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
                        onPressed: _handleSave,
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
                        child: const Text('Сохранить'),
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
}
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
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Госномер: ${widget.vehicle.licensePlate}'),
                          const SizedBox(height: 8),
                          Text('Модель: ${widget.vehicle.model ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text('Тип: ${widget.vehicle.vehicleType ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _daysController,
                    decoration: const InputDecoration(
                      labelText: 'Срок аренды (дней) *',
                      border: OutlineInputBorder(),
                      helperText: 'Минимум 1 день, максимум 365 дней',
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
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onClose,
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleSubmit,
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
}


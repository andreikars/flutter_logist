import 'package:flutter/material.dart';
import '../../../models/payment.dart';
import '../../../models/declaration.dart';
import '../../../models/user.dart';

class PaymentForm extends StatefulWidget {
  final Payment? payment;
  final int? clientId;
  final List<Declaration> declarations;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;
  final bool isAdmin;
  final List<User>? allUsers;
  final Function(int, String)? onStatusChange;

  const PaymentForm({
    super.key,
    this.payment,
    this.clientId,
    required this.declarations,
    required this.onSave,
    required this.onCancel,
    this.isAdmin = false,
    this.allUsers,
    this.onStatusChange,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedClientId;
  int? _selectedDeclarationId;
  late TextEditingController _amountController;
  late String _currency;
  late TextEditingController _paymentTypeController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.payment?.clientId ?? widget.clientId;
    // Проверяем, что declarationId существует в списке деклараций
    final paymentDeclarationId = widget.payment?.declarationId;
    if (paymentDeclarationId != null) {
      final exists = widget.declarations.any((decl) => decl.id == paymentDeclarationId);
      _selectedDeclarationId = exists ? paymentDeclarationId : null;
    } else {
      _selectedDeclarationId = null;
    }
    _amountController = TextEditingController(text: widget.payment?.amount.toString() ?? '');
    _currency = widget.payment?.currency ?? 'BYN';
    _paymentTypeController = TextEditingController(text: widget.payment?.paymentType ?? '');
    _dueDate = widget.payment?.dueDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final paymentData = {
      'clientId': widget.isAdmin ? _selectedClientId : widget.clientId,
      'amount': double.tryParse(_amountController.text) ?? 0,
      'currency': _currency,
    };

    if (_selectedDeclarationId != null) {
      paymentData['declarationId'] = _selectedDeclarationId;
    }
    if (_paymentTypeController.text.isNotEmpty) {
      paymentData['paymentType'] = _paymentTypeController.text.trim();
    }
    if (_dueDate != null) {
      paymentData['dueDate'] = _dueDate!.toIso8601String().split('T')[0];
    }

    widget.onSave(paymentData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.payment == null ? 'Добавить платеж' : 'Редактировать платеж',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  if (widget.isAdmin && widget.allUsers != null) ...[
                    DropdownButtonFormField<int?>(
                      value: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Клиент *',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.allUsers!
                          .fold<Map<int?, User>>({}, (map, user) {
                            if (user.id != null && !map.containsKey(user.id)) {
                              map[user.id] = user;
                            }
                            return map;
                          })
                          .values
                          .map((user) => DropdownMenuItem<int?>(
                                value: user.id,
                                child: Text('${user.name ?? user.username} (${user.email ?? ''})'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClientId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Выберите клиента';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<int?>(
                    value: _selectedDeclarationId,
                    decoration: const InputDecoration(
                      labelText: 'Декларация',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Не выбрано')),
                      // Убираем дубликаты по id
                      ...widget.declarations
                          .fold<Map<int?, Declaration>>({}, (map, decl) {
                            if (decl.id != null && !map.containsKey(decl.id)) {
                              map[decl.id] = decl;
                            }
                            return map;
                          })
                          .values
                          .map((decl) => DropdownMenuItem<int?>(
                                value: decl.id,
                                child: Text(decl.declarationNumber),
                              )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDeclarationId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Сумма *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите сумму';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Введите число';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: const InputDecoration(
                            labelText: 'Валюта',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'BYN', child: Text('BYN')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                            DropdownMenuItem(value: 'RUB', child: Text('RUB')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _currency = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Тип платежа',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Срок оплаты',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'
                            : 'Выберите дату',
                      ),
                    ),
                  ),
                  if (widget.isAdmin && widget.payment != null && widget.onStatusChange != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Текущий статус: ${widget.payment!.status}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (widget.payment!.status == 'PENDING')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                widget.onStatusChange!(widget.payment!.id!, 'PAID');
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Оплачено'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                widget.onStatusChange!(widget.payment!.id!, 'OVERDUE');
                              },
                              icon: const Icon(Icons.warning),
                              label: const Text('Просрочено'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onCancel,
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleSave,
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


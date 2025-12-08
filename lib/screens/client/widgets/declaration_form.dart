import 'package:flutter/material.dart';
import '../../../models/declaration.dart';
import '../../../models/user.dart';

class DeclarationForm extends StatefulWidget {
  final Declaration? declaration;
  final int? clientId;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;
  final bool isAdmin;
  final List<User>? allUsers;

  const DeclarationForm({
    super.key,
    this.declaration,
    this.clientId,
    required this.onSave,
    required this.onCancel,
    this.isAdmin = false,
    this.allUsers,
  });

  @override
  State<DeclarationForm> createState() => _DeclarationFormState();
}

class _DeclarationFormState extends State<DeclarationForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedClientId;
  late TextEditingController _declarationTypeController;
  late TextEditingController _tnvedCodeController;
  late TextEditingController _productDescriptionController;
  late TextEditingController _productValueController;
  late TextEditingController _netWeightController;
  late TextEditingController _quantityController;
  late TextEditingController _countryOfOriginController;
  late TextEditingController _countryOfDestinationController;
  late TextEditingController _customsOfficeController;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.declaration?.clientId ?? widget.clientId;
    _declarationTypeController = TextEditingController(text: widget.declaration?.declarationType ?? '');
    _tnvedCodeController = TextEditingController(text: widget.declaration?.tnvedCode ?? '');
    _productDescriptionController = TextEditingController(text: widget.declaration?.productDescription ?? '');
    _productValueController = TextEditingController(text: widget.declaration?.productValue.toString() ?? '');
    _netWeightController = TextEditingController(text: widget.declaration?.netWeight?.toString() ?? '');
    _quantityController = TextEditingController(text: widget.declaration?.quantity?.toString() ?? '');
    _countryOfOriginController = TextEditingController(text: widget.declaration?.countryOfOrigin ?? '');
    _countryOfDestinationController = TextEditingController(text: widget.declaration?.countryOfDestination ?? '');
    _customsOfficeController = TextEditingController(text: widget.declaration?.customsOffice ?? '');
  }

  @override
  void dispose() {
    _declarationTypeController.dispose();
    _tnvedCodeController.dispose();
    _productDescriptionController.dispose();
    _productValueController.dispose();
    _netWeightController.dispose();
    _quantityController.dispose();
    _countryOfOriginController.dispose();
    _countryOfDestinationController.dispose();
    _customsOfficeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final declarationData = {
      'clientId': widget.isAdmin ? _selectedClientId : widget.clientId,
      'declarationType': _declarationTypeController.text.trim(),
      'productDescription': _productDescriptionController.text.trim(),
      'productValue': double.tryParse(_productValueController.text) ?? 0,
    };

    if (_tnvedCodeController.text.isNotEmpty) {
      declarationData['tnvedCode'] = _tnvedCodeController.text.trim();
    }
    if (_netWeightController.text.isNotEmpty) {
      declarationData['netWeight'] = double.tryParse(_netWeightController.text);
    }
    if (_quantityController.text.isNotEmpty) {
      declarationData['quantity'] = int.tryParse(_quantityController.text);
    }
    if (_countryOfOriginController.text.isNotEmpty) {
      declarationData['countryOfOrigin'] = _countryOfOriginController.text.trim();
    }
    if (_countryOfDestinationController.text.isNotEmpty) {
      declarationData['countryOfDestination'] = _countryOfDestinationController.text.trim();
    }
    if (_customsOfficeController.text.isNotEmpty) {
      declarationData['customsOffice'] = _customsOfficeController.text.trim();
    }

    widget.onSave(declarationData);
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
                    widget.declaration == null ? 'Добавить декларацию' : 'Редактировать декларацию',
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
                  TextFormField(
                    controller: _declarationTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Тип декларации *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите тип декларации';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tnvedCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Код ТН ВЭД',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _productDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание товара *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите описание товара';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _productValueController,
                          decoration: const InputDecoration(
                            labelText: 'Стоимость товара *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите стоимость';
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
                        child: TextFormField(
                          controller: _netWeightController,
                          decoration: const InputDecoration(
                            labelText: 'Чистый вес',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Количество',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _countryOfOriginController,
                          decoration: const InputDecoration(
                            labelText: 'Страна происхождения',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _countryOfDestinationController,
                          decoration: const InputDecoration(
                            labelText: 'Страна назначения',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _customsOfficeController,
                    decoration: const InputDecoration(
                      labelText: 'Таможенный пост',
                      border: OutlineInputBorder(),
                    ),
                  ),
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


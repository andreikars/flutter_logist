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
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 700),
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
                    widget.declaration == null ? 'Добавить декларацию' : 'Редактировать декларацию',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (widget.isAdmin && widget.allUsers != null) ...[
                    DropdownButtonFormField<int?>(
                      value: _selectedClientId,
                      dropdownColor: const Color(0xFF2d2d2d),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Клиент *',
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
                          Icons.person,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      items: widget.allUsers!
                          .map((user) => DropdownMenuItem<int?>(
                                value: user.id,
                                child: Text(
                                  '${user.name ?? user.username} (${user.email ?? ''})',
                                  style: const TextStyle(color: Colors.white),
                                ),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Тип декларации *',
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
                        Icons.description,
                        color: Colors.white.withOpacity(0.7),
                      ),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Код ТН ВЭД',
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
                        Icons.code,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _productDescriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Описание товара *',
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
                        Icons.shopping_bag,
                        color: Colors.white.withOpacity(0.7),
                      ),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Стоимость товара *',
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
                              Icons.attach_money,
                              color: Colors.white.withOpacity(0.7),
                            ),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _netWeightController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Чистый вес',
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
                              Icons.scale,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Количество',
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
                              Icons.format_list_numbered,
                              color: Colors.white.withOpacity(0.7),
                            ),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Страна происхождения',
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
                              Icons.flag,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _countryOfDestinationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Страна назначения',
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
                              Icons.public,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _customsOfficeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Таможенный пост',
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
                        Icons.account_balance,
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
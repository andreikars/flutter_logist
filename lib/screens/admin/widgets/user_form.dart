import 'package:flutter/material.dart';
import '../../../models/user.dart';

class UserForm extends StatefulWidget {
  final User? user;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const UserForm({
    super.key,
    this.user,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late String _role;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _unpController;
  late TextEditingController _activityTypeController;

  @override
  void initState() {
    super.initState();
    _role = widget.user?.role ?? 'CLIENT';
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _unpController = TextEditingController(text: widget.user?.unp ?? '');
    _activityTypeController = TextEditingController(text: widget.user?.activityType ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _unpController.dispose();
    _activityTypeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userData = {
      'username': _usernameController.text.trim(),
      'role': _role,
    };

    if (_passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    if (_role == 'CLIENT' || _role == 'ADMIN') {
      userData['name'] = _nameController.text.trim();
      userData['email'] = _emailController.text.trim();
      userData['unp'] = _unpController.text.trim();
      userData['activityType'] = _activityTypeController.text.trim();
    }

    widget.onSave(userData);
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
                    widget.user == null ? 'Добавить пользователя' : 'Редактировать пользователя',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: 'Роль *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'CLIENT', child: Text('Клиент')),
                      DropdownMenuItem(value: 'DRIVER', child: Text('Водитель')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Админ')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Логин *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите логин';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: widget.user == null
                          ? 'Пароль *'
                          : 'Пароль (оставьте пустым, чтобы не менять)',
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (widget.user == null && (value == null || value.isEmpty)) {
                        return 'Введите пароль';
                      }
                      return null;
                    },
                  ),
                  if (_role == 'CLIENT' || _role == 'ADMIN') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unpController,
                      decoration: const InputDecoration(
                        labelText: 'УНП',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _activityTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Тип деятельности',
                        border: OutlineInputBorder(),
                      ),
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


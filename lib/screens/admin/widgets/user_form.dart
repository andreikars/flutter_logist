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
                    widget.user == null ? 'Добавить пользователя' : 'Редактировать пользователя',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _role,
                    dropdownColor: const Color(0xFF2d2d2d),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Роль *',
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
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'CLIENT',
                        child: Text('Клиент', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'DRIVER',
                        child: Text('Водитель', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'ADMIN',
                        child: Text('Админ', style: TextStyle(color: Colors.white)),
                      ),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Логин *',
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: widget.user == null
                          ? 'Пароль *'
                          : 'Пароль (оставьте пустым, чтобы не менять)',
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
                        Icons.lock,
                        color: Colors.white.withOpacity(0.7),
                      ),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Имя',
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
                          Icons.person_outline,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
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
                          Icons.email,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unpController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'УНП',
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
                          Icons.badge,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _activityTypeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Тип деятельности',
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
                          Icons.work,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
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
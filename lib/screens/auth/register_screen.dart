import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _unpController = TextEditingController();
  final _emailController = TextEditingController();
  final _activityTypeController = TextEditingController();
  
  String _role = 'CLIENT';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _unpController.dispose();
    _emailController.dispose();
    _activityTypeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final userData = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'role': _role,
    };

    if (_role == 'CLIENT') {
      userData['name'] = _nameController.text.trim();
      userData['unp'] = _unpController.text.trim();
      userData['email'] = _emailController.text.trim();
      userData['activityType'] = _activityTypeController.text.trim();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.register(userData);

    setState(() {
      _loading = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Регистрация успешна! Войдите в систему.'),
          backgroundColor: const Color(0xFF28a745),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      setState(() {
        _error = result['error'] ?? 'Ошибка регистрации';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Регистрация',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1e1e1e),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF121212),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3a1f1f),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFff6b6b)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: const Color(0xFFff6b6b),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Color(0xFFff6b6b)),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    labelText: 'Пароль *',
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
                    if (value == null || value.isEmpty) {
                      return 'Введите пароль';
                    }
                    return null;
                  },
                ),
                if (_role == 'CLIENT') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Имя *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите имя';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unpController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'УНП *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите УНП';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      }
                      if (!value.contains('@')) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _activityTypeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Тип деятельности *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите тип деятельности';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8a2be2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF8a2be2).withOpacity(0.4),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8a2be2),
                  ),
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
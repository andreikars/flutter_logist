import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'register_screen.dart';
import '../admin/admin_dashboard.dart';
import '../client/client_dashboard.dart';
import '../driver/driver_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ipController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _loading = false;
  bool _showIpField = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('backend_ip');
    if (savedIp != null && savedIp.isNotEmpty) {
      setState(() {
        _ipController.text = savedIp;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _saveIp() async {
    if (_ipController.text.trim().isNotEmpty) {
      await _apiService.updateBaseUrl(_ipController.text.trim());
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_ipController.text.trim().isNotEmpty) {
      await _saveIp();
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _loading = false;
    });

    if (!mounted) return;

    if (result['success']) {
      final user = result['user'] as dynamic;
      if (user.role == 'ADMIN') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (user.role == 'CLIENT') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ClientDashboard()),
        );
      } else if (user.role == 'DRIVER') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DriverDashboard()),
        );
      }
    } else {
      setState(() {
        _error = result['error'] ?? 'Неверные учетные данные';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color(0xFF1e1e1e),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Вход в систему',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3a1f1f),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFff6b6b),
                            ),
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
                                  style: const TextStyle(
                                    color: Color(0xFFff6b6b),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Логин',
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
                          labelText: 'Пароль',
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showIpField = !_showIpField;
                                });
                              },
                              icon: Icon(
                                _showIpField
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 18,
                                color: const Color(0xFF8a2be2),
                              ),
                              label: Text(
                                _showIpField
                                    ? 'Скрыть настройки'
                                    : 'Настройки сервера',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8a2be2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showIpField) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _ipController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'IP адрес бэкенда',
                            labelStyle: const TextStyle(color: Color(0xFFb0b0b0)),
                            hintText: '10.0.2.2:8080 или 192.168.1.100:8080',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
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
                              Icons.dns,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            helperText:
                                'Оставьте пустым для использования значения по умолчанию',
                            helperStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          keyboardType: TextInputType.url,
                          onChanged: (value) async {
                            if (value.trim().isNotEmpty) {
                              await _saveIp();
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
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
                                'Войти',
                                style: TextStyle(
                                  color:  Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8a2be2),
                        ),
                        child: const Text('Нет аккаунта? Зарегистрироваться'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../auth/login_screen.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final ApiService _apiService = ApiService();
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _unpController;
  late TextEditingController _activityTypeController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.name ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _unpController = TextEditingController(text: user.unp ?? '');
    _activityTypeController = TextEditingController(text: user.activityType ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _unpController.dispose();
    _activityTypeController.dispose();
    super.dispose();
  }

  Future<void> _addActivity(String description) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;
    try {
      await _apiService.createActivityForUser(user.username, description);
    } catch (e) {
      // Игнорируем ошибки активности
    }
  }

  Future<void> _handleSave() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    try {
      final updateData = {
        'username': user.username,
        'role': user.role,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'unp': _unpController.text.trim(),
        'activityType': _activityTypeController.text.trim(),
      };

      final updated = await _apiService.updateUser(user.id!, updateData);
      authProvider.updateUser(updated);
      await _addActivity('Профиль обновлен');
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Профиль обновлен'),
            backgroundColor: const Color(0xFF28a745),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: ${e.toString()}'),
            backgroundColor: const Color(0xFFf56565),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Подтверждение',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы уверены, что хотите удалить свой аккаунт? Это действие необратимо.',
          style: TextStyle(color: Color(0xFFb0b0b0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFb0b0b0),
            ),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFf56565),
            ),
            child: const Text('Удалить'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF404040)),
        ),
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user!;
      try {
        await _apiService.deleteUser(user.id!);
        await authProvider.logout();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: ${e.toString()}'),
              backgroundColor: const Color(0xFFf56565),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Container(
      color: const Color(0xFF121212),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isEditing)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8a2be2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF8a2be2).withOpacity(0.4),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Редактировать'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Удалить аккаунт'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf56565),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFf56565).withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isEditing) ...[
              TextField(
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
                    Icons.person,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
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
              TextField(
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
              TextField(
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = user.name ?? '';
                        _emailController.text = user.email ?? '';
                        _unpController.text = user.unp ?? '';
                        _activityTypeController.text = user.activityType ?? '';
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFb0b0b0),
                      backgroundColor: const Color(0xFF2d2d2d),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF404040).withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Имя', user.name ?? 'N/A'),
                      _buildDetailRow('Логин', user.username),
                      _buildDetailRow('Email', user.email ?? 'N/A'),
                      _buildDetailRow('УНП', user.unp ?? 'N/A'),
                      _buildDetailRow('Тип деятельности', user.activityType ?? 'N/A'),
                      _buildDetailRow('Роль', user.role),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF8a2be2),
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
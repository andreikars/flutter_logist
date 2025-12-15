import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../widgets/user_form.dart';
import '../widgets/user_list.dart';

class UsersSection extends StatefulWidget {
  const UsersSection({super.key});

  @override
  State<UsersSection> createState() => _UsersSectionState();
}

class _UsersSectionState extends State<UsersSection> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _loading = true;
  User? _editingUser;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
    });
    try {
      final users = await _apiService.getAllUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
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

  void _handleAdd() {
    setState(() {
      _editingUser = null;
      _showForm = true;
    });
  }

  void _handleEdit(User user) {
    setState(() {
      _editingUser = user;
      _showForm = true;
    });
  }

  void _handleCloseForm() {
    setState(() {
      _showForm = false;
      _editingUser = null;
    });
  }

  Future<void> _handleSave(Map<String, dynamic> userData) async {
    try {
      if (_editingUser != null) {
        await _apiService.updateUser(_editingUser!.id!, userData);
      } else {
        await _apiService.createUser(userData);
      }
      _handleCloseForm();
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пользователь сохранен'),
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
            content: Text('Ошибка сохранения: ${e.toString()}'),
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

  Future<void> _handleDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Подтверждение',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы уверены, что хотите удалить этого пользователя?',
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
      try {
        await _apiService.deleteUser(id);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Пользователь удален'),
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
    return Stack(
      children: [
        Container(
          color: const Color(0xFF121212),
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8a2be2),
                  ),
                )
              : UserList(
                  users: _users,
                  onEdit: _handleEdit,
                  onDelete: _handleDelete,
                ),
        ),
        if (!_loading && !_showForm)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8a2be2).withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _handleAdd,
                backgroundColor: const Color(0xFF8a2be2),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Добавить пользователя'),
              ),
            ),
          ),
        if (_showForm)
          UserForm(
            user: _editingUser,
            onSave: _handleSave,
            onCancel: _handleCloseForm,
          ),
      ],
    );
  }
}
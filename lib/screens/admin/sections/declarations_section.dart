import 'package:flutter/material.dart';
import '../../../models/declaration.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../client/widgets/declaration_form.dart';
import '../../client/widgets/declaration_list.dart';

class DeclarationsSection extends StatefulWidget {
  const DeclarationsSection({super.key});

  @override
  State<DeclarationsSection> createState() => _DeclarationsSectionState();
}

class _DeclarationsSectionState extends State<DeclarationsSection> {
  final ApiService _apiService = ApiService();
  List<Declaration> _declarations = [];
  List<User> _allUsers = [];
  bool _loading = true;
  Declaration? _editingDeclaration;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    try {
      final results = await Future.wait([
        _apiService.getAllDeclarations(),
        _apiService.getAllUsers(),
      ]);
      setState(() {
        _declarations = results[0] as List<Declaration>;
        final users = results[1] as List<User>;
        _allUsers = users.where((u) => u.role == 'CLIENT').toList();
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
      _editingDeclaration = null;
      _showForm = true;
    });
  }

  void _handleEdit(Declaration declaration) {
    setState(() {
      _editingDeclaration = declaration;
      _showForm = true;
    });
  }

  void _handleCloseForm() {
    setState(() {
      _showForm = false;
      _editingDeclaration = null;
    });
  }

  Future<void> _handleSave(Map<String, dynamic> declarationData) async {
    try {
      if (_editingDeclaration != null) {
        await _apiService.updateDeclaration(_editingDeclaration!.id!, declarationData);
      } else {
        await _apiService.createDeclaration(declarationData);
      }
      _handleCloseForm();
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Декларация сохранена'),
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
          'Вы уверены, что хотите удалить эту декларацию?',
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
        await _apiService.deleteDeclaration(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Декларация удалена'),
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

  Future<void> _handleApprove(int id) async {
    try {
      await _apiService.updateDeclarationStatus(id, 'APPROVED');
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Декларация одобрена'),
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
            content: Text('Ошибка: ${e.toString()}'),
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

  Future<void> _handleReject(int id) async {
    try {
      await _apiService.updateDeclarationStatus(id, 'REJECTED');
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Декларация отклонена'),
            backgroundColor: const Color(0xFFf56565),
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
            content: Text('Ошибка: ${e.toString()}'),
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
              : DeclarationList(
                  declarations: _declarations,
                  onEdit: _handleEdit,
                  onDelete: _handleDelete,
                  onApprove: _handleApprove,
                  onReject: _handleReject,
                  isAdmin: true,
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
                label: const Text('Добавить декларацию'),
              ),
            ),
          ),
        if (_showForm)
          DeclarationForm(
            declaration: _editingDeclaration,
            clientId: _editingDeclaration?.clientId,
            onSave: _handleSave,
            onCancel: _handleCloseForm,
            isAdmin: true,
            allUsers: _allUsers,
          ),
      ],
    );
  }
}
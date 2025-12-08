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
          SnackBar(content: Text('Ошибка загрузки: ${e.toString()}')),
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
          const SnackBar(content: Text('Декларация сохранена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы уверены, что хотите удалить эту декларацию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteDeclaration(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Декларация удалена')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: ${e.toString()}')),
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
          const SnackBar(content: Text('Декларация одобрена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
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
          const SnackBar(content: Text('Декларация отклонена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _loading
            ? const Center(child: CircularProgressIndicator())
            : DeclarationList(
                declarations: _declarations,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
                onApprove: _handleApprove,
                onReject: _handleReject,
                isAdmin: true,
              ),
        if (!_loading && !_showForm)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить декларацию'),
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


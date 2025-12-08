import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/declaration.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../widgets/declaration_form.dart';
import '../widgets/declaration_list.dart';

class DeclarationsSection extends StatefulWidget {
  const DeclarationsSection({super.key});

  @override
  State<DeclarationsSection> createState() => _DeclarationsSectionState();
}

class _DeclarationsSectionState extends State<DeclarationsSection> {
  final ApiService _apiService = ApiService();
  List<Declaration> _declarations = [];
  bool _loading = true;
  Declaration? _editingDeclaration;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadDeclarations();
  }

  Future<void> _loadDeclarations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    setState(() {
      _loading = true;
    });
    try {
      final declarations = await _apiService.getDeclarationsByClient(user.id!);
      setState(() {
        _declarations = declarations;
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

  Future<void> _addActivity(String description) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;
    try {
      await _apiService.createActivityForUser(user.username, description);
    } catch (e) {
      // Игнорируем ошибки активности
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
        await _addActivity('Декларация #${_editingDeclaration!.declarationNumber} обновлена');
      } else {
        await _apiService.createDeclaration(declarationData);
        await _addActivity('Декларация добавлена');
      }
      _handleCloseForm();
      _loadDeclarations();
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
        await _addActivity('Декларация удалена');
        _loadDeclarations();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    return Stack(
      children: [
        _loading
            ? const Center(child: CircularProgressIndicator())
            : DeclarationList(
                declarations: _declarations,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
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
            clientId: user.id,
            onSave: _handleSave,
            onCancel: _handleCloseForm,
          ),
      ],
    );
  }
}


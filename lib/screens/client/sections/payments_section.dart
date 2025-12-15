import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/payment.dart';
import '../../../models/declaration.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../widgets/payment_form.dart';
import '../widgets/payment_list.dart';

class PaymentsSection extends StatefulWidget {
  const PaymentsSection({super.key});

  @override
  State<PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends State<PaymentsSection> {
  final ApiService _apiService = ApiService();
  List<Payment> _payments = [];
  List<Declaration> _declarations = [];
  bool _loading = true;
  Payment? _editingPayment;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    setState(() {
      _loading = true;
    });
    try {
      final results = await Future.wait([
        _apiService.getPaymentsByClient(user.id!),
        _apiService.getDeclarationsByClient(user.id!),
      ]);
      setState(() {
        _payments = results[0] as List<Payment>;
        _declarations = results[1] as List<Declaration>;
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
      _editingPayment = null;
      _showForm = true;
    });
  }

  void _handleEdit(Payment payment) {
    setState(() {
      _editingPayment = payment;
      _showForm = true;
    });
  }

  void _handleCloseForm() {
    setState(() {
      _showForm = false;
      _editingPayment = null;
    });
  }

  Future<void> _handleSave(Map<String, dynamic> paymentData) async {
    try {
      if (_editingPayment != null) {
        await _apiService.updatePayment(_editingPayment!.id!, paymentData);
        await _addActivity('Платеж #${_editingPayment!.paymentNumber} обновлен');
      } else {
        await _apiService.createPayment(paymentData);
        await _addActivity('Платеж добавлен');
      }
      _handleCloseForm();
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Платеж сохранен'),
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
          'Вы уверены, что хотите удалить этот платеж?',
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
        await _apiService.deletePayment(id);
        await _addActivity('Платеж удален');
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Платеж удален'),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

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
              : PaymentList(
                  payments: _payments,
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
                label: const Text('Добавить платеж'),
              ),
            ),
          ),
        if (_showForm)
          PaymentForm(
            payment: _editingPayment,
            clientId: user.id,
            declarations: _declarations,
            onSave: _handleSave,
            onCancel: _handleCloseForm,
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../models/payment.dart';
import '../../../models/user.dart';
import '../../../models/declaration.dart';
import '../../../services/api_service.dart';
import '../../client/widgets/payment_form.dart';
import '../../client/widgets/payment_list.dart';

class PaymentsSection extends StatefulWidget {
  const PaymentsSection({super.key});

  @override
  State<PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends State<PaymentsSection> {
  final ApiService _apiService = ApiService();
  List<Payment> _payments = [];
  List<User> _allUsers = [];
  List<Declaration> _allDeclarations = [];
  bool _loading = true;
  Payment? _editingPayment;
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
        _apiService.getAllPayments(),
        _apiService.getAllUsers(),
        _apiService.getAllDeclarations(),
      ]);
      setState(() {
        _payments = results[0] as List<Payment>;
        final users = results[1] as List<User>;
        _allUsers = users.where((u) => u.role == 'CLIENT').toList();
        _allDeclarations = results[2] as List<Declaration>;
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
      } else {
        await _apiService.createPayment(paymentData);
      }
      _handleCloseForm();
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Платеж сохранен')),
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
        content: const Text('Вы уверены, что хотите удалить этот платеж?'),
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
        await _apiService.deletePayment(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Платеж удален')),
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

  Future<void> _handleStatusChange(int id, String status) async {
    try {
      await _apiService.updatePaymentStatus(id, status);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Статус платежа обновлен')),
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
            : PaymentList(
                payments: _payments,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
                onStatusChange: _handleStatusChange,
                isAdmin: true,
              ),
        if (!_loading && !_showForm)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить платеж'),
            ),
          ),
        if (_showForm)
          PaymentForm(
            payment: _editingPayment,
            clientId: _editingPayment?.clientId,
            declarations: _allDeclarations,
            onSave: _handleSave,
            onCancel: _handleCloseForm,
            isAdmin: true,
            allUsers: _allUsers,
            onStatusChange: _handleStatusChange,
          ),
      ],
    );
  }
}


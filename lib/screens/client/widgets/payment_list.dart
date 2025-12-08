import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/payment.dart';

class PaymentList extends StatelessWidget {
  final List<Payment> payments;
  final Function(Payment)? onEdit;
  final Function(int)? onDelete;
  final Function(int, String)? onStatusChange;
  final bool isAdmin;

  const PaymentList({
    super.key,
    required this.payments,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
    this.isAdmin = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Center(child: Text('Нет платежей'));
    }

    final dateFormat = DateFormat('dd.MM.yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text('Платеж #${payment.paymentNumber}'),
            subtitle: Text(
              '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      final canEdit = onEdit != null && payment.status != 'PAID';
                      return [
                        if (canEdit)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Редактировать'),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Удалить'),
                          ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!(payment);
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!(payment.id!);
                      }
                    },
                  ),
                ],
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Клиент', payment.clientName ?? payment.clientId.toString()),
                    if (payment.declarationNumber != null)
                      _buildDetailRow('Декларация', payment.declarationNumber!),
                    if (payment.paymentType != null)
                      _buildDetailRow('Тип', payment.paymentType!),
                    if (payment.dueDate != null)
                      _buildDetailRow('Срок оплаты', dateFormat.format(payment.dueDate!)),
                    if (payment.createdAt != null)
                      _buildDetailRow('Дата создания', dateFormat.format(payment.createdAt!)),
                    if (isAdmin && onStatusChange != null && payment.status == 'PENDING') ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => onStatusChange!(payment.id!, 'PAID'),
                        icon: const Icon(Icons.check),
                        label: const Text('Отметить как оплаченный'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}


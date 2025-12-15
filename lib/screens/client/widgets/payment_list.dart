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
        return const Color(0xFF28a745); // Зеленый
      case 'OVERDUE':
        return const Color(0xFFf56565); // Красный
      case 'PENDING':
        return const Color(0xFFffc107); // Оранжевый
      default:
        return const Color(0xFF6c757d); // Серый
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return const Color(0xFFd4edda); // Светло-зеленый
      case 'OVERDUE':
        return const Color(0xFFf8d7da); // Светло-красный
      case 'PENDING':
        return const Color(0xFFfff3cd); // Светло-оранжевый
      default:
        return const Color(0xFFe2e3e5); // Светло-серый
    }
  }

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Нет платежей',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAdmin 
                  ? 'Создайте первый платеж' 
                  : 'Добавьте первый платеж',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd.MM.yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF404040).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2d2d2d),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF404040)),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: const Color(0xFF8a2be2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Платеж #${payment.paymentNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(payment.status),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getStatusColor(payment.status).withOpacity(0.3)),
                ),
                child: Text(
                  payment.status,
                  style: TextStyle(
                    color: _getStatusColor(payment.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null || onDelete != null)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d2d),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF404040)),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20, color: Colors.white),
                      color: const Color(0xFF2d2d2d),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF404040)),
                      ),
                      itemBuilder: (context) {
                        final canEdit = onEdit != null && payment.status != 'PAID';
                        return [
                          if (canEdit)
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: const Color(0xFF8a2be2),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Редактировать',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: const Color(0xFFf56565),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Удалить',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
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
                  ),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2d2d2d).withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e1e1e),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF404040)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => onStatusChange!(payment.id!, 'PAID'),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Отметить как оплаченный'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF28a745),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF8a2be2),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/declaration.dart';

class DeclarationList extends StatelessWidget {
  final List<Declaration> declarations;
  final Function(Declaration)? onEdit;
  final Function(int)? onDelete;
  final Function(int)? onApprove;
  final Function(int)? onReject;
  final bool isAdmin;

  const DeclarationList({
    super.key,
    required this.declarations,
    this.onEdit,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.isAdmin = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'UNDER_REVIEW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (declarations.isEmpty) {
      return const Center(child: Text('Нет деклараций'));
    }

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: declarations.length,
      itemBuilder: (context, index) {
        final declaration = declarations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text('Декларация #${declaration.declarationNumber}'),
            subtitle: Text(
              '${declaration.declarationType} • ${declaration.productValue.toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(declaration.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    declaration.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      final canEdit = onEdit != null &&
                          declaration.status != 'APPROVED' &&
                          declaration.status != 'REJECTED';
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
                        onEdit!(declaration);
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!(declaration.id!);
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
                    _buildDetailRow('Клиент', declaration.clientName ?? declaration.clientId.toString()),
                    _buildDetailRow('Описание', declaration.productDescription),
                    if (declaration.tnvedCode != null)
                      _buildDetailRow('Код ТН ВЭД', declaration.tnvedCode!),
                    if (declaration.netWeight != null)
                      _buildDetailRow('Вес', declaration.netWeight!.toString()),
                    if (declaration.quantity != null)
                      _buildDetailRow('Количество', declaration.quantity!.toString()),
                    if (declaration.createdAt != null)
                      _buildDetailRow('Дата создания', dateFormat.format(declaration.createdAt!)),
                    if (isAdmin &&
                        (declaration.status == 'PENDING' ||
                            declaration.status == 'UNDER_REVIEW')) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (onApprove != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => onApprove!(declaration.id!),
                                icon: const Icon(Icons.check),
                                label: const Text('Одобрить'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          if (onApprove != null && onReject != null)
                            const SizedBox(width: 8),
                          if (onReject != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => onReject!(declaration.id!),
                                icon: const Icon(Icons.close),
                                label: const Text('Отклонить'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
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


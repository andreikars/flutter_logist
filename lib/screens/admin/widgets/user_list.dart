import 'package:flutter/material.dart';
import '../../../models/user.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final Function(User) onEdit;
  final Function(int) onDelete;

  const UserList({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Нет пользователей'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(user.name ?? user.username),
            subtitle: Text('${user.username} • ${user.role}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(user.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


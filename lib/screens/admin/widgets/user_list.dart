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
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Нет пользователей',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Добавьте первого пользователя',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              user.name ?? user.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        color: const Color(0xFFb0b0b0),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (user.email != null && user.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.email!,
                        style: TextStyle(
                          color: const Color(0xFFb0b0b0),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2d2d2d),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF404040)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: const Color(0xFF8a2be2),
                    onPressed: () => onEdit(user),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3a1f1f),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFff6b6b).withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: const Color(0xFFff6b6b),
                    onPressed: () => onDelete(user.id!),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return const Color(0xFF8a2be2);
      case 'CLIENT':
        return const Color(0xFF0d6efd);
      case 'DRIVER':
        return const Color(0xFF20c997);
      default:
        return const Color(0xFF6c757d);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'sections/declarations_section.dart';
import 'sections/payments_section.dart';
import 'sections/profile_section.dart';
import '../auth/login_screen.dart';
import '../client/activity_log.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DeclarationsSection(),
    const PaymentsSection(),
    const ProfileSection(),
  ];

  // Пример данных активности
  final List<ActivityItem> _activityItems = [
    ActivityItem(
      id: '1',
      description: 'Вход в систему выполнен',
      date: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ActivityItem(
      id: '2',
      description: 'Просмотрена декларация №12345',
      date: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ActivityItem(
      id: '3',
      description: 'Создан новый платеж на сумму 1500 руб.',
      date: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ActivityItem(
      id: '4',
      description: 'Обновлен профиль пользователя',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ActivityItem(
      id: '5',
      description: 'Загружен документ "Договор_аренды.pdf"',
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ActivityItem(
      id: '6',
      description: 'Отправлен запрос в поддержку',
      date: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Показать диалог подтверждения
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Выход',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF8a2be2)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8a2be2),
            ),
            child: const Text(
              'Выйти',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1e1e1e),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0d6efd),
                    Color(0xFF8a2be2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0d6efd).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.business_center, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Клиент',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Прямая кнопка выхода (без меню)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Выйти',
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF404040)),
            ),
            child: Row(
              children: [
                Icon(Icons.person, size: 18, color: const Color(0xFFb0b0b0)),
                const SizedBox(width: 6),
                Text(
                  user.name ?? user.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Основной контент
          Expanded(
            child: Container(
              color: const Color(0xFF121212),
              child: _screens[_selectedIndex],
            ),
          ),

          // Лог активности
          ActivityLog(
            activities: _activityItems,
            isExpanded: true,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1e1e1e),
          border: Border(
            top: BorderSide(color: const Color(0xFF404040).withOpacity(0.3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1e1e1e),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF8a2be2),
          unselectedItemColor: const Color(0xFFb0b0b0),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Декларации',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              activeIcon: Icon(Icons.payment),
              label: 'Платежи',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
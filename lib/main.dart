import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/client_dashboard.dart';
import 'screens/driver/driver_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Logistics App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/admin': (context) => const AdminDashboard(),
          '/client': (context) => const ClientDashboard(),
          '/driver': (context) => const DriverDashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final user = authProvider.user!;
    if (user.role == 'ADMIN') {
      return const AdminDashboard();
    } else if (user.role == 'CLIENT') {
      return const ClientDashboard();
    } else if (user.role == 'DRIVER') {
      return const DriverDashboard();
    }

    return const LoginScreen();
  }
}

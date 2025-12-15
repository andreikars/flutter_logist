import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/vehicle.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../widgets/rent_modal.dart';
import '../widgets/vehicle_list.dart';

class VehiclesSection extends StatefulWidget {
  final String initialTab;

  const VehiclesSection({
    super.key,
    this.initialTab = 'rented',
  });

  @override
  State<VehiclesSection> createState() => _VehiclesSectionState();
}

class _VehiclesSectionState extends State<VehiclesSection> {
  final ApiService _apiService = ApiService();
  List<Vehicle> _vehicles = [];
  bool _loading = true;
  late String _activeTab;
  Vehicle? _rentingVehicle;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _loadVehicles();
  }

  @override
  void didUpdateWidget(VehiclesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _activeTab = widget.initialTab;
      });
      _loadVehicles();
    }
  }

  Future<void> _loadVehicles() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    setState(() {
      _loading = true;
    });
    try {
      List<Vehicle> vehicles;
      if (_activeTab == 'available') {
        vehicles = await _apiService.getAvailableVehicles();
      } else {
        vehicles = await _apiService.getRentedVehiclesByDriver(user.id!);
      }
      setState(() {
        _vehicles = vehicles;
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

  void _handleRentClick(Vehicle vehicle) {
    setState(() {
      _rentingVehicle = vehicle;
    });
  }

  void _handleRentCancel() {
    setState(() {
      _rentingVehicle = null;
    });
  }

  Future<void> _handleRentConfirm(int days) async {
    if (_rentingVehicle == null) return;

    try {
      await _apiService.rentVehicle(_rentingVehicle!.id!, days);
      setState(() {
        _rentingVehicle = null;
      });
      _loadVehicles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Машина успешно арендована на $days ${_getDaysText(days)}!'),
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
            content: Text('Ошибка аренды: ${e.toString()}'),
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

  String _getDaysText(int days) {
    if (days == 1) return 'день';
    if (days < 5) return 'дня';
    return 'дней';
  }

  Future<void> _handleReturn(int vehicleId) async {
    final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);
    final isEarlyReturn = vehicle.rentalEndDate != null &&
        vehicle.rentalEndDate!.isAfter(DateTime.now());

    String message;
    if (isEarlyReturn) {
      final dateFormat = vehicle.rentalEndDate!;
      message =
          'Вы уверены, что хотите вернуть эту машину досрочно?\nПланируемая дата возврата: ${dateFormat.day}.${dateFormat.month}.${dateFormat.year}';
    } else {
      message = 'Вы уверены, что хотите вернуть эту машину?';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Подтверждение',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFb0b0b0)),
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
              foregroundColor: const Color(0xFF8a2be2),
            ),
            child: const Text('Вернуть'),
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
        await _apiService.returnVehicle(vehicleId);
        _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Машина успешно возвращена!'),
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
              content: Text('Ошибка возврата: ${e.toString()}'),
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
              : VehicleList(
                  vehicles: _vehicles,
                  activeTab: _activeTab,
                  onRent: _handleRentClick,
                  onReturn: _handleReturn,
                ),
        ),
        if (_rentingVehicle != null)
          RentModal(
            vehicle: _rentingVehicle!,
            onClose: _handleRentCancel,
            onConfirm: _handleRentConfirm,
          ),
      ],
    );
  }
}
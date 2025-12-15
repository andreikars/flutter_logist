import 'package:flutter/material.dart';
import '../../../models/vehicle.dart';
import '../../../services/api_service.dart';
import '../widgets/vehicle_form.dart';
import '../widgets/vehicle_list.dart';

class VehiclesSection extends StatefulWidget {
  const VehiclesSection({super.key});

  @override
  State<VehiclesSection> createState() => _VehiclesSectionState();
}

class _VehiclesSectionState extends State<VehiclesSection> {
  final ApiService _apiService = ApiService();
  List<Vehicle> _vehicles = [];
  bool _loading = true;
  Vehicle? _editingVehicle;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _loading = true;
    });
    try {
      final vehicles = await _apiService.getAllVehicles();
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

  void _handleAdd() {
    setState(() {
      _editingVehicle = null;
      _showForm = true;
    });
  }

  void _handleEdit(Vehicle vehicle) {
    setState(() {
      _editingVehicle = vehicle;
      _showForm = true;
    });
  }

  void _handleCloseForm() {
    setState(() {
      _showForm = false;
      _editingVehicle = null;
    });
  }

  Future<void> _handleSave(Map<String, dynamic> vehicleData) async {
    try {
      if (_editingVehicle != null) {
        await _apiService.updateVehicle(_editingVehicle!.id!, vehicleData);
      } else {
        await _apiService.createVehicle(vehicleData);
      }
      _handleCloseForm();
      _loadVehicles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Машина сохранена'),
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
          'Вы уверены, что хотите удалить эту машину?',
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
        await _apiService.deleteVehicle(id);
        _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Машина удалена'),
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
                label: const Text('Добавить машину'),
              ),
            ),
          ),
        if (_showForm)
          VehicleForm(
            vehicle: _editingVehicle,
            onSave: _handleSave,
            onCancel: _handleCloseForm,
          ),
      ],
    );
  }
}
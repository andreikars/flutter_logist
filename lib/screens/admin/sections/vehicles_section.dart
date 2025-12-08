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
          SnackBar(content: Text('Ошибка загрузки: ${e.toString()}')),
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
          const SnackBar(content: Text('Машина сохранена')),
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
        content: const Text('Вы уверены, что хотите удалить эту машину?'),
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
        await _apiService.deleteVehicle(id);
        _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Машина удалена')),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _loading
            ? const Center(child: CircularProgressIndicator())
            : VehicleList(
                vehicles: _vehicles,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
              ),
        if (!_loading && !_showForm)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить машину'),
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


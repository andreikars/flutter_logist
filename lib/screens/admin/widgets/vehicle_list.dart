import 'package:flutter/material.dart';
import '../../../models/vehicle.dart';

class VehicleList extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onEdit;
  final Function(int) onDelete;

  const VehicleList({
    super.key,
    required this.vehicles,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const Center(child: Text('Нет машин'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(vehicle.licensePlate),
            subtitle: Text('${vehicle.model ?? 'N/A'} • ${vehicle.vehicleType ?? 'N/A'} • ${vehicle.isAvailable ? 'Доступна' : 'Арендована'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(vehicle),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(vehicle.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


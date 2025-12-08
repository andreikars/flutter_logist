import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/vehicle.dart';

class VehicleList extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String activeTab;
  final Function(Vehicle)? onRent;
  final Function(int)? onReturn;

  const VehicleList({
    super.key,
    required this.vehicles,
    required this.activeTab,
    this.onRent,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return Center(
        child: Text(
          activeTab == 'rented'
              ? 'У вас нет арендованных машин'
              : 'Нет доступных машин',
        ),
      );
    }

    final dateFormat = DateFormat('dd.MM.yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(vehicle.licensePlate),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${vehicle.model ?? 'N/A'} • ${vehicle.vehicleType ?? 'N/A'}'),
                if (activeTab == 'rented' && vehicle.rentalEndDate != null)
                  Text(
                    'Возврат до: ${dateFormat.format(vehicle.rentalEndDate!)}',
                    style: TextStyle(
                      color: vehicle.rentalEndDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
              ],
            ),
            trailing: activeTab == 'available'
                ? ElevatedButton.icon(
                    onPressed: onRent != null ? () => onRent!(vehicle) : null,
                    icon: const Icon(Icons.directions_car),
                    label: const Text('Арендовать'),
                  )
                : ElevatedButton.icon(
                    onPressed: onReturn != null ? () => onReturn!(vehicle.id!) : null,
                    icon: const Icon(Icons.undo),
                    label: const Text('Вернуть'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}


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
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Нет машин',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Добавьте первую машину',
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
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2d2d2d),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF404040)),
              ),
              child: Icon(
                Icons.directions_car,
                color: vehicle.isAvailable
                    ? const Color(0xFF8a2be2)
                    : const Color(0xFFf56565),
                size: 28,
              ),
            ),
            title: Row(
              children: [
                Text(
                  vehicle.licensePlate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: vehicle.isAvailable
                        ? const Color(0xFF28a745).withOpacity(0.2)
                        : const Color(0xFFf56565).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: vehicle.isAvailable
                          ? const Color(0xFF28a745).withOpacity(0.4)
                          : const Color(0xFFf56565).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    vehicle.isAvailable ? 'Доступна' : 'Арендована',
                    style: TextStyle(
                      color: vehicle.isAvailable
                          ? const Color(0xFF28a745)
                          : const Color(0xFFf56565),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (vehicle.model != null && vehicle.model!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.model!,
                        style: TextStyle(
                          color: const Color(0xFFb0b0b0),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (vehicle.vehicleType != null && vehicle.vehicleType!.isNotEmpty)
                  const SizedBox(height: 2),
                if (vehicle.vehicleType != null && vehicle.vehicleType!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.vehicleType!,
                        style: TextStyle(
                          color: const Color(0xFFb0b0b0),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
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
                    onPressed: () => onEdit(vehicle),
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
                    onPressed: () => onDelete(vehicle.id!),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
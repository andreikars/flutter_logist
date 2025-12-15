class Vehicle {
  final int? id;
  final String licensePlate;
  final String? model;
  final String? vehicleType;
  final bool isAvailable;
  final int? driverId;
  final String? driverName;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;

  Vehicle({
    this.id,
    required this.licensePlate,
    this.model,
    this.vehicleType,
    required this.isAvailable,
    this.driverId,
    this.driverName,
    this.rentalStartDate,
    this.rentalEndDate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      licensePlate: json['licensePlate'] ?? '',
      model: json['model'],
      vehicleType: json['vehicleType'],
      isAvailable: json['isAvailable'] ?? true,
      driverId: json['driverId'],
      driverName: json['driverName'],
      rentalStartDate: json['rentalStartDate'] != null
          ? DateTime.parse(json['rentalStartDate'])
          : null,
      rentalEndDate: json['rentalEndDate'] != null
          ? DateTime.parse(json['rentalEndDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'licensePlate': licensePlate,
      'isAvailable': isAvailable,
    };
    if (model != null) data['model'] = model;
    if (vehicleType != null) data['vehicleType'] = vehicleType;
    return data;
  }
}


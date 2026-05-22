class Vehicle {
  Vehicle({
    required this.id,
    required this.name,
    required this.capacity,
    this.description,
    required this.active,
  });

  final String id;
  final String name;
  final int capacity;
  final String? description;
  final bool active;

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      description: map['description']?.toString(),
      active: map['active'] == true,
    );
  }
}

class Driver {
  Driver({
    required this.id,
    required this.name,
    this.phone,
    this.vehicle,
    required this.active,
  });

  final String id;
  final String name;
  final String? phone;
  final String? vehicle;
  final bool active;

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString(),
      vehicle: map['vehicle']?.toString(),
      active: map['active'] == true,
    );
  }
}

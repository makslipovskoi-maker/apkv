enum UserRole {
  registrar,
  corps,
  driver,
  mechanic,
  manager;

  static UserRole fromString(String value) {
    switch (value) {
      case 'registrar':
        return UserRole.registrar;
      case 'corps':
        return UserRole.corps;
      case 'driver':
        return UserRole.driver;
      case 'mechanic':
        return UserRole.mechanic;
      case 'manager':
        return UserRole.manager;
      default:
        return UserRole.corps;
    }
  }

  String get dbValue {
    switch (this) {
      case UserRole.registrar:
        return 'registrar';
      case UserRole.corps:
        return 'corps';
      case UserRole.driver:
        return 'driver';
      case UserRole.mechanic:
        return 'mechanic';
      case UserRole.manager:
        return 'manager';
    }
  }

  String get title {
    switch (this) {
      case UserRole.registrar:
        return 'Регистратор';
      case UserRole.corps:
        return 'Администратор корпуса';
      case UserRole.driver:
        return 'Водитель';
      case UserRole.mechanic:
        return 'Главный механик';
      case UserRole.manager:
        return 'Руководитель';
    }
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.pin,
    required this.role,
    required this.name,
    this.corps,
    this.driverName,
    this.vehicle,
    this.phone,
    required this.active,
  });

  final String id;
  final String pin;
  final UserRole role;
  final String name;
  final String? corps;
  final String? driverName;
  final String? vehicle;
  final String? phone;
  final bool active;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'].toString(),
      pin: map['pin']?.toString() ?? '',
      role: UserRole.fromString(map['role']?.toString() ?? 'corps'),
      name: map['name']?.toString() ?? 'Пользователь',
      corps: map['corps']?.toString(),
      driverName: map['driver_name']?.toString(),
      vehicle: map['vehicle']?.toString(),
      phone: map['phone']?.toString(),
      active: map['active'] == true,
    );
  }
}

import '../core/constants.dart';
import '../core/date_time_utils.dart';
import '../models/action_log_entry.dart';
import '../models/app_user.dart';
import '../models/request_model.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';

class DemoRepository {
  DemoRepository._() {
    _seed();
  }

  static final DemoRepository instance = DemoRepository._();

  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _vehicles = [];
  final List<Map<String, dynamic>> _drivers = [];
  final List<Map<String, dynamic>> _requests = [];
  final List<Map<String, dynamic>> _trips = [];
  final List<Map<String, dynamic>> _logs = [];

  int _requestCounter = 102;
  int _tripCounter = 14;
  int _logCounter = 3;

  Map<String, dynamic>? _first(List<Map<String, dynamic>> rows, bool Function(Map<String, dynamic>) test) {
    for (final row in rows) {
      if (test(row)) return row;
    }
    return null;
  }

  void _seed() {
    final today = dbDate(todayOnly());
    final tomorrow = dbDate(tomorrowOnly());
    final yesterday = dbDate(todayOnly().subtract(const Duration(days: 1)));

    _users.addAll([
      {'id': 'demo-registrar', 'pin': '1111', 'role': 'registrar', 'name': 'Регистратор санатория', 'active': true},
      {'id': 'demo-corps', 'pin': '2222', 'role': 'corps', 'name': 'Администратор корпуса №1', 'corps': 'Корпус 1', 'active': true},
      {'id': 'demo-driver', 'pin': '3333', 'role': 'driver', 'name': 'Водитель Сергей', 'driver_name': 'Сергей Иванов', 'vehicle': 'Газель', 'phone': '+7 900 000-00-01', 'active': true},
      {'id': 'demo-mechanic', 'pin': '4444', 'role': 'mechanic', 'name': 'Главный механик', 'active': true},
      {'id': 'demo-manager', 'pin': '5555', 'role': 'manager', 'name': 'Руководитель службы размещения', 'active': true},
    ]);

    _vehicles.addAll([
      {'id': 'vehicle-bus', 'name': 'Автобус', 'capacity': 45, 'description': 'Для больших групп гостей', 'active': true},
      {'id': 'vehicle-gazel', 'name': 'Газель', 'capacity': 13, 'description': 'Средние группы и багаж', 'active': true},
      {'id': 'vehicle-largus', 'name': 'Ларгус', 'capacity': 6, 'description': 'Малые группы и индивидуальные выезды', 'active': true},
    ]);

    _drivers.addAll([
      {'id': 'driver-sergey', 'name': 'Сергей Иванов', 'phone': '+7 900 000-00-01', 'vehicle': 'Газель', 'active': true},
      {'id': 'driver-alexey', 'name': 'Алексей Петров', 'phone': '+7 900 000-00-02', 'vehicle': 'Автобус', 'active': true},
      {'id': 'driver-viktor', 'name': 'Виктор Сидоров', 'phone': '+7 900 000-00-03', 'vehicle': 'Ларгус', 'active': true},
    ]);

    _requests.addAll([
      {'id': 'REQ-101', 'corps': 'Корпус 1', 'room': '214', 'guest_name': 'Смирнова Анна Петровна', 'people_count': 2, 'baggage': '2 чемодана', 'departure_date': tomorrow, 'direction': 'Ж/д вокзал Анапа', 'destination': 'Ж/д вокзал Анапа', 'ticket_time': '15:20', 'transfer_needed': true, 'comment': 'Пожилой гость, посадить ближе к выходу', 'status': statusNewRequest, 'created_by': 'demo-corps', 'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
      {'id': 'REQ-102', 'corps': 'Корпус 2', 'room': '118', 'guest_name': 'Группа Ивановых', 'people_count': 5, 'baggage': '5 сумок', 'departure_date': tomorrow, 'direction': 'Аэропорт Сочи', 'destination': 'Аэропорт Сочи', 'ticket_time': '19:40', 'transfer_needed': true, 'comment': 'Нужен детский бустер', 'status': statusNewRequest, 'created_by': 'demo-corps', 'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()},
    ]);

    _trips.addAll([
      {'id': 'TRIP-011', 'trip_code': 'R-011', 'request_id': 'REQ-090', 'departure_date': today, 'vehicle_time': '08:30', 'recommended_time': '08:45', 'corps': 'Корпус 1', 'room': '305, 306', 'guest_name': 'Группа Кузнецовых', 'people_count': 4, 'baggage': '4 чемодана', 'direction': 'Ж/д вокзал Анапа', 'destination': 'Ж/д вокзал Анапа', 'ticket_time': '10:15', 'vehicle': 'Газель', 'driver_name': 'Сергей Иванов', 'driver_phone': '+7 900 000-00-01', 'status': statusToDriver, 'comment': 'Гости ждут у главного входа', 'created_by': 'demo-registrar', 'updated_by': 'demo-registrar', 'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
      {'id': 'TRIP-012', 'trip_code': 'R-012', 'request_id': 'REQ-091', 'departure_date': today, 'vehicle_time': '11:00', 'recommended_time': '11:15', 'corps': 'Корпус 3', 'room': '410', 'guest_name': 'Орлова Марина', 'people_count': 1, 'baggage': '1 сумка', 'direction': 'Автовокзал Анапа', 'destination': 'Автовокзал Анапа', 'ticket_time': '12:05', 'vehicle': 'Ларгус', 'driver_name': 'Виктор Сидоров', 'driver_phone': '+7 900 000-00-03', 'status': statusDriverConfirmed, 'driver_confirmed_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(), 'comment': '', 'created_by': 'demo-registrar', 'updated_by': 'demo-driver', 'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
      {'id': 'TRIP-013', 'trip_code': 'R-013', 'request_id': 'REQ-092', 'departure_date': tomorrow, 'vehicle_time': '07:00', 'recommended_time': '07:15', 'corps': 'Корпус 2', 'room': '201-210', 'guest_name': 'Группа конференции', 'people_count': 22, 'baggage': 'много багажа', 'direction': 'Ж/д вокзал Анапа', 'destination': 'Ж/д вокзал Анапа', 'ticket_time': '09:00', 'vehicle': 'Автобус', 'driver_name': 'Алексей Петров', 'driver_phone': '+7 900 000-00-02', 'status': statusScheduled, 'comment': 'Проверить список перед посадкой', 'created_by': 'demo-registrar', 'updated_by': 'demo-registrar', 'created_at': DateTime.now().toIso8601String()},
      {'id': 'TRIP-014', 'trip_code': 'R-014', 'request_id': 'REQ-093', 'departure_date': tomorrow, 'vehicle_time': null, 'recommended_time': '13:00', 'corps': 'Корпус 4', 'room': '122', 'guest_name': 'Белова Елена', 'people_count': 2, 'baggage': '2 чемодана', 'direction': 'Новороссийск', 'destination': 'Ж/д вокзал Новороссийск', 'ticket_time': '16:30', 'vehicle': null, 'driver_name': null, 'driver_phone': null, 'status': statusNeedInfo, 'comment': 'Нужно согласовать машину', 'created_by': 'demo-registrar', 'updated_by': 'demo-registrar', 'created_at': DateTime.now().toIso8601String()},
      {'id': 'TRIP-010', 'trip_code': 'R-010', 'request_id': 'REQ-089', 'departure_date': yesterday, 'vehicle_time': '09:00', 'recommended_time': '09:15', 'corps': 'Корпус 1', 'room': '101', 'guest_name': 'Павлов Дмитрий', 'people_count': 1, 'baggage': '1 чемодан', 'direction': 'Аэропорт Анапа', 'destination': 'Аэропорт Анапа', 'ticket_time': '11:00', 'vehicle': 'Ларгус', 'driver_name': 'Виктор Сидоров', 'driver_phone': '+7 900 000-00-03', 'status': statusDone, 'completed_at': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(), 'created_by': 'demo-registrar', 'updated_by': 'demo-driver'},
    ]);

    _logs.addAll([
      {'id': 'LOG-001', 'user_name': 'Регистратор санатория', 'role': 'Регистратор', 'trip_id': 'TRIP-011', 'action': 'создан рейс', 'old_value': null, 'new_value': 'R-011', 'reason': null, 'urgency': null, 'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String()},
      {'id': 'LOG-002', 'user_name': 'Водитель Сергей', 'role': 'Водитель', 'trip_id': 'TRIP-012', 'action': 'водитель подтвердил', 'old_value': statusToDriver, 'new_value': statusDriverConfirmed, 'reason': null, 'urgency': null, 'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String()},
    ]);
  }

  Future<AppUser?> loginByPin(String pin) async {
    final row = _first(_users, (user) => user['pin'] == pin && user['active'] == true);
    return row == null ? null : AppUser.fromMap(row);
  }

  Future<List<Vehicle>> vehicles() async => _vehicles.map(Vehicle.fromMap).toList();

  Future<List<Driver>> drivers() async => _drivers.map(Driver.fromMap).toList();

  Future<List<GuestRequest>> requests({String? corps, bool onlyActive = false}) async {
    var rows = List<Map<String, dynamic>>.from(_requests);
    if (corps != null && corps.isNotEmpty) rows = rows.where((row) => row['corps'] == corps).toList();
    if (onlyActive) rows = rows.where((row) => row['status'] != statusDone && row['status'] != statusCancelled).toList();
    rows.sort((a, b) => (b['created_at'] ?? '').toString().compareTo((a['created_at'] ?? '').toString()));
    return rows.map(GuestRequest.fromMap).toList();
  }

  Future<List<Trip>> trips({DateTime? date, String? driverName, bool archive = false, bool problems = false}) async {
    var rows = List<Map<String, dynamic>>.from(_trips);
    if (date != null) rows = rows.where((row) => row['departure_date'] == dbDate(date)).toList();
    if (driverName != null && driverName.isNotEmpty) rows = rows.where((row) => row['driver_name'] == driverName).toList();
    if (archive) {
      rows = rows.where((row) => row['status'] == statusDone).toList();
    } else if (problems) {
      rows = rows.where((row) => row['status'] == statusProblem || (row['problem']?.toString().trim().isNotEmpty ?? false)).toList();
    }
    rows.sort((a, b) {
      final byDate = (a['departure_date'] ?? '').toString().compareTo((b['departure_date'] ?? '').toString());
      if (byDate != 0) return byDate;
      return (a['vehicle_time'] ?? '').toString().compareTo((b['vehicle_time'] ?? '').toString());
    });
    return rows.map(Trip.fromMap).toList();
  }

  Future<Trip?> tripByCode(String code) async {
    final row = _first(_trips, (trip) => trip['trip_code'] == code || trip['id'] == code);
    return row == null ? null : Trip.fromMap(row);
  }

  Future<String> createRequest(Map<String, dynamic> data, AppUser user) async {
    final id = 'REQ-${++_requestCounter}';
    _requests.insert(0, {...data, 'id': id, 'created_at': DateTime.now().toIso8601String()});
    await logAction(user: user, action: 'создана заявка', newValue: '${data['guest_name']} / ${data['departure_date']}');
    return id;
  }

  Future<Trip> createTripFromRequest({required GuestRequest request, required AppUser user, required String vehicleTime, required String recommendedTime, required String? vehicle, required Driver? driver, required String? comment}) async {
    final id = 'TRIP-${++_tripCounter}';
    final code = 'R-${_tripCounter.toString().padLeft(3, '0')}';
    final row = {'id': id, 'trip_code': code, 'request_id': request.id, 'departure_date': request.departureDate, 'vehicle_time': vehicleTime.isEmpty ? null : vehicleTime, 'recommended_time': recommendedTime.isEmpty ? null : recommendedTime, 'corps': request.corps, 'room': request.room, 'guest_name': request.guestName, 'people_count': request.peopleCount, 'baggage': request.baggage, 'direction': request.direction, 'destination': request.destination, 'ticket_time': request.ticketTime, 'vehicle': vehicle?.isEmpty == true ? null : vehicle, 'driver_name': driver?.name, 'driver_phone': driver?.phone, 'status': driver == null ? statusScheduled : statusToDriver, 'comment': comment, 'created_by': user.id, 'updated_by': user.id, 'created_at': DateTime.now().toIso8601String()};
    _trips.add(row);
    final requestRow = _first(_requests, (item) => item['id'] == request.id);
    if (requestRow != null) requestRow['status'] = statusScheduled;
    await logAction(user: user, tripId: id, action: 'создан рейс', newValue: code);
    return Trip.fromMap(row);
  }

  Future<void> updateTrip(Trip trip, AppUser user, Map<String, dynamic> values, {required String action, String? oldValue, String? newValue, String? reason, String? urgency}) async {
    final row = _first(_trips, (item) => item['id'] == trip.id);
    if (row == null) return;
    row.addAll(values);
    row['updated_by'] = user.id;
    row['updated_at'] = DateTime.now().toIso8601String();
    await logAction(user: user, tripId: trip.id, action: action, oldValue: oldValue, newValue: newValue ?? values.toString(), reason: reason, urgency: urgency);
  }

  Future<void> createChange({required AppUser user, String? tripCode, String? requestId, required String corps, required String room, required String guestName, required String fieldChanged, String? oldValue, required String newValue, required String reason, required String urgency}) async {
    final trip = tripCode == null || tripCode.trim().isEmpty ? null : await tripByCode(tripCode.trim());
    if (trip != null) {
      final row = _first(_trips, (item) => item['id'] == trip.id);
      if (row != null) {
        row['status'] = urgency == 'срочно' || urgency == 'очень срочно' ? statusUrgentChange : statusChanged;
        row['comment'] = '$fieldChanged: $newValue. Причина: $reason';
      }
    }
    await logAction(user: user, tripId: trip?.id, action: 'подано изменение', oldValue: oldValue, newValue: '$fieldChanged: $newValue', reason: reason, urgency: urgency);
  }

  Future<void> setMechanicStatus({required AppUser user, required DateTime date, required String vehicle, required String status, String? comment}) async {
    final rows = _trips.where((row) => row['departure_date'] == dbDate(date) && row['vehicle'] == vehicle);
    for (final row in rows) {
      if (status == 'ГОТОВА') {
        row['mechanic_confirmed_at'] = DateTime.now().toIso8601String();
      } else {
        row['status'] = statusProblem;
        row['problem'] = comment?.trim().isNotEmpty == true ? 'Транспорт: $status. $comment' : 'Транспорт: $status';
      }
    }
    await logAction(user: user, action: 'механик отметил транспорт', newValue: '$vehicle: $status', reason: comment);
  }

  Future<List<ActionLogEntry>> actionLog() async {
    final rows = List<Map<String, dynamic>>.from(_logs);
    rows.sort((a, b) => (b['created_at'] ?? '').toString().compareTo((a['created_at'] ?? '').toString()));
    return rows.map(ActionLogEntry.fromMap).toList();
  }

  Future<void> logAction({required AppUser user, String? tripId, required String action, String? oldValue, String? newValue, String? reason, String? urgency}) async {
    _logs.insert(0, {'id': 'LOG-${(_logCounter++).toString().padLeft(3, '0')}', 'user_name': user.name, 'role': user.role.title, 'trip_id': tripId, 'action': action, 'old_value': oldValue, 'new_value': newValue, 'reason': reason, 'urgency': urgency, 'created_at': DateTime.now().toIso8601String()});
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/date_time_utils.dart';
import '../models/action_log_entry.dart';
import '../models/app_user.dart';
import '../models/request_model.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';
import '../services/supabase_service.dart';
import 'demo_repository.dart';

class AppRepository {
  SupabaseClient get _client => SupabaseService.instance.client;
  DemoRepository get _demo => DemoRepository.instance;
  bool get _useDemo => !SupabaseService.instance.isConfigured;

  Future<AppUser?> loginByPin(String pin) async {
    if (_useDemo) return _demo.loginByPin(pin);
    final result = await _client.rpc('login_by_pin', params: {'p_pin': pin});
    if (result is List && result.isNotEmpty) {
      return AppUser.fromMap(Map<String, dynamic>.from(result.first as Map));
    }
    return null;
  }

  Future<List<Vehicle>> vehicles() async {
    if (_useDemo) return _demo.vehicles();
    final data = await _client.from('vehicles').select().eq('active', true).order('name');
    return (data as List).map((item) => Vehicle.fromMap(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<Driver>> drivers() async {
    if (_useDemo) return _demo.drivers();
    final data = await _client.from('drivers').select().eq('active', true).order('name');
    return (data as List).map((item) => Driver.fromMap(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<GuestRequest>> requests({String? corps, bool onlyActive = false}) async {
    if (_useDemo) return _demo.requests(corps: corps, onlyActive: onlyActive);
    var query = _client.from('requests').select();
    if (corps != null && corps.isNotEmpty) query = query.eq('corps', corps);
    if (onlyActive) query = query.neq('status', statusDone).neq('status', statusCancelled);
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((item) => GuestRequest.fromMap(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<Trip>> trips({DateTime? date, String? driverName, bool archive = false, bool problems = false}) async {
    if (_useDemo) return _demo.trips(date: date, driverName: driverName, archive: archive, problems: problems);
    var query = _client.from('trips').select();
    if (date != null) query = query.eq('departure_date', dbDate(date));
    if (driverName != null && driverName.isNotEmpty) query = query.eq('driver_name', driverName);
    if (archive) {
      query = query.eq('status', statusDone);
    } else if (problems) {
      query = query.or('status.eq.$statusProblem,problem.not.is.null');
    }
    final data = await query.order('departure_date', ascending: true).order('vehicle_time', ascending: true);
    return (data as List).map((item) => Trip.fromMap(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<Trip?> tripByCode(String code) async {
    if (_useDemo) return _demo.tripByCode(code);
    final data = await _client.from('trips').select().eq('trip_code', code).maybeSingle();
    if (data == null) return null;
    return Trip.fromMap(Map<String, dynamic>.from(data));
  }

  Future<String> createRequest(Map<String, dynamic> data, AppUser user) async {
    if (_useDemo) return _demo.createRequest(data, user);
    final inserted = await _client.from('requests').insert(data).select('id').single();
    await logAction(user: user, action: 'создана заявка', newValue: '${data['guest_name']} / ${data['departure_date']}');
    return inserted['id'].toString();
  }

  Future<Trip> createTripFromRequest({required GuestRequest request, required AppUser user, required String vehicleTime, required String recommendedTime, required String? vehicle, required Driver? driver, required String? comment}) async {
    if (_useDemo) return _demo.createTripFromRequest(request: request, user: user, vehicleTime: vehicleTime, recommendedTime: recommendedTime, vehicle: vehicle, driver: driver, comment: comment);
    final status = driver == null ? statusScheduled : statusToDriver;
    final row = {'request_id': request.id, 'departure_date': request.departureDate, 'vehicle_time': vehicleTime.isEmpty ? null : vehicleTime, 'recommended_time': recommendedTime.isEmpty ? null : recommendedTime, 'corps': request.corps, 'room': request.room, 'guest_name': request.guestName, 'people_count': request.peopleCount, 'baggage': request.baggage, 'direction': request.direction, 'destination': request.destination, 'ticket_time': request.ticketTime, 'vehicle': vehicle?.isEmpty == true ? null : vehicle, 'driver_name': driver?.name, 'driver_phone': driver?.phone, 'status': status, 'comment': comment, 'created_by': user.id, 'updated_by': user.id};
    final inserted = await _client.from('trips').insert(row).select().single();
    await _client.from('requests').update({'status': statusScheduled}).eq('id', request.id);
    final trip = Trip.fromMap(Map<String, dynamic>.from(inserted));
    await logAction(user: user, tripId: trip.id, action: 'создан рейс', newValue: trip.tripCode);
    return trip;
  }

  Future<void> updateTrip(Trip trip, AppUser user, Map<String, dynamic> values, {required String action, String? oldValue, String? newValue, String? reason, String? urgency}) async {
    if (_useDemo) return _demo.updateTrip(trip, user, values, action: action, oldValue: oldValue, newValue: newValue, reason: reason, urgency: urgency);
    await _client.from('trips').update({...values, 'updated_by': user.id}).eq('id', trip.id);
    await logAction(user: user, tripId: trip.id, action: action, oldValue: oldValue, newValue: newValue ?? values.toString(), reason: reason, urgency: urgency);
  }

  Future<void> createChange({required AppUser user, String? tripCode, String? requestId, required String corps, required String room, required String guestName, required String fieldChanged, String? oldValue, required String newValue, required String reason, required String urgency}) async {
    if (_useDemo) return _demo.createChange(user: user, tripCode: tripCode, requestId: requestId, corps: corps, room: room, guestName: guestName, fieldChanged: fieldChanged, oldValue: oldValue, newValue: newValue, reason: reason, urgency: urgency);
    Trip? trip;
    if (tripCode != null && tripCode.trim().isNotEmpty) trip = await tripByCode(tripCode.trim());
    await _client.from('changes').insert({'trip_id': trip?.id, 'request_id': requestId?.trim().isEmpty == true ? null : requestId, 'corps': corps, 'room': room, 'guest_name': guestName, 'field_changed': fieldChanged, 'old_value': oldValue, 'new_value': newValue, 'reason': reason, 'urgency': urgency, 'created_by': user.id});
    if (trip != null) {
      final status = urgency == 'очень срочно' || urgency == 'срочно' ? statusUrgentChange : statusChanged;
      await _client.from('trips').update({'status': status, 'updated_by': user.id}).eq('id', trip.id);
    }
    await logAction(user: user, tripId: trip?.id, action: 'подано изменение', oldValue: oldValue, newValue: '$fieldChanged: $newValue', reason: reason, urgency: urgency);
  }

  Future<void> setMechanicStatus({required AppUser user, required DateTime date, required String vehicle, required String status, String? comment}) async {
    if (_useDemo) return _demo.setMechanicStatus(user: user, date: date, vehicle: vehicle, status: status, comment: comment);
    await _client.from('mechanic_status').insert({'date': dbDate(date), 'vehicle': vehicle, 'status': status, 'comment': comment, 'confirmed_by': user.id});
    if (status == 'ГОТОВА') {
      await _client.from('trips').update({'mechanic_confirmed_at': DateTime.now().toIso8601String(), 'updated_by': user.id}).eq('departure_date', dbDate(date)).eq('vehicle', vehicle);
    } else {
      await _client.from('trips').update({'status': statusProblem, 'problem': comment?.trim().isEmpty == true ? 'Транспорт: $status' : 'Транспорт: $status. $comment', 'updated_by': user.id}).eq('departure_date', dbDate(date)).eq('vehicle', vehicle);
    }
    await logAction(user: user, action: 'механик отметил транспорт', newValue: '$vehicle: $status', reason: comment);
  }

  Future<List<ActionLogEntry>> actionLog() async {
    if (_useDemo) return _demo.actionLog();
    final data = await _client.from('action_log').select().order('created_at', ascending: false).limit(200);
    return (data as List).map((item) => ActionLogEntry.fromMap(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<void> logAction({required AppUser user, String? tripId, required String action, String? oldValue, String? newValue, String? reason, String? urgency}) async {
    if (_useDemo) return _demo.logAction(user: user, tripId: tripId, action: action, oldValue: oldValue, newValue: newValue, reason: reason, urgency: urgency);
    await _client.from('action_log').insert({'user_id': user.id, 'user_name': user.name, 'role': user.role.title, 'trip_id': tripId, 'action': action, 'old_value': oldValue, 'new_value': newValue, 'reason': reason, 'urgency': urgency});
  }
}

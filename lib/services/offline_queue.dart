import 'package:hive_flutter/hive_flutter.dart';

class OfflineQueue {
  OfflineQueue._();

  static final OfflineQueue instance = OfflineQueue._();

  static const _boxName = 'offline_actions';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<void> enqueue(String type, Map<String, dynamic> data) async {
    await _box.add({
      'type': type,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  int get pendingCount => _box.length;

  List<Map<String, dynamic>> pending() {
    return _box.values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> clear() => _box.clear();
}

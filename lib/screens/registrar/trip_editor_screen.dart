import 'package:flutter/material.dart';

import '../../core/date_time_utils.dart';
import '../../models/app_user.dart';
import '../../models/request_model.dart';
import '../../models/vehicle.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/app_widgets.dart';

class TripEditorScreen extends StatefulWidget {
  const TripEditorScreen({
    super.key,
    required this.user,
    required this.request,
  });

  final AppUser user;
  final GuestRequest request;

  @override
  State<TripEditorScreen> createState() => _TripEditorScreenState();
}

class _TripEditorScreenState extends State<TripEditorScreen> {
  final _repo = AppRepository();
  final _vehicleTime = TextEditingController();
  final _recommendedTime = TextEditingController();
  final _comment = TextEditingController();

  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  String? _vehicle;
  Driver? _driver;
  bool _loading = false;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDictionaries();
  }

  @override
  void dispose() {
    _vehicleTime.dispose();
    _recommendedTime.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _loadDictionaries() async {
    try {
      final vehicles = await _repo.vehicles();
      final drivers = await _repo.drivers();
      setState(() {
        _vehicles = vehicles;
        _drivers = drivers;
        _initialLoading = false;
      });
    } catch (_) {
      setState(() => _initialLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final trip = await _repo.createTripFromRequest(
        request: widget.request,
        user: widget.user,
        vehicleTime: normalizeTime(_vehicleTime.text),
        recommendedTime: normalizeTime(_recommendedTime.text),
        vehicle: _vehicle,
        driver: _driver,
        comment: _comment.text.trim(),
      );
      if (!mounted) return;
      showAppMessage(context, 'Создан рейс ${trip.tripCode}');
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      showAppMessage(context, 'Нет связи с сервером или ошибка создания рейса');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Driver> get _filteredDrivers {
    if (_vehicle == null || _vehicle!.isEmpty) return _drivers;
    final filtered = _drivers.where((driver) => driver.vehicle == _vehicle).toList();
    return filtered.isEmpty ? _drivers : filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const AppPage(
        title: 'Создать рейс',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppPage(
      title: 'Создать рейс',
      child: ListView(
        children: [
          Card(
            color: const Color(0xFFFFF2C7),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow('Гость', widget.request.guestName),
                  InfoRow('Корпус', widget.request.corps),
                  InfoRow('Комната', widget.request.room),
                  InfoRow('Дата', displayDate(widget.request.departureDate)),
                  InfoRow('Куда', widget.request.direction),
                  InfoRow('Билет', displayTime(widget.request.ticketTime)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vehicleTime,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              labelText: 'Время подачи машины, например 13:00',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recommendedTime,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              labelText: 'Рекомендуемое время выезда',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _vehicle,
            items: _vehicles
                .map((vehicle) => DropdownMenuItem(
                      value: vehicle.name,
                      child: Text('${vehicle.name} · ${vehicle.capacity} мест'),
                    ))
                .toList(),
            onChanged: (value) => setState(() {
              _vehicle = value;
              _driver = null;
            }),
            decoration: const InputDecoration(labelText: 'Машина'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Driver>(
            value: _driver,
            items: _filteredDrivers
                .map((driver) => DropdownMenuItem(
                      value: driver,
                      child: Text('${driver.name} · ${driver.vehicle ?? 'машина не указана'}'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _driver = value),
            decoration: const InputDecoration(labelText: 'Водитель'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Комментарий'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: Text(_loading ? 'СОЗДАНИЕ...' : 'СОЗДАТЬ РЕЙС'),
          ),
        ],
      ),
    );
  }
}

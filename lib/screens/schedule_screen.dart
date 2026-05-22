import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/date_time_utils.dart';
import '../models/app_user.dart';
import '../models/trip.dart';
import '../repositories/app_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

enum ScheduleMode { all, today, tomorrow, urgent, problems }

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.user, required this.mode});

  final AppUser user;
  final ScheduleMode mode;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _repo = AppRepository();
  late Future<List<Trip>> _future;

  bool get _canEdit =>
      widget.user.role == UserRole.registrar || widget.user.role == UserRole.mechanic;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Trip>> _load() async {
    switch (widget.mode) {
      case ScheduleMode.today:
        return _repo.trips(date: todayOnly());
      case ScheduleMode.tomorrow:
        return _repo.trips(date: tomorrowOnly());
      case ScheduleMode.problems:
        return _repo.trips(problems: true);
      case ScheduleMode.urgent:
        final trips = await _repo.trips();
        return trips.where((trip) => trip.status == statusUrgentChange).toList();
      case ScheduleMode.all:
        return _repo.trips();
    }
  }

  String get _title {
    switch (widget.mode) {
      case ScheduleMode.today:
        return 'Рейсы сегодня';
      case ScheduleMode.tomorrow:
        return 'Рейсы завтра';
      case ScheduleMode.problems:
        return 'Проблемы';
      case ScheduleMode.urgent:
        return 'Срочные изменения';
      case ScheduleMode.all:
        return 'Главный график';
    }
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  Future<void> _setStatus(Trip trip, String status) async {
    try {
      await _repo.updateTrip(
        trip,
        widget.user,
        {
          'status': status,
          if (status == statusDone) 'completed_at': DateTime.now().toIso8601String(),
        },
        action: status == statusDone ? 'рейс закрыт' : 'изменён статус рейса',
        oldValue: trip.status,
        newValue: status,
      );
      if (!mounted) return;
      showAppMessage(context, 'Статус обновлён');
      _refresh();
    } catch (_) {
      if (!mounted) return;
      showAppMessage(context, 'Нет связи с сервером');
    }
  }

  Future<void> _markProblem(Trip trip) async {
    final controller = TextEditingController();
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Проблема по рейсу'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Комментарий'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('СОХРАНИТЬ'),
          ),
        ],
      ),
    );

    if (comment == null) return;

    await _repo.updateTrip(
      trip,
      widget.user,
      {'status': statusProblem, 'problem': comment},
      action: 'возникла проблема',
      oldValue: trip.status,
      newValue: comment,
    );
    _refresh();
  }

  Future<void> _editTrip(Trip trip) async {
    final vehicleTime = TextEditingController(text: displayTime(trip.vehicleTime));
    final recommendedTime = TextEditingController(text: displayTime(trip.recommendedTime));
    final vehicle = TextEditingController(text: trip.vehicle ?? '');
    final driver = TextEditingController(text: trip.driverName ?? '');
    final comment = TextEditingController(text: trip.comment ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Изменить рейс ${trip.tripCode}'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: vehicleTime,
                decoration: const InputDecoration(labelText: 'Время подачи'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: recommendedTime,
                decoration: const InputDecoration(labelText: 'Рекомендуемое время'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: vehicle,
                decoration: const InputDecoration(labelText: 'Машина'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: driver,
                decoration: const InputDecoration(labelText: 'Водитель'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: comment,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Комментарий'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'vehicle_time': normalizeTime(vehicleTime.text),
              'recommended_time': normalizeTime(recommendedTime.text),
              'vehicle': vehicle.text.trim(),
              'driver_name': driver.text.trim(),
              'comment': comment.text.trim(),
            }),
            child: const Text('СОХРАНИТЬ'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final updates = <String, dynamic>{
      'vehicle_time': result['vehicle_time']!.isEmpty ? null : result['vehicle_time'],
      'recommended_time':
          result['recommended_time']!.isEmpty ? null : result['recommended_time'],
      'vehicle': result['vehicle']!.isEmpty ? null : result['vehicle'],
      'driver_name': result['driver_name']!.isEmpty ? null : result['driver_name'],
      'comment': result['comment'],
      'status': result['driver_name']!.isEmpty ? statusScheduled : statusToDriver,
    };

    await _repo.updateTrip(
      trip,
      widget.user,
      updates,
      action: 'изменён рейс',
      oldValue: '${trip.vehicleTime}/${trip.vehicle}/${trip.driverName}',
      newValue: result.toString(),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: _title,
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
      ],
      child: FutureBuilder<List<Trip>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              text: 'Нет связи с сервером',
              icon: Icons.cloud_off_outlined,
            );
          }

          final trips = snapshot.data ?? [];
          if (trips.isEmpty) return const EmptyState(text: 'Рейсов нет');

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) => _TripCard(
              trip: trips[index],
              canEdit: _canEdit,
              onDone: () => _setStatus(trips[index], statusDone),
              onCancel: () => _setStatus(trips[index], statusCancelled),
              onProblem: () => _markProblem(trips[index]),
              onEdit: () => _editTrip(trips[index]),
            ),
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.canEdit,
    required this.onDone,
    required this.onCancel,
    required this.onProblem,
    required this.onEdit,
  });

  final Trip trip;
  final bool canEdit;
  final VoidCallback onDone;
  final VoidCallback onCancel;
  final VoidCallback onProblem;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final missingDriver = trip.driverName == null || trip.driverName!.isEmpty;
    final missingVehicle = trip.vehicle == null || trip.vehicle!.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Рейс ${trip.tripCode}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                StatusBadge(status: trip.status),
                if (missingDriver) const StatusBadge(status: 'Нет водителя'),
                if (missingVehicle) const StatusBadge(status: 'Нет машины'),
              ],
            ),
            const SizedBox(height: 10),
            InfoRow('Дата', displayDate(trip.departureDate), icon: Icons.event),
            InfoRow('Подача', displayTime(trip.vehicleTime), icon: Icons.schedule),
            InfoRow('Выезд', displayTime(trip.recommendedTime), icon: Icons.route),
            InfoRow('Корпус', trip.corps, icon: Icons.business_outlined),
            InfoRow('Комната', trip.room, icon: Icons.meeting_room_outlined),
            InfoRow('Гость', trip.guestName, icon: Icons.person_outline),
            InfoRow('Людей', trip.peopleCount.toString(), icon: Icons.people_outline),
            InfoRow('Багаж', trip.baggage, icon: Icons.work_outline),
            InfoRow('Куда', trip.direction, icon: Icons.place_outlined),
            InfoRow('Адрес', trip.destination),
            InfoRow('Билет', displayTime(trip.ticketTime), icon: Icons.confirmation_num_outlined),
            InfoRow('Машина', trip.vehicle, icon: Icons.directions_bus_outlined),
            InfoRow('Водитель', trip.driverName, icon: Icons.badge_outlined),
            InfoRow('Водитель подтвердил', displayDateTime(trip.driverConfirmedAt)),
            InfoRow('Механик подтвердил', displayDateTime(trip.mechanicConfirmedAt)),
            if (trip.comment != null && trip.comment!.isNotEmpty)
              InfoRow('Комментарий', trip.comment),
            if (trip.problem != null && trip.problem!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.red),
                  ),
                  child: Text(
                    'Проблема: ${trip.problem}',
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (canEdit) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Изменить'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onProblem,
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Проблема'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Отменить'),
                  ),
                  ElevatedButton.icon(
                    onPressed: onDone,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Закрыть'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

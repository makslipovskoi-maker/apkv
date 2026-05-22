import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/date_time_utils.dart';
import '../../models/app_user.dart';
import '../../models/trip.dart';
import '../../repositories/app_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({
    super.key,
    required this.user,
    required this.showTomorrow,
  });

  final AppUser user;
  final bool showTomorrow;

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  final _repo = AppRepository();
  late Future<List<Trip>> _future;

  DateTime get _date => widget.showTomorrow ? tomorrowOnly() : todayOnly();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Trip>> _load() {
    return _repo.trips(date: _date, driverName: widget.user.driverName);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  Future<void> _update(Trip trip, String status) async {
    final values = <String, dynamic>{'status': status};
    if (status == statusDriverConfirmed) {
      values['driver_confirmed_at'] = DateTime.now().toIso8601String();
    }
    if (status == statusDone) {
      values['completed_at'] = DateTime.now().toIso8601String();
    }

    try {
      await _repo.updateTrip(
        trip,
        widget.user,
        values,
        action: _driverAction(status),
        oldValue: trip.status,
        newValue: status,
      );
      if (!mounted) return;
      showAppMessage(context, 'Отметка сохранена');
      _refresh();
    } catch (_) {
      if (!mounted) return;
      showAppMessage(context, 'Нет связи с сервером');
    }
  }

  String _driverAction(String status) {
    switch (status) {
      case statusDriverConfirmed:
        return 'водитель подтвердил';
      case statusVehicleArrived:
        return 'машина подана';
      case statusDone:
        return 'гости уехали';
      default:
        return 'изменён статус водителем';
    }
  }

  Future<void> _problem(Trip trip) async {
    final controller = TextEditingController();
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сообщить о проблеме'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Что произошло?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('ОТПРАВИТЬ'),
          ),
        ],
      ),
    );
    if (comment == null) return;
    await _repo.updateTrip(
      trip,
      widget.user,
      {'status': statusProblem, 'problem': comment},
      action: 'водитель сообщил проблему',
      oldValue: trip.status,
      newValue: comment,
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.showTomorrow ? 'Мои рейсы завтра' : 'Мои рейсы сегодня',
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
          if (trips.isEmpty) return const EmptyState(text: 'Ваших рейсов нет');

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) => _DriverTripCard(
              trip: trips[index],
              onAccepted: () => _update(trips[index], statusDriverConfirmed),
              onArrived: () => _update(trips[index], statusVehicleArrived),
              onDeparted: () => _update(trips[index], statusDone),
              onProblem: () => _problem(trips[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DriverTripCard extends StatelessWidget {
  const _DriverTripCard({
    required this.trip,
    required this.onAccepted,
    required this.onArrived,
    required this.onDeparted,
    required this.onProblem,
  });

  final Trip trip;
  final VoidCallback onAccepted;
  final VoidCallback onArrived;
  final VoidCallback onDeparted;
  final VoidCallback onProblem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Рейс ${trip.tripCode}',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              displayTime(trip.vehicleTime),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 8),
            StatusBadge(status: trip.status),
            const SizedBox(height: 14),
            InfoRow('Машина', trip.vehicle, icon: Icons.directions_bus),
            InfoRow('Куда', trip.direction, icon: Icons.place),
            InfoRow('Гостей', trip.peopleCount.toString(), icon: Icons.people),
            InfoRow('Комнаты', trip.room, icon: Icons.meeting_room),
            InfoRow('Багаж', trip.baggage, icon: Icons.work),
            if (trip.comment != null && trip.comment!.isNotEmpty)
              InfoRow('Комментарий', trip.comment),
            if (trip.problem != null && trip.problem!.isNotEmpty)
              InfoRow('Проблема', trip.problem, icon: Icons.report_problem),
            const SizedBox(height: 14),
            BigActionButton(
              label: 'ПРИНЯЛ',
              icon: Icons.thumb_up_alt_outlined,
              onPressed: onAccepted,
              color: AppColors.blue,
            ),
            BigActionButton(
              label: 'МАШИНА ПОДАНА',
              icon: Icons.directions_car_filled_outlined,
              onPressed: onArrived,
              color: AppColors.green,
            ),
            BigActionButton(
              label: 'ГОСТИ УЕХАЛИ',
              icon: Icons.done_all,
              onPressed: onDeparted,
              color: AppColors.green,
            ),
            BigActionButton(
              label: 'ПРОБЛЕМА',
              icon: Icons.report_problem_outlined,
              onPressed: onProblem,
              color: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }
}

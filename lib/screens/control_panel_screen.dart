import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/date_time_utils.dart';
import '../models/app_user.dart';
import '../models/trip.dart';
import '../repositories/app_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ControlPanelScreen extends StatefulWidget {
  const ControlPanelScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  final _repo = AppRepository();
  late Future<_ControlData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ControlData> _load() async {
    final today = await _repo.trips(date: todayOnly());
    final tomorrow = await _repo.trips(date: tomorrowOnly());
    final all = [...today, ...tomorrow];
    return _ControlData(today: today, tomorrow: tomorrow);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Панель контроля',
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
      ],
      child: FutureBuilder<_ControlData>(
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

          final data = snapshot.data!;
          final todayGuests =
              data.today.fold<int>(0, (sum, trip) => sum + trip.peopleCount);
          final tomorrowGuests =
              data.tomorrow.fold<int>(0, (sum, trip) => sum + trip.peopleCount);
          final all = [...data.today, ...data.tomorrow];
          final withoutDriver = all.where((t) => t.driverName == null || t.driverName!.isEmpty).length;
          final withoutVehicle = all.where((t) => t.vehicle == null || t.vehicle!.isEmpty).length;
          final unconfirmed = all.where((t) => t.driverConfirmedAt == null).length;
          final urgent = all.where((t) => t.status == statusUrgentChange).length;
          final cancelled = all.where((t) => t.status == statusCancelled).length;
          final problems = all.where((t) => t.hasProblem).length;
          final done = all.where((t) => t.status == statusDone).length;
          final needsAttention = all.where((t) => t.needsAttention).toList();

          return ListView(
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Metric('Рейсов сегодня', data.today.length.toString(), AppColors.blue),
                  _Metric('Рейсов завтра', data.tomorrow.length.toString(), AppColors.blue),
                  _Metric('Гостей сегодня', todayGuests.toString(), AppColors.turquoise),
                  _Metric('Гостей завтра', tomorrowGuests.toString(), AppColors.turquoise),
                  _Metric('Без водителя', withoutDriver.toString(), AppColors.orange),
                  _Metric('Без машины', withoutVehicle.toString(), AppColors.orange),
                  _Metric('Не подтверждено', unconfirmed.toString(), AppColors.orange),
                  _Metric('Срочные изменения', urgent.toString(), AppColors.orange),
                  _Metric('Отмен', cancelled.toString(), AppColors.gray),
                  _Metric('Проблем', problems.toString(), AppColors.red),
                  _Metric('Выполнено', done.toString(), AppColors.green),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Требуют внимания',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (needsAttention.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Критичных задач нет',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else
                ...needsAttention.map(
                  (trip) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber, color: AppColors.orange),
                      title: Text(
                        '${trip.tripCode} · ${displayTime(trip.vehicleTime)} · ${trip.direction}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${trip.vehicle ?? 'без машины'} · ${trip.driverName ?? 'без водителя'} · ${trip.status}',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.title, this.value, this.color);

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlData {
  _ControlData({
    required this.today,
    required this.tomorrow,
  });

  final List<Trip> today;
  final List<Trip> tomorrow;
}

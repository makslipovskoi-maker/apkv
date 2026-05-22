import 'package:flutter/material.dart';

import '../../core/date_time_utils.dart';
import '../../models/app_user.dart';
import '../../models/trip.dart';
import '../../repositories/app_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class MechanicScreen extends StatefulWidget {
  const MechanicScreen({
    super.key,
    required this.user,
    required this.showTomorrow,
  });

  final AppUser user;
  final bool showTomorrow;

  @override
  State<MechanicScreen> createState() => _MechanicScreenState();
}

class _MechanicScreenState extends State<MechanicScreen> {
  final _repo = AppRepository();
  late Future<List<Trip>> _future;

  DateTime get _date => widget.showTomorrow ? tomorrowOnly() : todayOnly();

  @override
  void initState() {
    super.initState();
    _future = _repo.trips(date: _date);
  }

  void _refresh() {
    setState(() => _future = _repo.trips(date: _date));
  }

  Future<void> _setVehicleStatus(String vehicle, String status) async {
    String? comment;
    if (status != 'ГОТОВА') {
      final controller = TextEditingController();
      comment = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$vehicle: $status'),
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
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('СОХРАНИТЬ'),
            ),
          ],
        ),
      );
      if (comment == null) return;
    }

    try {
      await _repo.setMechanicStatus(
        user: widget.user,
        date: _date,
        vehicle: vehicle,
        status: status,
        comment: comment,
      );
      if (!mounted) return;
      showAppMessage(context, 'Статус транспорта сохранён');
      _refresh();
    } catch (_) {
      if (!mounted) return;
      showAppMessage(context, 'Нет связи с сервером');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.showTomorrow ? 'Транспорт завтра' : 'Транспорт сегодня',
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
          final groups = <String, List<Trip>>{};
          for (final trip in trips) {
            final vehicle = trip.vehicle?.isNotEmpty == true ? trip.vehicle! : 'Без машины';
            groups.putIfAbsent(vehicle, () => []).add(trip);
          }
          if (groups.isEmpty) return const EmptyState(text: 'Рейсов нет');

          return ListView(
            children: groups.entries.map((entry) {
              return _VehicleCard(
                vehicle: entry.key,
                trips: entry.value,
                onReady: () => _setVehicleStatus(entry.key, 'ГОТОВА'),
                onNotReady: () => _setVehicleStatus(entry.key, 'НЕ ГОТОВА'),
                onReplace: () => _setVehicleStatus(entry.key, 'НУЖНА ЗАМЕНА'),
                onProblem: () => _setVehicleStatus(entry.key, 'ПРОБЛЕМА'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.trips,
    required this.onReady,
    required this.onNotReady,
    required this.onReplace,
    required this.onProblem,
  });

  final String vehicle;
  final List<Trip> trips;
  final VoidCallback onReady;
  final VoidCallback onNotReady;
  final VoidCallback onReplace;
  final VoidCallback onProblem;

  @override
  Widget build(BuildContext context) {
    final totalPeople = trips.fold<int>(0, (sum, trip) => sum + trip.peopleCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vehicle,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Рейсов: ${trips.length} · гостей: $totalPeople',
              style: const TextStyle(fontSize: 18, color: AppColors.deepBlue),
            ),
            const Divider(height: 24),
            ...trips.map(
              (trip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  '${displayTime(trip.vehicleTime)} — ${trip.direction} — ${trip.peopleCount} чел. — ${trip.driverName ?? 'водитель не назначен'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (vehicle == 'Без машины')
              const Text(
                'Сначала регистратор должен назначить машину.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              )
            else ...[
              BigActionButton(
                label: 'ГОТОВА',
                onPressed: onReady,
                color: AppColors.green,
                icon: Icons.check_circle_outline,
              ),
              BigActionButton(
                label: 'НЕ ГОТОВА',
                onPressed: onNotReady,
                color: AppColors.red,
                icon: Icons.cancel_outlined,
              ),
              BigActionButton(
                label: 'НУЖНА ЗАМЕНА',
                onPressed: onReplace,
                color: AppColors.orange,
                icon: Icons.swap_horiz,
              ),
              BigActionButton(
                label: 'ПРОБЛЕМА',
                onPressed: onProblem,
                color: AppColors.red,
                icon: Icons.report_problem_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/date_time_utils.dart';
import '../../models/app_user.dart';
import '../../models/trip.dart';
import '../../repositories/app_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'create_trip_screen.dart';

class TwoWeekScheduleScreen extends StatefulWidget {
  const TwoWeekScheduleScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<TwoWeekScheduleScreen> createState() => _TwoWeekScheduleScreenState();
}

class _TwoWeekScheduleScreenState extends State<TwoWeekScheduleScreen> {
  final _repo = AppRepository();
  late Future<List<Trip>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Trip>> _load() async {
    final start = todayOnly();
    final end = start.add(const Duration(days: 13));
    final trips = await _repo.trips();
    return trips.where((trip) {
      final date = DateTime.tryParse(trip.departureDate);
      if (date == null) return false;
      final only = DateTime(date.year, date.month, date.day);
      return !only.isBefore(start) && !only.isAfter(end);
    }).toList();
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  Map<String, List<Trip>> _groupByDate(List<Trip> trips) {
    final result = <String, List<Trip>>{};
    final start = todayOnly();
    for (var i = 0; i < 14; i++) {
      final date = dbDate(start.add(Duration(days: i)));
      result[date] = [];
    }
    for (final trip in trips) {
      result.putIfAbsent(trip.departureDate, () => []).add(trip);
    }
    for (final rows in result.values) {
      rows.sort((a, b) => (a.vehicleTime ?? '').compareTo(b.vehicleTime ?? ''));
    }
    return result;
  }

  void _createTrip() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateTripScreen(user: widget.user)),
    ).then((_) => _refresh());
  }

  void _showTrip(Trip trip) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Рейс ${trip.tripCode}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              StatusBadge(status: trip.status),
              const SizedBox(height: 14),
              InfoRow('Дата', displayDate(trip.departureDate), icon: Icons.event),
              InfoRow('Подача', displayTime(trip.vehicleTime), icon: Icons.schedule),
              InfoRow('Корпус', trip.corps, icon: Icons.business_outlined),
              InfoRow('Комната', trip.room, icon: Icons.meeting_room_outlined),
              InfoRow('Гость', trip.guestName, icon: Icons.person_outline),
              InfoRow('Людей', trip.peopleCount.toString(), icon: Icons.people_outline),
              InfoRow('Куда', trip.direction, icon: Icons.place_outlined),
              InfoRow('Билет', displayTime(trip.ticketTime), icon: Icons.confirmation_num_outlined),
              InfoRow('Машина', trip.vehicle, icon: Icons.directions_bus_outlined),
              InfoRow('Водитель', trip.driverName, icon: Icons.badge_outlined),
              if (trip.comment != null && trip.comment!.trim().isNotEmpty) InfoRow('Комментарий', trip.comment),
              if (trip.problem != null && trip.problem!.trim().isNotEmpty) InfoRow('Проблема', trip.problem),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = todayOnly();
    final end = start.add(const Duration(days: 13));
    return Scaffold(
      appBar: AppBar(
        title: const Text('График на 2 недели'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTrip,
        icon: const Icon(Icons.add_road_outlined),
        label: const Text('Создать рейс'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: appBackgroundGradient),
        child: SafeArea(
          child: FutureBuilder<List<Trip>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const EmptyState(text: 'Нет связи с сервером', icon: Icons.cloud_off_outlined);
              final trips = snapshot.data ?? [];
              final groups = _groupByDate(trips);
              final guests = trips.fold<int>(0, (sum, trip) => sum + trip.peopleCount);
              final attention = trips.where((trip) => trip.needsAttention).length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  PremiumHeroCard(
                    title: '2 недели: ${trips.length} рейсов',
                    subtitle: '${displayDate(dbDate(start))} — ${displayDate(dbDate(end))}\nГостей: $guests · Требуют внимания: $attention',
                    trailing: const Icon(Icons.table_chart_outlined, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 14),
                  for (final entry in groups.entries) _DayTable(date: entry.key, trips: entry.value, onTap: _showTrip),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DayTable extends StatelessWidget {
  const _DayTable({required this.date, required this.trips, required this.onTap});

  final String date;
  final List<Trip> trips;
  final void Function(Trip trip) onTap;

  @override
  Widget build(BuildContext context) {
    final guests = trips.fold<int>(0, (sum, trip) => sum + trip.peopleCount);
    return Card(
      child: ExpansionTile(
        initiallyExpanded: trips.isNotEmpty,
        title: Text(displayDate(date), style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('Рейсов: ${trips.length} · Гостей: $guests'),
        children: [
          if (trips.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('На этот день рейсов нет', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.lightTurquoise),
                columns: const [
                  DataColumn(label: Text('Время')),
                  DataColumn(label: Text('Корпус')),
                  DataColumn(label: Text('Гость')),
                  DataColumn(label: Text('Людей')),
                  DataColumn(label: Text('Куда')),
                  DataColumn(label: Text('Машина')),
                  DataColumn(label: Text('Водитель')),
                  DataColumn(label: Text('Статус')),
                ],
                rows: trips.map((trip) {
                  return DataRow(
                    onSelectChanged: (_) => onTap(trip),
                    cells: [
                      DataCell(Text(displayTime(trip.vehicleTime))),
                      DataCell(Text('${trip.corps}, ${trip.room}')),
                      DataCell(Text(trip.guestName)),
                      DataCell(Text(trip.peopleCount.toString())),
                      DataCell(Text(trip.direction)),
                      DataCell(Text(trip.vehicle ?? '—')),
                      DataCell(Text(trip.driverName ?? '—')),
                      DataCell(StatusBadge(status: trip.status)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

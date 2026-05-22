import 'package:flutter/material.dart';

import '../../core/date_time_utils.dart';
import '../../models/app_user.dart';
import '../../models/trip.dart';
import '../../repositories/app_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'create_trip_screen.dart';

class TwoWeekCalendarScreen extends StatefulWidget {
  const TwoWeekCalendarScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<TwoWeekCalendarScreen> createState() => _TwoWeekCalendarScreenState();
}

class _TwoWeekCalendarScreenState extends State<TwoWeekCalendarScreen> {
  final _repo = AppRepository();
  late Future<List<Trip>> _future;

  static const _weekDays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

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
      final parsed = DateTime.tryParse(trip.departureDate);
      if (parsed == null) return false;
      final date = DateTime(parsed.year, parsed.month, parsed.day);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  void _refresh() => setState(() => _future = _load());

  List<DateTime> get _days => List.generate(14, (i) => todayOnly().add(Duration(days: i)));

  Map<String, List<Trip>> _groups(List<Trip> trips) {
    final map = <String, List<Trip>>{};
    for (final day in _days) {
      map[dbDate(day)] = [];
    }
    for (final trip in trips) {
      map.putIfAbsent(trip.departureDate, () => []).add(trip);
    }
    for (final rows in map.values) {
      rows.sort((a, b) => (a.vehicleTime ?? '').compareTo(b.vehicleTime ?? ''));
    }
    return map;
  }

  void _createTrip() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CreateTripScreen(user: widget.user)))
        .then((_) => _refresh());
  }

  void _openDay(String date, List<Trip> trips) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayDate(date), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.deepBlue)),
              const SizedBox(height: 8),
              if (trips.isEmpty)
                const Card(child: ListTile(leading: Icon(Icons.event_available_outlined), title: Text('На этот день рейсов нет')))
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: trips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _TripListTile(trip: trips[i], onTap: () => _openTrip(trips[i])),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createTrip,
                  icon: const Icon(Icons.add_road_outlined),
                  label: const Text('СОЗДАТЬ РЕЙС'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTrip(Trip trip) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Рейс ${trip.tripCode}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.deepBlue)),
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
              InfoRow('Машина', trip.vehicle, icon: Icons.directions_bus_outlined),
              InfoRow('Водитель', trip.driverName, icon: Icons.badge_outlined),
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
        title: const Text('Календарь выездов'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTrip,
        icon: const Icon(Icons.add),
        label: const Text('Рейс'),
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
              final groups = _groups(trips);
              final guests = trips.fold<int>(0, (sum, trip) => sum + trip.peopleCount);
              final attention = trips.where((trip) => trip.needsAttention).length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                children: [
                  PremiumHeroCard(
                    title: 'Календарь на 2 недели',
                    subtitle: '${displayDate(dbDate(start))} — ${displayDate(dbDate(end))}\nРейсов: ${trips.length} · Гостей: $guests · Внимание: $attention',
                    trailing: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1120,
                      child: Column(
                        children: [
                          Row(children: [for (final d in _weekDays) Expanded(child: _WeekHeader(d))]),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 7,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 0.92,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              for (final day in _days)
                                _CalendarDay(
                                  date: dbDate(day),
                                  trips: groups[dbDate(day)] ?? const [],
                                  isToday: dbDate(day) == dbDate(todayOnly()),
                                  onTap: () => _openDay(dbDate(day), groups[dbDate(day)] ?? const []),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.deepBlue, borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.date, required this.trips, required this.isToday, required this.onTap});
  final String date;
  final List<Trip> trips;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final guests = trips.fold<int>(0, (sum, trip) => sum + trip.peopleCount);
    final problems = trips.where((trip) => trip.needsAttention).length;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(displayDate(date), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue))),
                  if (isToday) const Icon(Icons.today, color: AppColors.blue, size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Text('Рейсов: ${trips.length} · Гостей: $guests', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gray)),
              if (problems > 0) Text('Внимание: $problems', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.orange)),
              const SizedBox(height: 6),
              Expanded(
                child: trips.isEmpty
                    ? const Center(child: Text('—', style: TextStyle(color: AppColors.gray)))
                    : ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final trip in trips.take(4))
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(color: trip.needsAttention ? AppColors.orange.withValues(alpha: 0.14) : AppColors.lightTurquoise, borderRadius: BorderRadius.circular(10)),
                              child: Text('${displayTime(trip.vehicleTime)} ${trip.corps} · ${trip.peopleCount} чел.', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                            ),
                          if (trips.length > 4) Text('+ ещё ${trips.length - 4}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.blue)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripListTile extends StatelessWidget {
  const _TripListTile({required this.trip, required this.onTap});
  final Trip trip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: const Icon(Icons.route_outlined, color: AppColors.blue),
          title: Text('${displayTime(trip.vehicleTime)} · ${trip.corps}, ${trip.room}', style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${trip.guestName} · ${trip.peopleCount} чел. · ${trip.direction}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

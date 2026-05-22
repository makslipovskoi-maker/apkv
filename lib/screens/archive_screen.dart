import 'package:flutter/material.dart';

import '../core/date_time_utils.dart';
import '../models/app_user.dart';
import '../models/trip.dart';
import '../repositories/app_repository.dart';
import '../widgets/app_widgets.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _repo = AppRepository();
  late Future<List<Trip>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.trips(archive: true);
  }

  void _refresh() {
    setState(() => _future = _repo.trips(archive: true));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Архив',
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
          if (trips.isEmpty) return const EmptyState(text: 'Архив пуст');

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Рейс ${trip.tripCode}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(status: trip.status),
                      const SizedBox(height: 8),
                      InfoRow('Дата', displayDate(trip.departureDate)),
                      InfoRow('Машина', trip.vehicle),
                      InfoRow('Водитель', trip.driverName),
                      InfoRow('Направление', trip.direction),
                      InfoRow('Гостей', trip.peopleCount.toString()),
                      InfoRow('Проблемы', trip.problem),
                      InfoRow('Закрыт', displayDateTime(trip.completedAt)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

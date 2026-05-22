import 'package:flutter/material.dart';

import '../../core/date_time_utils.dart';
import '../../models/app_user.dart';
import '../../models/request_model.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/app_widgets.dart';
import 'trip_editor_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _repo = AppRepository();
  late Future<List<GuestRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.requests(onlyActive: true);
  }

  void _refresh() {
    setState(() => _future = _repo.requests(onlyActive: true));
  }

  Future<void> _openCreateTrip(GuestRequest request) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripEditorScreen(user: widget.user, request: request),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Заявки',
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
      ],
      child: FutureBuilder<List<GuestRequest>>(
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
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const EmptyState(text: 'Новых заявок нет');

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _RequestCard(
              request: items[index],
              onCreateTrip: () => _openCreateTrip(items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onCreateTrip});

  final GuestRequest request;
  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  request.guestName,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            InfoRow('Корпус', request.corps, icon: Icons.business),
            InfoRow('Комната', request.room, icon: Icons.meeting_room_outlined),
            InfoRow('Дата', displayDate(request.departureDate), icon: Icons.event),
            InfoRow('Людей', request.peopleCount.toString(), icon: Icons.people),
            InfoRow('Багаж', request.baggage, icon: Icons.work_outline),
            InfoRow('Куда', request.direction, icon: Icons.place_outlined),
            InfoRow('Адрес', request.destination),
            InfoRow('Билет', displayTime(request.ticketTime), icon: Icons.schedule),
            if (request.comment != null && request.comment!.isNotEmpty)
              InfoRow('Комментарий', request.comment),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onCreateTrip,
              icon: const Icon(Icons.add_road),
              label: const Text('СОЗДАТЬ РЕЙС'),
            ),
          ],
        ),
      ),
    );
  }
}

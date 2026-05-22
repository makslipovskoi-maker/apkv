import 'package:flutter/material.dart';

import '../core/date_time_utils.dart';
import '../models/app_user.dart';
import '../models/request_model.dart';
import '../repositories/app_repository.dart';
import '../widgets/app_widgets.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _repo = AppRepository();
  late Future<List<GuestRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.requests(corps: widget.user.corps);
  }

  void _refresh() {
    setState(() => _future = _repo.requests(corps: widget.user.corps));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Мои заявки',
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
          if (items.isEmpty) {
            return const EmptyState(text: 'Заявок пока нет');
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _RequestCard(request: items[index]),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final GuestRequest request;

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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            InfoRow('Дата', displayDate(request.departureDate), icon: Icons.event),
            InfoRow('Комната', request.room, icon: Icons.meeting_room_outlined),
            InfoRow('Людей', request.peopleCount.toString(), icon: Icons.people),
            InfoRow('Куда', request.direction, icon: Icons.place_outlined),
            InfoRow('Билет', displayTime(request.ticketTime), icon: Icons.schedule),
            if (request.comment != null && request.comment!.isNotEmpty)
              InfoRow('Комментарий', request.comment),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/request_model.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/app_widgets.dart';
import 'trip_editor_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _repo = AppRepository();
  late Future<List<GuestRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.requests(onlyActive: true);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Создать рейс',
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

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const EmptyState(text: 'Нет заявок для создания рейса');
          }

          return ListView(
            children: [
              const Text(
                'Выберите заявку, из которой нужно создать рейс.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...requests.map(
                (request) => Card(
                  child: ListTile(
                    title: Text(
                      request.guestName,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('${request.corps}, комн. ${request.room}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => TripEditorScreen(
                          user: widget.user,
                          request: request,
                        ),
                      ),
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

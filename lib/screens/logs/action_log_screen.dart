import 'package:flutter/material.dart';

import '../../core/date_time_utils.dart';
import '../../models/action_log_entry.dart';
import '../../models/app_user.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/app_widgets.dart';

class ActionLogScreen extends StatefulWidget {
  const ActionLogScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ActionLogScreen> createState() => _ActionLogScreenState();
}

class _ActionLogScreenState extends State<ActionLogScreen> {
  final _repo = AppRepository();
  late Future<List<ActionLogEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.actionLog();
  }

  void _refresh() {
    setState(() => _future = _repo.actionLog());
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Журнал изменений',
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
      ],
      child: FutureBuilder<List<ActionLogEntry>>(
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

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) return const EmptyState(text: 'Журнал пуст');

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.action,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InfoRow('Время', displayDateTime(entry.createdAt)),
                      InfoRow('Кто', entry.userName),
                      InfoRow('Роль', entry.role),
                      InfoRow('Было', entry.oldValue),
                      InfoRow('Стало', entry.newValue),
                      InfoRow('Причина', entry.reason),
                      InfoRow('Срочность', entry.urgency),
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

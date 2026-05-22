import 'package:flutter/material.dart';

import '../models/action_log_entry.dart';
import '../models/app_user.dart';
import '../repositories/app_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = AppRepository();
  late Future<List<ActionLogEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ActionLogEntry>> _load() async {
    final entries = await _repo.actionLog();
    return entries.take(80).toList();
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Оповещения',
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
              text: 'Не удалось загрузить оповещения',
              icon: Icons.cloud_off_outlined,
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const EmptyState(
              text: 'Пока нет оповещений',
              icon: Icons.notifications_none_outlined,
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _NotificationCard(entry: items[index]),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.entry});

  final ActionLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = _color(entry);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(_icon(entry), color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.action,
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _subtitle(entry),
                    style: const TextStyle(
                      color: AppColors.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (entry.reason != null && entry.reason!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Причина: ${entry.reason}',
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  if (entry.newValue != null && entry.newValue!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.newValue!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(ActionLogEntry entry) {
    final user = entry.userName?.trim().isNotEmpty == true ? entry.userName! : 'Система';
    final role = entry.role?.trim().isNotEmpty == true ? ' · ${entry.role}' : '';
    final urgency = entry.urgency?.trim().isNotEmpty == true ? ' · ${entry.urgency}' : '';
    return '$user$role$urgency';
  }

  IconData _icon(ActionLogEntry entry) {
    final text = '${entry.action} ${entry.newValue ?? ''}'.toLowerCase();
    if (text.contains('проблем')) return Icons.report_problem_outlined;
    if (text.contains('сроч')) return Icons.notification_important_outlined;
    if (text.contains('водитель')) return Icons.directions_car_outlined;
    if (text.contains('механик') || text.contains('транспорт')) return Icons.handyman_outlined;
    if (text.contains('заявк')) return Icons.assignment_outlined;
    return Icons.notifications_outlined;
  }

  Color _color(ActionLogEntry entry) {
    final text = '${entry.action} ${entry.newValue ?? ''}'.toLowerCase();
    if (text.contains('проблем')) return AppColors.red;
    if (text.contains('сроч')) return AppColors.orange;
    if (text.contains('подтверд') || text.contains('готов')) return AppColors.green;
    return AppColors.blue;
  }
}

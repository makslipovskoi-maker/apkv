import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/offline_queue.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'archive_screen.dart';
import 'change_request_screen.dart';
import 'control_panel_screen.dart';
import 'driver/driver_trips_screen.dart';
import 'login_screen.dart';
import 'logs/action_log_screen.dart';
import 'mechanic/mechanic_screen.dart';
import 'my_requests_screen.dart';
import 'registrar/create_trip_screen.dart';
import 'registrar/requests_screen.dart';
import 'request_form_screen.dart';
import 'schedule_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.user});

  final AppUser user;

  List<_MenuItem> _items() {
    switch (user.role) {
      case UserRole.registrar:
        return [
          _MenuItem('Заявки', Icons.assignment_outlined,
              () => RequestsScreen(user: user)),
          _MenuItem('Главный график', Icons.calendar_month_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.all)),
          _MenuItem('Создать рейс', Icons.add_road_outlined,
              () => CreateTripScreen(user: user)),
          _MenuItem('Рейсы сегодня', Icons.today_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.today)),
          _MenuItem('Рейсы завтра', Icons.event_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.tomorrow)),
          _MenuItem('Срочные изменения', Icons.notification_important_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.urgent)),
          _MenuItem('Проблемы', Icons.report_problem_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.problems)),
          _MenuItem('Журнал изменений', Icons.history_outlined,
              () => ActionLogScreen(user: user)),
          _MenuItem('Панель контроля', Icons.dashboard_outlined,
              () => ControlPanelScreen(user: user)),
          _MenuItem('Архив', Icons.archive_outlined,
              () => ArchiveScreen(user: user)),
        ];
      case UserRole.corps:
        return [
          _MenuItem('Подать заявку', Icons.post_add_outlined,
              () => RequestFormScreen(user: user)),
          _MenuItem('Изменить / отменить заявку', Icons.edit_note_outlined,
              () => ChangeRequestScreen(user: user)),
          _MenuItem('Мои заявки', Icons.list_alt_outlined,
              () => MyRequestsScreen(user: user)),
        ];
      case UserRole.driver:
        return [
          _MenuItem('Мои рейсы сегодня', Icons.today_outlined,
              () => DriverTripsScreen(user: user, showTomorrow: false)),
          _MenuItem('Мои рейсы завтра', Icons.event_outlined,
              () => DriverTripsScreen(user: user, showTomorrow: true)),
        ];
      case UserRole.mechanic:
        return [
          _MenuItem('Транспорт сегодня', Icons.directions_bus_outlined,
              () => MechanicScreen(user: user, showTomorrow: false)),
          _MenuItem('Транспорт завтра', Icons.event_available_outlined,
              () => MechanicScreen(user: user, showTomorrow: true)),
          _MenuItem('Проблемы транспорта', Icons.car_crash_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.problems)),
        ];
      case UserRole.manager:
        return [
          _MenuItem('Главный график', Icons.calendar_month_outlined,
              () => ScheduleScreen(user: user, mode: ScheduleMode.all)),
          _MenuItem('Панель контроля', Icons.dashboard_outlined,
              () => ControlPanelScreen(user: user)),
          _MenuItem('Журнал изменений', Icons.history_outlined,
              () => ActionLogScreen(user: user)),
          _MenuItem('Архив', Icons.archive_outlined,
              () => ArchiveScreen(user: user)),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return Scaffold(
      appBar: AppBar(
        title: Text(user.role.title),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const LogoHeader(compact: true),
            const SizedBox(height: 16),
            Card(
              color: AppColors.sand,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${user.name}\n${user.corps ?? user.driverName ?? user.vehicle ?? ''}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlue,
                  ),
                ),
              ),
            ),
            if (OfflineQueue.instance.pendingCount > 0)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_off, color: AppColors.orange),
                  title: const Text('Есть несинхронизированные действия'),
                  subtitle: Text('Ожидают отправки: ${OfflineQueue.instance.pendingCount}'),
                ),
              ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.lightTurquoise,
                    child: Icon(item.icon, color: AppColors.blue),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => item.builder()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  _MenuItem(this.title, this.icon, this.builder);

  final String title;
  final IconData icon;
  final Widget Function() builder;
}

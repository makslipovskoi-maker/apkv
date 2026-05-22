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
import 'notifications_screen.dart';
import 'registrar/create_trip_screen.dart';
import 'registrar/requests_screen.dart';
import 'registrar/two_week_schedule_screen.dart';
import 'request_form_screen.dart';
import 'schedule_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.user});

  final AppUser user;

  List<_MenuItem> _items() {
    final notifications = _MenuItem('Оповещения', 'Все изменения и важные события', Icons.notifications_active_outlined, () => NotificationsScreen(user: user));
    switch (user.role) {
      case UserRole.registrar:
        return [
          notifications,
          _MenuItem('График на 2 недели', 'Таблица рейсов по дням', Icons.table_chart_outlined, () => TwoWeekScheduleScreen(user: user)),
          _MenuItem('Заявки', 'Новые заявки от корпусов', Icons.assignment_outlined, () => RequestsScreen(user: user)),
          _MenuItem('Главный график', 'Все рейсы и выезды', Icons.calendar_month_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.all)),
          _MenuItem('Создать рейс', 'Назначить время, машину и водителя', Icons.add_road_outlined, () => CreateTripScreen(user: user)),
          _MenuItem('Рейсы сегодня', 'Текущие выезды', Icons.today_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.today)),
          _MenuItem('Рейсы завтра', 'План на завтра', Icons.event_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.tomorrow)),
          _MenuItem('Срочные изменения', 'То, что нельзя пропустить', Icons.notification_important_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.urgent)),
          _MenuItem('Проблемы', 'Конфликты и сбои', Icons.report_problem_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.problems)),
          _MenuItem('Журнал изменений', 'Кто и что изменил', Icons.history_outlined, () => ActionLogScreen(user: user)),
          _MenuItem('Панель контроля', 'Сводка по рейсам', Icons.dashboard_outlined, () => ControlPanelScreen(user: user)),
          _MenuItem('Архив', 'Выполненные выезды', Icons.archive_outlined, () => ArchiveScreen(user: user)),
        ];
      case UserRole.corps:
        return [
          notifications,
          _MenuItem('Подать заявку', 'Передать гостя регистратору', Icons.post_add_outlined, () => RequestFormScreen(user: user)),
          _MenuItem('Изменить / отменить', 'Билеты, время, багаж, отмена', Icons.edit_note_outlined, () => ChangeRequestScreen(user: user)),
          _MenuItem('Мои заявки', 'Статусы заявок корпуса', Icons.list_alt_outlined, () => MyRequestsScreen(user: user)),
        ];
      case UserRole.driver:
        return [
          notifications,
          _MenuItem('Мои рейсы сегодня', 'Крупные кнопки для работы', Icons.today_outlined, () => DriverTripsScreen(user: user, showTomorrow: false)),
          _MenuItem('Мои рейсы завтра', 'План заранее', Icons.event_outlined, () => DriverTripsScreen(user: user, showTomorrow: true)),
        ];
      case UserRole.mechanic:
        return [
          notifications,
          _MenuItem('Транспорт сегодня', 'Готовность машин', Icons.directions_bus_outlined, () => MechanicScreen(user: user, showTomorrow: false)),
          _MenuItem('Транспорт завтра', 'Подготовка заранее', Icons.event_available_outlined, () => MechanicScreen(user: user, showTomorrow: true)),
          _MenuItem('Проблемы транспорта', 'Замена, поломки, риски', Icons.car_crash_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.problems)),
        ];
      case UserRole.manager:
        return [
          notifications,
          _MenuItem('Главный график', 'Вся картина по выездам', Icons.calendar_month_outlined, () => ScheduleScreen(user: user, mode: ScheduleMode.all)),
          _MenuItem('Панель контроля', 'Цифры, риски, контроль', Icons.dashboard_outlined, () => ControlPanelScreen(user: user)),
          _MenuItem('Журнал изменений', 'Прозрачность действий', Icons.history_outlined, () => ActionLogScreen(user: user)),
          _MenuItem('Архив', 'История выполненных рейсов', Icons.archive_outlined, () => ArchiveScreen(user: user)),
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
            tooltip: 'Оповещения',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsScreen(user: user))),
          ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: appBackgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const LogoHeader(compact: true),
                  const SizedBox(height: 18),
                  PremiumHeroCard(
                    title: 'Рабочий центр',
                    subtitle: '${user.name}\n${user.corps ?? user.driverName ?? user.vehicle ?? 'Служебный доступ'}',
                    trailing: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(_roleIcon(user.role), color: AppColors.blue, size: 32),
                    ),
                  ),
                  if (OfflineQueue.instance.pendingCount > 0) ...[
                    const SizedBox(height: 14),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.cloud_off, color: AppColors.orange),
                        title: const Text('Есть несинхронизированные действия'),
                        subtitle: Text('Ожидают отправки: ${OfflineQueue.instance.pendingCount}'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.18 : 3.35,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _DashboardTile(
                        item: item,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.builder())),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.registrar:
        return Icons.manage_accounts_outlined;
      case UserRole.corps:
        return Icons.apartment_outlined;
      case UserRole.driver:
        return Icons.directions_car_outlined;
      case UserRole.mechanic:
        return Icons.handyman_outlined;
      case UserRole.manager:
        return Icons.insights_outlined;
    }
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({required this.item, required this.onTap});

  final _MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: AppColors.lightTurquoise, borderRadius: BorderRadius.circular(20)),
                child: Icon(item.icon, color: AppColors.blue, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.deepBlue, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.gray, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  _MenuItem(this.title, this.subtitle, this.icon, this.builder);

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;
}

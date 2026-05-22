import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/date_time_utils.dart';
import '../core/smart_suggestions.dart';
import '../models/app_user.dart';
import '../repositories/app_repository.dart';
import '../services/offline_queue.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AppRepository();
  late final TextEditingController _corps;
  final _room = TextEditingController();
  final _guestName = TextEditingController();
  final _peopleCount = TextEditingController(text: '1');
  final _destination = TextEditingController();
  final _ticketTime = TextEditingController();
  final _comment = TextEditingController();
  DateTime _departureDate = tomorrowOnly();
  String? _direction;
  String? _baggage;
  bool _transferNeeded = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _corps = TextEditingController(text: widget.user.corps ?? 'Корпус 1');
  }

  @override
  void dispose() {
    _corps.dispose();
    _room.dispose();
    _guestName.dispose();
    _peopleCount.dispose();
    _destination.dispose();
    _ticketTime.dispose();
    _comment.dispose();
    super.dispose();
  }

  int get _people => int.tryParse(_peopleCount.text.trim()) ?? 1;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: todayOnly(),
      lastDate: todayOnly().add(const Duration(days: 365)),
      locale: const Locale('ru'),
    );
    if (selected != null) setState(() => _departureDate = selected);
  }

  Map<String, dynamic> _payload() => {
        'corps': _corps.text.trim(),
        'room': _room.text.trim(),
        'guest_name': _guestName.text.trim(),
        'people_count': _people,
        'baggage': _baggage ?? '',
        'departure_date': dbDate(_departureDate),
        'direction': _direction ?? '',
        'destination': _destination.text.trim(),
        'ticket_time': normalizeTime(_ticketTime.text).isEmpty ? null : normalizeTime(_ticketTime.text),
        'transfer_needed': _transferNeeded,
        'comment': _comment.text.trim(),
        'status': statusNewRequest,
        'created_by': widget.user.id,
      };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_direction == null || _baggage == null) {
      showAppMessage(context, 'Выберите направление и багаж');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отправить заявку?'),
        content: Text('${_guestName.text}\n${displayDate(dbDate(_departureDate))}\n$_direction\n${SmartSuggestions.vehicleHint(_people)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ПРОВЕРИТЬ')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('ОТПРАВИТЬ')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _loading = true);
    final data = _payload();
    try {
      await _repo.createRequest(data, widget.user);
      if (!mounted) return;
      showAppMessage(context, 'Заявка отправлена регистратору');
      Navigator.of(context).pop();
    } catch (_) {
      await OfflineQueue.instance.enqueue('create_request', data);
      if (!mounted) return;
      showAppMessage(context, 'Нет связи. Заявка сохранена локально.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Подать заявку',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const PremiumHeroCard(title: 'Новая заявка', subtitle: 'Выберите готовые варианты — так быстрее и меньше ошибок.'),
            const SizedBox(height: 16),
            TextFormField(controller: _corps, readOnly: widget.user.role == UserRole.corps, decoration: const InputDecoration(labelText: 'Корпус'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _room, decoration: const InputDecoration(labelText: 'Номер комнаты'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _guestName, decoration: const InputDecoration(labelText: 'ФИО гостя или группа'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _peopleCount, decoration: const InputDecoration(labelText: 'Количество человек'), keyboardType: TextInputType.number, validator: _required, onChanged: (_) => setState(() {})),
            const SizedBox(height: 8),
            Card(child: ListTile(leading: const Icon(Icons.auto_awesome_outlined, color: AppColors.blue), title: Text(SmartSuggestions.vehicleHint(_people)))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _baggage, decoration: const InputDecoration(labelText: 'Багаж'), items: SmartSuggestions.baggage.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _baggage = v), validator: (v) => v == null ? 'Выберите багаж' : null),
            const SizedBox(height: 12),
            Card(child: ListTile(leading: const Icon(Icons.event, color: AppColors.blue), title: const Text('Дата выезда'), subtitle: Text(displayDate(dbDate(_departureDate))), trailing: const Icon(Icons.edit_calendar), onTap: _pickDate)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _direction, decoration: const InputDecoration(labelText: 'Направление'), items: SmartSuggestions.directions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() { _direction = v; _destination.text = v ?? ''; }), validator: (v) => v == null ? 'Выберите направление' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _destination, decoration: const InputDecoration(labelText: 'Станция / аэропорт / адрес')),
            const SizedBox(height: 12),
            TextFormField(controller: _ticketTime, decoration: const InputDecoration(labelText: 'Время билета, например 14:30'), keyboardType: TextInputType.datetime),
            const SizedBox(height: 12),
            SwitchListTile(value: _transferNeeded, title: const Text('Нужен трансфер'), activeColor: AppColors.green, onChanged: (v) => setState(() => _transferNeeded = v)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Быстрый комментарий'), items: SmartSuggestions.comments.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _comment.text = v ?? '')),
            const SizedBox(height: 12),
            TextFormField(controller: _comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Комментарий вручную')),
            const SizedBox(height: 18),
            ElevatedButton.icon(onPressed: _loading ? null : _submit, icon: const Icon(Icons.send_outlined), label: Text(_loading ? 'ОТПРАВКА...' : 'ОТПРАВИТЬ ЗАЯВКУ')),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Заполните поле' : null;
}

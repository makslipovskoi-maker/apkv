import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/date_time_utils.dart';
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
  final _baggage = TextEditingController();
  final _direction = TextEditingController();
  final _destination = TextEditingController();
  final _ticketTime = TextEditingController();
  final _comment = TextEditingController();

  DateTime _departureDate = tomorrowOnly();
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
    _baggage.dispose();
    _direction.dispose();
    _destination.dispose();
    _ticketTime.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: todayOnly(),
      lastDate: todayOnly().add(const Duration(days: 365)),
      locale: const Locale('ru'),
    );
    if (selected != null) {
      setState(() => _departureDate = selected);
    }
  }

  Map<String, dynamic> _payload() {
    return {
      'corps': _corps.text.trim(),
      'room': _room.text.trim(),
      'guest_name': _guestName.text.trim(),
      'people_count': int.tryParse(_peopleCount.text.trim()) ?? 1,
      'baggage': _baggage.text.trim(),
      'departure_date': dbDate(_departureDate),
      'direction': _direction.text.trim(),
      'destination': _destination.text.trim(),
      'ticket_time': normalizeTime(_ticketTime.text).isEmpty
          ? null
          : normalizeTime(_ticketTime.text),
      'transfer_needed': _transferNeeded,
      'comment': _comment.text.trim(),
      'status': statusNewRequest,
      'created_by': widget.user.id,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      showAppMessage(
        context,
        'Нет связи с сервером. Заявка сохранена локально и не потеряна.',
      );
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
            TextFormField(
              controller: _corps,
              readOnly: widget.user.role == UserRole.corps,
              decoration: const InputDecoration(labelText: 'Корпус'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _room,
              decoration: const InputDecoration(labelText: 'Номер комнаты'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guestName,
              decoration: const InputDecoration(labelText: 'ФИО гостя'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _peopleCount,
              decoration: const InputDecoration(labelText: 'Количество человек'),
              keyboardType: TextInputType.number,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _baggage,
              decoration: const InputDecoration(labelText: 'Багаж'),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event, color: AppColors.blue),
                title: const Text('Дата выезда'),
                subtitle: Text(displayDate(dbDate(_departureDate))),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direction,
              decoration: const InputDecoration(labelText: 'Направление'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _destination,
              decoration: const InputDecoration(
                labelText: 'Станция / аэропорт / адрес',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ticketTime,
              decoration: const InputDecoration(labelText: 'Время билета, например 14:30'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _transferNeeded,
              title: const Text('Нужен трансфер'),
              activeColor: AppColors.green,
              onChanged: (value) => setState(() => _transferNeeded = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _comment,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Комментарий'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'ОТПРАВКА...' : 'ОТПРАВИТЬ ЗАЯВКУ'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Заполните поле';
    return null;
  }
}

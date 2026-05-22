import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../repositories/app_repository.dart';
import '../services/offline_queue.dart';
import '../widgets/app_widgets.dart';

class ChangeRequestScreen extends StatefulWidget {
  const ChangeRequestScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ChangeRequestScreen> createState() => _ChangeRequestScreenState();
}

class _ChangeRequestScreenState extends State<ChangeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AppRepository();

  late final TextEditingController _corps;
  final _room = TextEditingController();
  final _guestName = TextEditingController();
  final _tripCode = TextEditingController();
  final _newValue = TextEditingController();
  final _reason = TextEditingController();

  String _fieldChanged = 'дата выезда';
  String _urgency = 'обычное';
  bool _loading = false;

  final _fields = const [
    'дата выезда',
    'время билета',
    'направление',
    'количество человек',
    'багаж',
    'отмена трансфера',
    'другое',
  ];

  @override
  void initState() {
    super.initState();
    _corps = TextEditingController(text: widget.user.corps ?? '');
  }

  @override
  void dispose() {
    _corps.dispose();
    _room.dispose();
    _guestName.dispose();
    _tripCode.dispose();
    _newValue.dispose();
    _reason.dispose();
    super.dispose();
  }

  Map<String, dynamic> _payload() {
    return {
      'trip_code': _tripCode.text.trim(),
      'corps': _corps.text.trim(),
      'room': _room.text.trim(),
      'guest_name': _guestName.text.trim(),
      'field_changed': _fieldChanged,
      'new_value': _newValue.text.trim(),
      'reason': _reason.text.trim(),
      'urgency': _urgency,
      'created_by': widget.user.id,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final data = _payload();

    try {
      await _repo.createChange(
        user: widget.user,
        tripCode: _tripCode.text,
        corps: _corps.text,
        room: _room.text,
        guestName: _guestName.text,
        fieldChanged: _fieldChanged,
        newValue: _newValue.text,
        reason: _reason.text,
        urgency: _urgency,
      );
      if (!mounted) return;
      showAppMessage(context, 'Изменение отправлено');
      Navigator.of(context).pop();
    } catch (_) {
      await OfflineQueue.instance.enqueue('create_change', data);
      if (!mounted) return;
      showAppMessage(
        context,
        'Нет связи с сервером. Изменение сохранено локально.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Изменить / отменить',
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
              controller: _tripCode,
              decoration: const InputDecoration(labelText: 'ID заявки или ID рейса'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fieldChanged,
              items: _fields
                  .map((field) => DropdownMenuItem(value: field, child: Text(field)))
                  .toList(),
              onChanged: (value) => setState(() => _fieldChanged = value!),
              decoration: const InputDecoration(labelText: 'Что изменилось'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newValue,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Новое значение'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reason,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Причина'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _urgency,
              items: const ['обычное', 'срочно', 'очень срочно']
                  .map((urgency) => DropdownMenuItem(value: urgency, child: Text(urgency)))
                  .toList(),
              onChanged: (value) => setState(() => _urgency = value!),
              decoration: const InputDecoration(labelText: 'Срочность'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'ОТПРАВКА...' : 'ОТПРАВИТЬ ИЗМЕНЕНИЕ'),
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

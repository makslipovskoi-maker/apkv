import 'package:intl/intl.dart';

final _dbDate = DateFormat('yyyy-MM-dd');
final _ruDate = DateFormat('dd.MM.yyyy');
final _ruDateTime = DateFormat('dd.MM.yyyy HH:mm');

DateTime todayOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime tomorrowOnly() => todayOnly().add(const Duration(days: 1));

String dbDate(DateTime date) => _dbDate.format(date);

String displayDate(dynamic value) {
  if (value == null) return '—';
  final parsed = DateTime.tryParse(value.toString());
  return parsed == null ? value.toString() : _ruDate.format(parsed);
}

String displayDateTime(dynamic value) {
  if (value == null) return '—';
  final parsed = DateTime.tryParse(value.toString());
  return parsed == null ? value.toString() : _ruDateTime.format(parsed.toLocal());
}

String displayTime(dynamic value) {
  if (value == null || value.toString().isEmpty) return '—';
  final raw = value.toString();
  if (raw.length >= 5) return raw.substring(0, 5);
  return raw;
}

String normalizeTime(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return '';
  if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(clean)) {
    final parts = clean.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }
  return clean;
}

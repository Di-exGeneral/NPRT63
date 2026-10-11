import 'package:intl/intl.dart';

final _dateTime = DateFormat('d MMM yyyy, HH:mm');
final _date = DateFormat('d MMM yyyy');

String formatDateTime(DateTime? value) =>
    value == null ? '-' : _dateTime.format(value.toLocal());

String formatDate(DateTime? value) =>
    value == null ? '-' : _date.format(value.toLocal());

/// The API stores naive UTC timestamps, so send UTC without a zone suffix.
String toApiDateTime(DateTime value) =>
    value.toUtc().toIso8601String().replaceAll('Z', '');

/// Parses API timestamps, treating zone-less values as UTC.
DateTime? parseApiDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  final hasZone = value.endsWith('Z') ||
      RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(value.substring(10));
  return DateTime.tryParse(hasZone ? value : '${value}Z');
}

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formatYYYYMMDDHS => DateFormat('yyyy-MM-dd, HH:mm').format(this);
}

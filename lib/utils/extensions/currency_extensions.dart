import 'package:intl/intl.dart';

extension CurrencyExtensions on num {
  String get formatDigitAmount {
    var formatter = NumberFormat('#,##0');
    return formatter.format(this);
  }
}

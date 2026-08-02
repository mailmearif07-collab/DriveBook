import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

String formatCurrency(double value) => _inr.format(value);

String formatShortDate(DateTime d) => DateFormat('d MMM').format(d);
String formatFullDate(DateTime d) => DateFormat('d MMM y').format(d);
String formatTime(DateTime d) => DateFormat('hh:mm a').format(d);

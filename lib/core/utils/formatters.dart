import 'package:intl/intl.dart';

class Formatters {
  static String rupiah(num number) {
    try {
      final currencyFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return currencyFormatter.format(number);
    } catch (_) {
      return 'Rp ${number.toStringAsFixed(0)}';
    }
  }

  static String number(num number) {
    try {
      final numFormatter = NumberFormat.decimalPattern('id_ID');
      return numFormatter.format(number);
    } catch (_) {
      return number.toString();
    }
  }

  static String date(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy').format(dateTime);
      } catch (_) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    }
  }

  static String dateTime(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
      } catch (_) {
        final d = dateTime.day.toString().padLeft(2, '0');
        final m = dateTime.month.toString().padLeft(2, '0');
        final y = dateTime.year;
        final hh = dateTime.hour.toString().padLeft(2, '0');
        final mm = dateTime.minute.toString().padLeft(2, '0');
        return '$d/$m/$y, $hh:$mm';
      }
    }
  }
}

import 'package:intl/intl.dart';

class Formatters {
  static String rupiah(num number) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
  }

  static String number(num number) {
    final numFormatter = NumberFormat.decimalPattern('id_ID');
    return numFormatter.format(number);
  }


  static String date(DateTime dateTime) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
  }

  static String dateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }
}

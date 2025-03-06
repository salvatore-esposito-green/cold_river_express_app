// ignore: file_names
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final DateFormat formattedDate = DateFormat('dd/MM/yyyy HH:mm', 'it_IT');

  return formattedDate.format(date);
}

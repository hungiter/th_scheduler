import 'package:intl/intl.dart';

class DatetimeHelper {
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  void stringToDatetime(String dateString, Function(String) errorCallback,
      Function(DateTime) resultCallback) {
    try {
      DateTime date = dateFormat.parse(dateString);
      resultCallback(date);
    } catch (e) {
      errorCallback('Error parsing date string: $e');
    }
  }

  void datetimeToString(DateTime date, Function(String) errorCallback,
      Function(String) resultCallback) {
    try {
      String dateString = dateFormat.format(date);
      resultCallback(dateString);
    } catch (e) {
      errorCallback('Error parsing date string: $e');
    }
  }

  String dtString(DateTime date) {
    return dateFormat.format(date);
  }

  DateTime stringDt(String dateString) {
    return dateFormat.parse(dateString);
  }
}

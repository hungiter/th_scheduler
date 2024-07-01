import 'package:flutter/services.dart';

class LengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  LengthLimitingTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.length <= maxLength) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}
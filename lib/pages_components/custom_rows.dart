import 'package:flutter/material.dart';

Widget buildTitleAndValueTextRow(String title, String value) {
  return Row(
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child:
              Text(value), // Make sure to convert id to string if it's an int
        ),
      ),
    ],
  );
}

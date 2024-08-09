import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';

class MyDatePicker extends StatefulWidget {
  final bool setAsDefault;
  final bool enable;
  final List<DateTime> dates;
  final ValueChanged<String>? onDateSelected;

  MyDatePicker(
      {super.key,
      required this.setAsDefault,
      required this.enable,
      required this.dates,
      required this.onDateSelected});

  @override
  _MyDatePickerState createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  int? selectedIndex;
  final TextEditingController _controller = TextEditingController();
  final DatetimeHelper datetimeHelper = DatetimeHelper();
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    initTextController();
  }

  void initTextController() {
    if (widget.setAsDefault) {
      setState(() {
        _controller.text = datetimeHelper.dtString(widget.dates.first);
      });
    }
  }

  void _onChangedDate(int index) {
    setState(() {
      selectedIndex = index;
      datetimeHelper.datetimeToString(widget.dates[index], (error) {
        debugPrint(error);
      }, (date) {
        _controller.text = date;
      });
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(_controller.text);
    }
  }

  String _dateFormmatter(DateTime date) {
    String dateString = "";
    datetimeHelper.datetimeToString(date, (error) {}, (date) {
      dateString = date;
    });
    return dateString;
  }

  void _showDropdown(BuildContext context) async {
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy - renderBox.size.height * widget.dates.length,
              // Position above the TextField
              child: Material(
                elevation: 8.0,
                child: Container(
                  width: renderBox.size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: widget.dates.map((date) {
                      return ListTile(
                        title: Text(_dateFormmatter(date)),
                        onTap: () {
                          Navigator.pop(context, date);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (selectedDate != null) {
      int index = widget.dates.indexOf(selectedDate);
      _onChangedDate(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showDropdown(context);
          },
          child: AbsorbPointer(
            child: TextField(
              key: _textFieldKey,
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ngày bắt đầu',
                fillColor: Color.fromARGB(222, 255, 255, 255),
                filled: true,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

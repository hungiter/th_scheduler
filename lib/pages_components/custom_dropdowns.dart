import 'package:flutter/material.dart';

class RoomTypeDropdown extends StatefulWidget {
  final int currentFilter;
  final Function(int) onRoomTypeSelected;

  const RoomTypeDropdown(
      {Key? key, required this.currentFilter, required this.onRoomTypeSelected})
      : super(key: key);

  @override
  _RoomTypeDropdownState createState() => _RoomTypeDropdownState();
}

class _RoomTypeDropdownState extends State<RoomTypeDropdown> {
  late int currentFilter;
  late String selectedType;

  final List<String> roomTypes = [
    'Tất cả',
    'Phòng có 1 giường đơn',
    'Phòng có 2 giường đơn',
    'Phòng có giường đôi'
  ];
  final List<int> roomValues = [-1, 0, 1, 2];

  @override
  void initState() {
    super.initState();
    currentFilter = widget.currentFilter;
    selectedType = roomTypes[roomValues.indexOf(currentFilter)];
  }

  @override
  void didUpdateWidget(RoomTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilter != widget.currentFilter) {
      setState(() {
        currentFilter = widget.currentFilter;
        selectedType = roomTypes[roomValues.indexOf(currentFilter)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onChanged: (String? newValue) {
            setState(() {
              selectedType = newValue!;
            });
            widget.onRoomTypeSelected(
                roomValues[roomTypes.indexOf(selectedType)]);
          },
          items: roomTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

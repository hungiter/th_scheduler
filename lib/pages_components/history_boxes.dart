import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/data/history.dart';
import 'package:th_scheduler/pages_components/custom_rows.dart';

class HistoryBox extends StatefulWidget {
  final Histories history;
  final Function(Histories) onTap; // Accepts a callback function

  HistoryBox({super.key, required this.history, required this.onTap});

  @override
  _HistoryBoxState createState() => _HistoryBoxState();
}

class _HistoryBoxState extends State<HistoryBox> {
  late Histories history;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    history = widget.history;
  }

  void _onContainerTap() {
    widget.onTap(history); // Invokes the callback with History details
  }

  void _onEnter(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? MouseRegion(
            onEnter: (_) => _onEnter(true),
            onExit: (_) => _onEnter(false),
            child: GestureDetector(
              onTap: _onContainerTap,
              child: buildHistoryBox(),
            ),
          )
        : GestureDetector(
            onTap: _onContainerTap,
            onTapDown: (_) => _onEnter(true),
            onTapUp: (_) => _onEnter(false),
            onTapCancel: () => _onEnter(false),
            child: buildHistoryBox(),
          );
  }

  Widget buildHistoryBox() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: _onContainerTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue[700] : Colors.blueAccent,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTitleAndValueTextRow(history.id, history.statusToString())
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StartedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const StartedButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.lightBlueAccent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)))),
        child: Text(text, style: const TextStyle(fontSize: 16)));
  }
}

class LoginFormButton extends StatelessWidget {
  final String text;
  final bool enable;
  final Color btnColor;
  final Color txtColor;
  final VoidCallback onPressed;

  const LoginFormButton(
      {super.key,
      required this.text,
      required this.enable,
      required this.btnColor,
      required this.txtColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: enable ? onPressed : () => {},
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(txtColor),
            backgroundColor: MaterialStateProperty.all<Color>(btnColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)))),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }
}

class MiniLoginFormButton extends StatelessWidget {
  final String text;
  final Color btnColor;
  final Color txtColor;
  final VoidCallback onPressed;

  const MiniLoginFormButton(
      {super.key,
      required this.text,
      required this.btnColor,
      required this.txtColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(txtColor),
            backgroundColor: MaterialStateProperty.all<Color>(btnColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)))),
        child: Text(text, style: const TextStyle(fontSize: 12)));
  }
}

class UIActionButton extends StatefulWidget {
  final bool enable;
  final int actionId;
  final VoidCallback onPressed;

  const UIActionButton({
    Key? key,
    required this.enable,
    required this.actionId,
    required this.onPressed,
  }) : super(key: key);

  @override
  _UIActionButtonState createState() => _UIActionButtonState();
}

class _UIActionButtonState extends State<UIActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color buttonColor = switch (widget.actionId) {
      -1 => Colors.green, // Đặt lịch
      0 => Colors.red, // Huỷ
      1 => Colors.yellow, // Dời lịch hẹn
      2 => Colors.red, // Xoá lịch sử
      3 => Colors.white, // Tải lại danh sách phòng
      4 => Colors.white, // Tải thêm
      5 => Colors.white, // Xoá hết
      int() => throw UnimplementedError(),
    };

    Color textColor = switch (widget.actionId) {
      -1 => Colors.black, // Đặt lịch
      0 => Colors.white, // Huỷ
      1 => Colors.grey, // Dời lịch hẹn
      2 => Colors.white, // Xoá lịch sử
      3 => Colors.black, // Tải lại danh sách phòng
      4 => Colors.black, // Tải thêm
      5 => Colors.black, // Xoá hết
      int() => throw UnimplementedError(),
    };

    String displayText = switch (widget.actionId) {
      -1 => "Đặt phòng", // Đặt lịch
      0 => "Huỷ phòng", // Huỷ
      1 => "Dời lịch", // Dời lịch hẹn
      2 => "Xoá", // Xoá lịch sử
      3 => "Tải lại danh sách phòng", // Tải lại danh sách phòng
      4 => "Tải thêm", // Tải thêm
      5 => "Xoá hết", // Xoá hết
      int() => throw UnimplementedError(),
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ElevatedButton(
        onPressed: widget.enable ? widget.onPressed : null,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(textColor),
          backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: textColor, // Set the outline color here
                width: 1.0, // Set the width of the outline
              ),
            ),
          ),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

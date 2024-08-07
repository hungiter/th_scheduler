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

import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final Color color;

  const AuthButton(
      {super.key,
        required this.text,
        required this.onPressed,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.maxFinite,
      padding: const EdgeInsets.all(10),
      height: 60,
      onPressed: onPressed,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

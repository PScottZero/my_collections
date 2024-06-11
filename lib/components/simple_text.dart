import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';

class SimpleText extends StatelessWidget {
  final String value;
  final double fontSize;
  final Color? color;
  final bool bold;
  final bool center;

  const SimpleText(
    this.value, {
    super.key,
    this.fontSize = Constants.fontRegular,
    this.color,
    this.bold = false,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: center ? TextAlign.center : TextAlign.left,
    );
  }
}

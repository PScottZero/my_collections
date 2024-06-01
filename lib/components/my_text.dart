import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';

class MyText extends StatelessWidget {
  final String value;
  final double fontSize;
  final Color? color;
  final bool bold;
  final bool center;

  const MyText(
    this.value, {
    super.key,
    this.fontSize = Constants.fontRegular,
    this.color,
    this.bold = false,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    var text = Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
    if (center) {
      return Container(
        alignment: Alignment.center,
        child: text,
      );
    }
    return text;
  }
}

import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/my_text.dart';

class FullWidthButton extends StatelessWidget {
  final String text;
  final Function() onPressed;

  const FullWidthButton(this.text, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Constants.buttonHeight,
      child: ElevatedButton(onPressed: onPressed, child: MyText(text)),
    );
  }
}

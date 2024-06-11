import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/components/simple_text.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function() onPressed;

  const RoundedButton(this.text, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Constants.buttonHeight,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        onPressed: onPressed,
        child: SimpleText(text),
      ),
    );
  }
}

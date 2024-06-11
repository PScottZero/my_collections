import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';

class EntryField extends StatelessWidget {
  final String label;
  final String value;

  const EntryField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Constants.paddingTop16,
      padding: Constants.padding16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: Constants.borderRadius,
      ),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Constants.fontRegular,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_collections/components/my_text.dart';
import 'package:my_collections/components/constants.dart';

class EntryField extends StatelessWidget {
  final String label;
  final String value;

  const EntryField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Constants.paddingTop16,
      padding: Constants.padding24,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: Constants.borderRadius,
      ),
      child: Row(children: [MyText('$label: ', bold: true), MyText(value)]),
    );
  }
}

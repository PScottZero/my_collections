import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  final TextEditingController _controller = TextEditingController();

  LabeledTextField(this.label, this.value, this.onChanged, {super.key}) {
    _controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: Constants.borderRadius),
      ),
      onChanged: onChanged,
    );
  }
}

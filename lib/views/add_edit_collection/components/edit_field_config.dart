import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/components/labeled_text_field.dart';

class EditFieldConfig extends StatelessWidget {
  final String fieldName;
  final Function(String) onChanged;
  final Function() onDeleted;

  const EditFieldConfig({
    super.key,
    required this.fieldName,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: LabeledTextField('Field Name', fieldName, onChanged),
      contentPadding: Constants.padding0,
      trailing: SizedBox(
        width: Constants.fieldConfigTrailingWidth,
        child: Row(
          children: [
            IconButton(onPressed: onDeleted, icon: const Icon(Icons.delete)),
            const Icon(Icons.drag_handle)
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_collections/components/full_width_button.dart';
import 'package:my_collections/components/my_text.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/models/field_config.dart';
import 'package:my_collections/models/my_collections_model.dart';
import 'package:my_collections/views/add_edit_collection/components/edit_field_config.dart';
import 'package:provider/provider.dart';

class EditEntryTemplate extends StatefulWidget {
  const EditEntryTemplate({super.key});

  @override
  State<EditEntryTemplate> createState() => _EditEntryTemplateState();
}

class _EditEntryTemplateState extends State<EditEntryTemplate> {
  void _addFieldConfig(MyCollectionsModel model) {
    setState(() {
      model.editFieldConfigs.add(FieldConfig.create(model.editCollection.id));
    });
  }

  void _reorderFieldConfig(MyCollectionsModel model, int oldIdx, int newIdx) {
    if (oldIdx < newIdx) {
      newIdx -= 1;
    }
    setState(() {
      var fieldConfig = model.editFieldConfigs.removeAt(oldIdx);
      model.editFieldConfigs.insert(newIdx, fieldConfig);
    });
  }

  void _removeFieldConfig(MyCollectionsModel model, FieldConfig fieldConfig) {
    setState(() {
      model.removedFieldConfigs.add(fieldConfig);
      model.editFieldConfigs.remove(fieldConfig);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCollectionsModel>(
      builder: (context, model, child) => Column(
        children: [
          const MyText('Entry Template'),
          Constants.height16,
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIdx, newIdx) {
              return _reorderFieldConfig(model, oldIdx, newIdx);
            },
            children: () {
              var fieldConfigs = model.editFieldConfigs.asMap().entries;
              var tilesMap = fieldConfigs.map(
                (entry) => EditFieldConfig(
                  key: Key(entry.key.toString()),
                  fieldName: entry.value.name,
                  onChanged: (fieldName) => entry.value.name = fieldName,
                  onDeleted: () {
                    return _removeFieldConfig(model, entry.value);
                  },
                ),
              );
              return tilesMap.toList();
            }(),
          ),
          Constants.height16,
          FullWidthButton('Add Field', () => _addFieldConfig(model)),
        ],
      ),
    );
  }
}

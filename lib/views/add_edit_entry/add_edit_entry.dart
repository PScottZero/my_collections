import 'package:flutter/material.dart';
import 'package:my_collections/components/confirm_button.dart';
import 'package:my_collections/components/full_width_button.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/labeled_text_field.dart';
import 'package:my_collections/components/padded_divider.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/models/my_collections_model.dart';
import 'package:my_collections/views/add_edit_entry/components/image_chooser.dart';
import 'package:provider/provider.dart';

class AddEditEntry extends StatefulWidget {
  final bool edit;

  const AddEditEntry({super.key, this.edit = false});

  @override
  State<AddEditEntry> createState() => _AddEditEntryState();
}

class _AddEditEntryState extends State<AddEditEntry> {
  void _addEntry(MyCollectionsModel model) async {
    await model.addEntry();
    if (mounted) Navigator.pop(context);
  }

  void _updateEntry(MyCollectionsModel model) async {
    await model.updateEntry();
    if (mounted) Navigator.pop(context);
  }

  void _moveToList(MyCollectionsModel model) async {
    setState(() {
      model.editEntry.inWantlist = 1 - model.editEntry.inWantlist;
    });
  }

  void _removeEntry(MyCollectionsModel model) async {
    await model.removeEntry();
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  void _save(MyCollectionsModel model) =>
      widget.edit ? _updateEntry(model) : _addEntry(model);

  String _title(MyCollectionsModel model) => widget.edit
      ? 'Edit ${model.currCollection.name} Entry'
      : 'Add ${model.currCollection.name} Entry';

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCollectionsModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_title(model)),
            centerTitle: true,
            actions: [
              IfElse(
                condition: widget.edit,
                ifWidget: () {
                  return ConfirmButton(
                    icon: Icons.delete,
                    dialogTitle: 'Remove Entry',
                    dialogContent: 'Are you sure you want to remove'
                        ' the entry ${model.editCollection.name}?',
                    confirmAction: 'Remove',
                    onConfirm: () => _removeEntry(model),
                  );
                },
              ),
              IconButton(
                onPressed: () => _save(model),
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          body: ListView(
            padding: Constants.padding16,
            children: <Widget>[
              Column(
                children: [
                  const ImageChooser(),
                  const PaddedDivider(bottom: false),
                  Constants.height16,
                  LabeledTextField(
                    'Name',
                    model.editEntry.name,
                    (name) => model.editEntry.name = name,
                  ),
                ],
              ),
              Column(
                children: model.currFieldConfigs.map(
                  (fieldConfig) {
                    var field = model.editFields[fieldConfig.id];
                    return Column(
                      children: [
                        Constants.height16,
                        LabeledTextField(
                          fieldConfig.name,
                          field?.value ?? '',
                          (newValue) => field?.value = newValue,
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
              Column(
                children: [
                  Constants.height16,
                  LabeledTextField(
                    'Value',
                    model.editEntry.value,
                    (value) => model.editEntry.value = value,
                  ),
                  IfElse(
                    condition: widget.edit,
                    ifWidget: () {
                      return Column(
                        children: [
                          const PaddedDivider(),
                          FullWidthButton(
                            model.editEntry.inWantlist == 1
                                ? 'Move to Collection'
                                : 'Move to Wantlist',
                            () => _moveToList(model),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

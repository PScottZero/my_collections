import 'package:flutter/material.dart';
import 'package:my_collections/components/confirm_button.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/labeled_text_field.dart';
import 'package:my_collections/components/padded_divider.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:my_collections/views/add_edit_collection/components/edit_entry_template.dart';
import 'package:my_collections/components/thumbnail_chooser.dart';
import 'package:provider/provider.dart';

class AddEditCollection extends StatefulWidget {
  final bool edit;

  const AddEditCollection({super.key, this.edit = false});

  @override
  State<AddEditCollection> createState() => _AddEditCollectionState();
}

class _AddEditCollectionState extends State<AddEditCollection> {
  void _addCollection(MCModel model) async {
    await model.addCollection();
    if (mounted) Navigator.pop(context);
  }

  void _updateCollection(MCModel model) async {
    await model.updateCollection();
    if (mounted) Navigator.pop(context);
  }

  void _removeCollection(MCModel model) async {
    await model.removeCollection();
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _save(MCModel model, bool update) =>
      update ? _updateCollection(model) : _addCollection(model);

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.edit ? 'Edit Collection' : 'Add Collection'),
            centerTitle: true,
            actions: [
              IfElse(
                condition: widget.edit,
                ifWidget: () => ConfirmButton(
                  icon: Icons.delete,
                  dialogTitle: 'Remove ${model.editCollection.name} Collection',
                  dialogContent: 'Are you sure you want'
                      ' to remove this collection?',
                  confirmAction: 'Remove',
                  onConfirm: () => _removeCollection(model),
                ),
              ),
              IconButton(
                onPressed: () => _save(model, widget.edit),
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          body: ListView(
            padding: Constants.padding16,
            children: [
              LabeledTextField(
                'Name',
                model.editCollection.name,
                (name) => model.editCollection.name = name,
              ),
              const PaddedDivider(),
              ThumbnailChooser(
                thumbnail: model.editCollection.thumbnail,
                onThumbnailUpload: (thumbnail) {
                  model.addCollectionThumbnail(thumbnail);
                },
              ),
              const PaddedDivider(),
              const EditEntryTemplate(),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_collections/components/confirm_button.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/labeled_text_field.dart';
import 'package:my_collections/components/padded_divider.dart';
import 'package:my_collections/components/thumbnail_chooser.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:provider/provider.dart';

class AddEditFolder extends StatefulWidget {
  final bool edit;

  const AddEditFolder({super.key, this.edit = false});

  @override
  State<AddEditFolder> createState() => _AddEditFolderState();
}

class _AddEditFolderState extends State<AddEditFolder> {
  void _addFolder(MCModel model) async {
    await model.addFolder();
    if (mounted) Navigator.pop(context);
  }

  void _updateFolder(MCModel model) async {
    await model.updateFolder();
    if (mounted) Navigator.pop(context);
  }

  void _removeFolder(MCModel model) async {
    await model.removeFolder();
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  void _save(MCModel model, bool update) =>
      update ? _updateFolder(model) : _addFolder(model);

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.edit ? 'Edit Folder' : 'Add Folder'),
            centerTitle: true,
            actions: [
              IfElse(
                condition: widget.edit,
                ifWidget: () => ConfirmButton(
                  icon: Icons.delete,
                  dialogTitle: 'Remove ${model.editFolder.name} Folder',
                  dialogContent: 'Are you sure you want'
                      ' to remove this folder?',
                  confirmAction: 'Remove',
                  onConfirm: () => _removeFolder(model),
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
                model.editFolder.name,
                (name) => model.editFolder.name = name,
              ),
              const PaddedDivider(),
              ThumbnailChooser(
                thumbnail: model.editFolder.thumbnail,
                onThumbnailUpload: (thumbnail) {
                  model.addFolderThumbnail(thumbnail);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

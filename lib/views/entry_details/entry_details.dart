import 'package:flutter/material.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/views/add_edit_entry/add_edit_entry.dart';
import 'package:my_collections/views/entry_details/components/entry_field.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:my_collections/views/entry_details/components/image_carousel.dart';
import 'package:provider/provider.dart';

class EntryDetails extends StatelessWidget {
  const EntryDetails({super.key});

  void _editEntryRoute(BuildContext context, MCModel model) async {
    await model.initEditEntryRoute();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddEditEntry(edit: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text(model.currEntry.name),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editEntryRoute(context, model),
            ),
          ],
        ),
        body: ListView(
          children: [
            ImageCarousel(model),
            Padding(
              padding: Constants.padding16,
              child: Column(
                children: [
                  SimpleText(
                    model.currEntry.name,
                    fontSize: Constants.fontXLarge,
                    center: true,
                  ),
                  Column(
                    children: model.currFieldConfigs.map(
                      (fieldConfig) {
                        var field = model.currFields[fieldConfig.id];
                        return field!.value.isNotEmpty
                            ? EntryField(
                                label: fieldConfig.name,
                                value: field.value,
                              )
                            : Container();
                      },
                    ).toList(),
                  ),
                  () {
                    if (model.currEntry.value.isNotEmpty) {
                      return EntryField(
                        label: 'Value',
                        value: model.currEntry.formattedValue,
                      );
                    } else {
                      return Container();
                    }
                  }(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

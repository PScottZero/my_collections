import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/full_width_button.dart';
import 'package:my_collections/components/my_text.dart';
import 'package:my_collections/components/padded_divider.dart';
import 'package:my_collections/models/my_collections_model.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  Future<void> _backup(BuildContext context, MyCollectionsModel model) async {
    await _loadingDialog(context, model.backup);
  }

  Future<void> _restore(BuildContext context, MyCollectionsModel model) async {
    await _loadingDialog(context, model.restore);
  }

  Future<void> _refreshCounts(
    BuildContext context,
    MyCollectionsModel model,
  ) async {
    await _loadingDialog(context, model.refreshCounts);
  }

  Future<void> _refreshThumbnails(
    BuildContext context,
    MyCollectionsModel model,
  ) async {
    await _loadingDialog(context, model.refreshThumbnails);
  }

  Future<void> _loadingDialog(
    BuildContext context,
    Future<String> Function() future,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Constants.width16,
              MyText('Loading'),
            ],
          ),
        ),
      ),
    );
    var message = await future();
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: MyText(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCollectionsModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
        ),
        body: Container(
          padding: Constants.padding16,
          alignment: Alignment.center,
          child: Column(
            children: [
              FullWidthButton(
                'Refresh Collections Counts',
                () => _refreshCounts(context, model),
              ),
              Constants.height16,
              FullWidthButton(
                'Refresh Thumbnails',
                () => _refreshThumbnails(context, model),
              ),
              const PaddedDivider(),
              FullWidthButton('Backup Data', () => _backup(context, model)),
              Constants.height16,
              FullWidthButton('Restore Data', () => _restore(context, model)),
            ],
          ),
        ),
      ),
    );
  }
}

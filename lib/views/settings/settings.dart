import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/components/rounded_button.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/components/padded_divider.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  Future<void> _backup(BuildContext context, MCModel model) async {
    await _loadingDialog(context, model.backup);
  }

  Future<void> _restore(BuildContext context, MCModel model) async {
    await _loadingDialog(context, model.restore);
  }

  Future<void> _refreshCounts(
    BuildContext context,
    MCModel model,
  ) async {
    await _loadingDialog(context, model.refreshCounts);
  }

  Future<void> _refreshThumbnails(
    BuildContext context,
    MCModel model,
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
              SimpleText('Loading'),
            ],
          ),
        ),
      ),
    );
    var message = await future();
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SimpleText(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
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
              RoundedButton(
                'Refresh Collections Counts',
                () => _refreshCounts(context, model),
              ),
              Constants.height16,
              RoundedButton(
                'Refresh Thumbnails',
                () => _refreshThumbnails(context, model),
              ),
              const PaddedDivider(),
              RoundedButton('Backup Data', () => _backup(context, model)),
              Constants.height16,
              RoundedButton('Restore Data', () => _restore(context, model)),
            ],
          ),
        ),
      ),
    );
  }
}

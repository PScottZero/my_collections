import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/full_width_button.dart';
import 'package:my_collections/components/my_text.dart';

class ConfirmButton extends StatelessWidget {
  final String dialogTitle;
  final String dialogContent;
  final String confirmAction;
  final Function() onConfirm;
  final String buttonText;
  final IconData? icon;

  const ConfirmButton({
    super.key,
    required this.dialogTitle,
    required this.dialogContent,
    required this.confirmAction,
    required this.onConfirm,
    this.buttonText = '',
    this.icon,
  });

  Future<void> _showDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: MyText(dialogTitle, fontSize: Constants.fontLarge),
        content: MyText(dialogContent),
        actions: [
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: MyText(confirmAction, color: Colors.red),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const MyText('Cancel'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return IconButton(
        onPressed: () => _showDialog(context),
        icon: Icon(icon),
      );
    } else {
      return FullWidthButton(buttonText, () => _showDialog(context));
    }
  }
}

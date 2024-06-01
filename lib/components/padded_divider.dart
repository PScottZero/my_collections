import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';

class PaddedDivider extends StatelessWidget {
  final bool top, bottom;

  const PaddedDivider({
    super.key,
    this.top = true,
    this.bottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        top ? Constants.height16 : Container(),
        const Divider(),
        bottom ? Constants.height16 : Container(),
      ],
    );
  }
}

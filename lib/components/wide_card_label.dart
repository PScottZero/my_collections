import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/my_text.dart';

class WideCardLabel extends StatelessWidget {
  final String name;
  final int collectionSize;
  final int wantlistSize;

  const WideCardLabel({
    super.key,
    required this.name,
    required this.collectionSize,
    required this.wantlistSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.labelHeight,
      child: Row(
        children: [
          Expanded(child: MyText(name, bold: true)),
          Row(
            children: [
              Constants.width8,
              const Icon(Icons.grid_view),
              Constants.width2,
              MyText(collectionSize.toString(), bold: true),
              Constants.width8,
              const Icon(Icons.favorite_outline),
              Constants.width2,
              MyText(wantlistSize.toString(), bold: true),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/components/simple_text.dart';

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
          Expanded(child: SimpleText(name, bold: true)),
          Row(
            children: [
              Constants.width8,
              const Icon(Icons.grid_view),
              Constants.width2,
              SimpleText(collectionSize.toString(), bold: true),
              Constants.width8,
              const Icon(Icons.favorite_outline),
              Constants.width2,
              SimpleText(wantlistSize.toString(), bold: true),
            ],
          ),
        ],
      ),
    );
  }
}

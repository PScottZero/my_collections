import 'package:flutter/material.dart';
import 'package:my_collections/components/if_else.dart';

class Loading extends StatelessWidget {
  final bool loaded;
  final Widget content;

  const Loading({super.key, required this.loaded, required this.content});

  @override
  Widget build(BuildContext context) {
    return IfElse(
      condition: loaded,
      ifWidget: () => content,
      elseWidget: () => Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

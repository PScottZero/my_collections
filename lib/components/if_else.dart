import 'package:flutter/material.dart';

class IfElse extends StatelessWidget {
  final bool condition;
  final Widget Function() ifWidget;
  final Widget Function()? elseWidget;

  const IfElse({
    super.key,
    required this.condition,
    required this.ifWidget,
    this.elseWidget,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? ifWidget() : (elseWidget ?? () => Container())();
  }
}

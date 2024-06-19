import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final Future<bool> future;
  final Widget content;

  const Loading({super.key, required this.future, required this.content});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return content;
        } else {
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

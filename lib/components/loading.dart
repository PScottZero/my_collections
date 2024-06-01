import 'package:flutter/material.dart';

class Loading<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T) futureWidget;

  const Loading({
    super.key,
    required this.future,
    required this.futureWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return futureWidget(snapshot.data as T);
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

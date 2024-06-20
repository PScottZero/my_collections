import 'package:flutter/material.dart';

class LoadAsyncView<T> extends StatelessWidget {
  final String viewTitle;
  final Future<T> future;
  final Widget Function(T?) builder;

  const LoadAsyncView({
    super.key,
    required this.viewTitle,
    required this.future,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return builder(snapshot.data);
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(viewTitle)),
            body: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

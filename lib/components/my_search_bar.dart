import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  final String? hint;
  final Widget? bottom;
  final Function(String)? onChanged;

  const MySearchBar({super.key, this.hint, this.bottom, this.onChanged});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: SearchBar(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withAlpha(220),
            ),
            leading: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.search),
            ),
            hintText: widget.hint,
            onChanged: widget.onChanged,
          ),
        ),
        const SizedBox(height: 16),
        widget.bottom ?? Container(),
        widget.bottom != null ? const SizedBox(height: 16) : Container(),
      ],
    );
  }
}

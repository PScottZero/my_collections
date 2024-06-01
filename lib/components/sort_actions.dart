import 'package:flutter/material.dart';
import 'package:my_collections/components/my_text.dart';

class SortActions extends StatelessWidget {
  final String sortColumn;
  final bool sortAsc;
  final List<String> sortOptions;
  final List<String> sortOptionLabels;
  final Function(String) onSortColumnSelected;
  final Function() onSortAscToggled;

  const SortActions({
    super.key,
    required this.sortColumn,
    required this.sortAsc,
    required this.sortOptions,
    required this.sortOptionLabels,
    required this.onSortColumnSelected,
    required this.onSortAscToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onSortAscToggled,
          icon: Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
        ),
        PopupMenuButton(
          initialValue: sortColumn,
          onSelected: onSortColumnSelected,
          itemBuilder: (context) {
            List<PopupMenuItem<String>> items = [];
            if (sortOptions.length == sortOptionLabels.length) {
              for (var i = 0; i < sortOptions.length; i++) {
                items.add(
                  PopupMenuItem(
                    value: sortOptions[i],
                    child: MyText(sortOptionLabels[i]),
                  ),
                );
              }
            }
            return items;
          },
        )
      ],
    );
  }
}

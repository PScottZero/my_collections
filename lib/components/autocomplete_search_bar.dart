import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:my_collections/components/simple_text.dart';

class AutocompleteSearchBar extends StatelessWidget {
  final String? hint;
  final Widget? bottom;
  final List<String> searchOptions;
  final Function(String) onChanged;

  List<String> _filteredOptions(String query) {
    var options = searchOptions
        .where((option) => option.toLowerCase().contains(query.toLowerCase()))
        .toList();
    options.sort();
    return options;
  }

  const AutocompleteSearchBar({
    super.key,
    this.hint,
    this.bottom,
    required this.searchOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: TypeAheadField<String>(
            builder: (context, controller, focusNode) {
              return SearchBar(
                controller: controller,
                focusNode: focusNode,
                backgroundColor: WidgetStateProperty.resolveWith(
                  (_) => Theme.of(context).colorScheme.secondaryContainer,
                ),
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.search),
                ),
                hintText: hint,
                onChanged: onChanged,
              );
            },
            itemBuilder: (context, value) => ListTile(title: SimpleText(value)),
            suggestionsCallback: (query) => _filteredOptions(query),
            onSelected: onChanged,
          ),
        ),
        const SizedBox(height: 16),
        bottom ?? Container(),
        bottom != null ? const SizedBox(height: 16) : Container(),
      ],
    );
  }
}

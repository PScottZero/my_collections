import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:provider/provider.dart';

class AutocompleteSearchBar extends StatefulWidget {
  final String? hint;
  final Widget? bottom;
  final List<String> searchOptions;
  final Function(String) onChanged;

  const AutocompleteSearchBar({
    super.key,
    this.hint,
    this.bottom,
    required this.searchOptions,
    required this.onChanged,
  });

  @override
  State<AutocompleteSearchBar> createState() => _AutocompleteSearchBarState();
}

class _AutocompleteSearchBarState extends State<AutocompleteSearchBar> {
  final TextEditingController _controller = TextEditingController();

  List<String> _options(String query) {
    var options = widget.searchOptions
        .where((option) => option.toLowerCase().contains(query.toLowerCase()))
        .toList();
    options.sort();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: TypeAheadField<String>(
              controller: _controller,
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
                  hintText: widget.hint,
                  onChanged: (query) => setState(() => widget.onChanged(query)),
                );
              },
              itemBuilder: (context, value) =>
                  ListTile(title: SimpleText(value)),
              suggestionsCallback: (query) => _options(query),
              onSelected: (query) => setState(
                () {
                  _controller.text = query;
                  widget.onChanged(query);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          widget.bottom ?? Container(),
          widget.bottom != null ? const SizedBox(height: 16) : Container(),
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onQueryChanged,
    required this.controller,
  });

  final void Function(String newQuery) onQueryChanged;
  final TextEditingController controller;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.controller,
        onChanged: (value) {
          widget.onQueryChanged(value);
        },
        decoration: InputDecoration(
          labelText: "Search",
          hintText: "Fruits, Vegetables, Groceries, etc...",
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              widget.controller.clear();
              widget.onQueryChanged('');
            },
            icon: const Icon(Icons.clear),
          ),
        ),
      ),
    );
  }
}

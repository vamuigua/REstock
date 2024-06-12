import "package:flutter/material.dart";

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onQueryChanged,
  });

  final void Function(String newQuery) onQueryChanged;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          widget.onQueryChanged(value);
        },
        decoration: const InputDecoration(
          labelText: "Search",
          hintText: "Fruits, Vegetables, Groceries, etc...",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

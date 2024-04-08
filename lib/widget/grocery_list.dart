import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        "restock-cc312-default-rtdb.asia-southeast1.firebasedatabase.app",
        "shopping-list.json");

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (category) => category.value.title == item.value['category'])
          .value;

      loadedItems.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }

    setState(() {
      _groceryItems = loadedItems;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    _loadItems();
  }

  void _removeItem(GroceryItem item) {
    final itemIndex = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      content: const Text("🚮 Item deleted."),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          setState(() {
            _groceryItems.insert(itemIndex, item);
          });
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_outlined, size: 50),
          const SizedBox(height: 2),
          const Text(
            'No items found.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text("Click on the '+' button to get started!"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addItem,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id),
            background: Container(
              color: Theme.of(context).colorScheme.error,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
            ),
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            child: ListTile(
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              title: Text(_groceryItems[index].name),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
                style: const TextStyle(fontSize: 15.0),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('REstock'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';
import 'package:shopping_list/widget/edit_item.dart';
import 'package:shopping_list/widget/custom_search_bar.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  List<GroceryItem> _filteredItems = [];
  var _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems({String searchQuery = ''}) async {
    Map<String, dynamic> queryParams = {};

    if (searchQuery.isNotEmpty) {
      queryParams = {
        'orderBy': jsonEncode("name"),
        'startAt': jsonEncode(searchQuery),
        'endAt': jsonEncode("$searchQuery\uf8ff"),
      };
    }

    final url = Uri.https(
      "restock-cc312-default-rtdb.asia-southeast1.firebasedatabase.app",
      "shopping-list.json",
      queryParams,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = "❌ Failed to fetch data. Please try again later.";
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });

        return;
      }

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
        _filteredItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Oops!😗 That's embarassing. Please try again later.";
      });
    }
  }

  void _addItem() async {
    _clearSearch();

    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text("✅ Item Added."),
      ),
    );
  }

  void _editItem(GroceryItem item) async {
    _clearSearch();

    final itemIndex = _filteredItems.indexOf(item);

    final updatedItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditItem(groceryItem: item),
      ),
    );

    if (updatedItem == null) {
      return;
    }

    setState(() {
      _groceryItems[itemIndex] = updatedItem;
    });

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text("✅ Item Updated."),
      ),
    );
  }

  void _removeItem(GroceryItem item) async {
    final itemIndex = _filteredItems.indexOf(item);

    setState(() {
      _filteredItems.remove(item);
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      "restock-cc312-default-rtdb.asia-southeast1.firebasedatabase.app",
      "shopping-list/${item.id}.json",
    );

    try {
      final response = await http.delete(url);

      if (!context.mounted) {
        return;
      }

      if (response.statusCode >= 400) {
        setState(() {
          _filteredItems.insert(itemIndex, item);
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Something went wrong! Try again later."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text("✅ Item removed."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _filteredItems.insert(itemIndex, item);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oops!😅 That's embarassing. Please try again later."),
        ),
      );
    }
  }

  void _updateSearchResults(String newQuery) {
    setState(() {
      if (newQuery.isEmpty) {
        _filteredItems = _groceryItems;
      } else {
        _filteredItems = _groceryItems.where((item) {
          return item.name.toLowerCase().contains(newQuery.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _updateSearchResults('');
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

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredItems.isNotEmpty) {
      content = RefreshIndicator(
        onRefresh: _loadItems,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _filteredItems.length,
          itemBuilder: (ctx, index) {
            return Dismissible(
              key: ValueKey(_filteredItems[index].id),
              background: Container(
                color: Theme.of(context).colorScheme.error,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
              ),
              onDismissed: (direction) {
                _removeItem(_filteredItems[index]);
              },
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Remove item'),
                          content: const Text(
                              'Are you sure you want to remove this item?'),
                          actions: [
                            TextButton(
                              child: const Text(
                                "Cancel",
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text(
                                "Remove item",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;
              },
              child: ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _filteredItems[index].category.color,
                ),
                title: Text(_filteredItems[index].name),
                trailing: Text(
                  _filteredItems[index].quantity.toString(),
                  style: const TextStyle(fontSize: 15.0),
                ),
                onTap: () {
                  _editItem(_filteredItems[index]);
                },
              ),
            );
          },
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.background,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 200),
                shape: const CircleBorder(),
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Icon(Icons.add, size: 30.0),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('REstock'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          CustomSearchBar(
            onQueryChanged: _updateSearchResults,
            controller: _searchController,
          ),
          Expanded(
            child: content,
          )
        ],
      ),
    );
  }
}

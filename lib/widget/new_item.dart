import 'package:flutter/material.dart';

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/services/database_service.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      try {
        final item = GroceryItem(
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
          listId: 1 // TODO: Change to shopping_list id
        );

        int itemId = await _databaseService.addItem(item);

        GroceryItem updatedItem = item.copyWith(id: itemId);

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop(updatedItem);
      } catch (e) {
        setState(() {
          _isSending = false;
        });

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Something went wrong! Try again later."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    onSaved: (value) {
                      _enteredName = value.toString();
                    },
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return "Must be between 2 and 50 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      _enteredQuantity = int.parse(value!);
                    },
                    maxLength: 8,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Quantity"),
                    ),
                    initialValue: "1",
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return "Must be a valid, positive number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(
                    value: _selectedCategory,
                    items: [
                      for (final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(width: 6),
                              Text(category.value.title),
                            ],
                          ),
                        )
                    ],
                    onChanged: (value) {
                      _selectedCategory = value!;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                              },
                        child: const Text("Reset"),
                      ),
                      ElevatedButton(
                        onPressed: _isSending ? null : _saveItem,
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Save item"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

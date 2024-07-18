import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/services/database_service.dart';

class EditItem extends StatefulWidget {
  const EditItem({
    required this.groceryItem,
    super.key,
  });

  final GroceryItem groceryItem;

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;
  late String _enteredName;
  late int _enteredQuantity;
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.groceryItem.name;
    _enteredQuantity = widget.groceryItem.quantity;
    _selectedCategory = widget.groceryItem.category;
  }

  void _updateItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final updatedItem = GroceryItem(
        id: widget.groceryItem.id,
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _selectedCategory,
        firebaseId: widget.groceryItem.firebaseId,
      );

      _databaseService.updateItem(updatedItem);

      try {
        final url = Uri.https(
            "restock-cc312-default-rtdb.asia-southeast1.firebasedatabase.app",
            "shopping-list/${widget.groceryItem.id}.json");

        await http.patch(
          url,
          headers: {"Content-type": "application/json"},
          body: json.encode(
            {
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
            },
          ),
        );

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop(updatedItem);
      } catch (e) {
        setState(() {
          _isSending = false;
        });

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
        title: const Text("Edit item"),
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
                    initialValue: _enteredName,
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
                    initialValue: _enteredQuantity.toString(),
                    onSaved: (value) {
                      _enteredQuantity = int.parse(value!);
                    },
                    maxLength: 8,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Quantity"),
                    ),
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
                      ElevatedButton(
                        onPressed: _isSending ? null : _updateItem,
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Update item"),
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

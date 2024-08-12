import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

class GroceryItem {
  final int? id;
  final String name;
  final int quantity;
  final Category category;
  final String? firebaseId;
  final int listId;

  const GroceryItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.firebaseId,
    required this.listId,
  });

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    final category = categories.entries
        .firstWhere((category) => category.value.title == map['category'])
        .value;

    return GroceryItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      category: category,
      firebaseId: map['firebase_id'],
      listId: map['list_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category.title,
      'firebase_id': firebaseId,
      'list_id': listId,
    };
  }

  GroceryItem copyWith({
    int? id,
    String? name,
    int? quantity,
    Category? category,
    String? firebaseId,
    int? listId,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      firebaseId: firebaseId ?? this.firebaseId,
      listId: listId ?? this.listId,
    );
  }
}

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.firebaseId = '',
  });

  final String id;
  final String name;
  final int quantity;
  final Category category;
  final String firebaseId;

  static GroceryItem fromMap(Map<String, dynamic> map) {
    final category = categories.entries
        .firstWhere((category) => category.value.title == map['category'])
        .value;

    return GroceryItem(
      id: map['id'].toString(),
      name: map['name'],
      quantity: map['quantity'],
      category: category,
      firebaseId: map['firebase_id'] ?? '',
    );
  }
}

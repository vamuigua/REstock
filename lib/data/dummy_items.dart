import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/data/categories.dart';

final groceryItems = [
  GroceryItem(
    id: 1,
    name: 'Milk',
    quantity: 1,
    category: categories[Categories.dairy]!,
    listId: 1,
  ),
  GroceryItem(
    id: 2,
    name: 'Bananas',
    quantity: 5,
    category: categories[Categories.fruit]!,
    listId: 1,
  ),
  GroceryItem(
    id: 3,
    name: 'Beef Steak',
    quantity: 1,
    category: categories[Categories.meat]!,
    listId: 1,
  ),
];

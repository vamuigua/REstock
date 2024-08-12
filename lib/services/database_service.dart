import 'package:path/path.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;

  DatabaseService._constructor();

  static final DatabaseService instance = DatabaseService._constructor();

  final String tableShoppingList = "shopping_list";
  final String columnId = 'id';
  final String columnFirebaseId = 'firebase_id';
  final String columnName = 'name';
  final String columnQuantity = 'quantity';
  final String columnCategory = 'category';

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await getDatabase();

    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'restock.db');
    final database = openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableShoppingList (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnFirebaseId TEXT,
            $columnName TEXT NOT NULL,
            $columnQuantity INTEGER NOT NULL,
            $columnCategory TEXT NOT NULL
          )
        ''');
      },
    );

    return database;
  }

  Future<List<GroceryItem>> getItems() async {
    final db = await database;
    final result = await db.query(tableShoppingList);
    return result.map((item) => GroceryItem.fromMap(item)).toList();
  }

  Future<int> addItem(GroceryItem item) async {
    final db = await database;
    final itemId = await db.insert(
      tableShoppingList,
      item.toMap()..remove(columnId),
    );

    return itemId;
  }

  void updateItem(GroceryItem item) async {
    final db = await database;
    await db.update(
      tableShoppingList,
      item.toMap()..remove(columnId),
      where: "$columnId = ?",
      whereArgs: [item.id],
    );
  }

  void deleteItem(int id) async {
    final db = await database;
    await db.delete(
      tableShoppingList,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }
}

import 'package:path/path.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/models/shopping_list.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  DatabaseService._constructor();

  final String tableShoppingList = "shopping_list";
  final String tableShoppingItems = "shopping_items";

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );

    return database;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        firebase_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableShoppingItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        firebase_id TEXT,
        list_id INTEGER,
        FOREIGN KEY (list_id) REFERENCES $tableShoppingList (id)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE shopping_list ADD COLUMN firebase_id TEXT');
    }
  }

  // Methods for shopping_list table
  Future<List<ShoppingList>> getShoppingLists() async {
    final db = await database;
    final result = await db.query(tableShoppingList);
    return result.map((list) => ShoppingList.fromMap(list)).toList();
  }

  Future<int> createShoppingList(ShoppingList list) async {
    final db = await database;
    return await db.insert(tableShoppingList, list.toMap());
  }

  Future<int> updateShoppingList(ShoppingList list) async {
    final db = await database;
    return await db.update(
      tableShoppingList,
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<ShoppingList?> getShoppingListByFirebaseId(String firebaseId) async {
    final db = await database;
    final maps = await db.query(
      tableShoppingList,
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );

    if (maps.isNotEmpty) {
      return ShoppingList.fromMap(maps.first);
    }

    return null;
  }

  // Methods for shopping_items table
  Future<List<GroceryItem>> getItems() async {
    final db = await database;
    final result = await db.query(tableShoppingItems);
    return result.map((item) => GroceryItem.fromMap(item)).toList();
  }

  Future<int> addItem(GroceryItem item) async {
    final db = await database;
    final itemId = await db.insert(
      tableShoppingItems,
      item.toMap()..remove('id'),
    );

    return itemId;
  }

  void updateItem(GroceryItem item) async {
    final db = await database;
    await db.update(
      tableShoppingItems,
      item.toMap()..remove('id'),
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  void deleteItem(int id) async {
    final db = await database;
    await db.delete(
      tableShoppingItems,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

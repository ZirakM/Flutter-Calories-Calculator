import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'food.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await initDatabase();
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'food_database.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT, calories INTEGER, date TEXT)',
    );
    await _insertInitialFoodItems(db);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> _insertInitialFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Almonds (1 oz)', 'calories': 160},
      {'name': 'Banana (medium)', 'calories': 105},
      {'name': 'Chicken Breast (cooked, 3 oz)', 'calories': 165},
      {'name': 'Broccoli (1 cup, chopped)', 'calories': 55},
      {'name': 'Salmon (cooked, 3 oz)', 'calories': 175},
      {'name': 'Oats (1 cup, cooked)', 'calories': 147},
      {'name': 'Avocado (1/2 medium)', 'calories': 120},
      {'name': 'Quinoa (cooked, 1 cup)', 'calories': 222},
      {'name': 'Egg (boiled, large)', 'calories': 68},
      {'name': 'Sweet Potato (baked, medium)', 'calories': 103},
      {'name': 'Spinach (1 cup, cooked)', 'calories': 41},
      {'name': 'Greek Yogurt (1 cup)', 'calories': 150},
      {'name': 'Apple (medium)', 'calories': 95},
      {'name': 'Carrot (1 cup, chopped)', 'calories': 52},
      {'name': 'Brown Rice (cooked, 1 cup)', 'calories': 215},
      {'name': 'Cheese (cheddar, 1 oz)', 'calories': 113},
      {'name': 'Ground Beef (cooked, 3 oz)', 'calories': 213},
      {'name': 'Peanut Butter (2 tbsp)', 'calories': 180},
      {'name': 'Orange (medium)', 'calories': 62},
      {'name': 'Whole Wheat Bread (1 slice)', 'calories': 69},
    ];

    for (final foodItem in foodItems) {
      await db.insert(
        'foods',
        foodItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertFood(String name, int calories, String date) async {
    final db = await database;
    await db
        .insert('foods', {'name': name, 'calories': calories, 'date': date});
  }

  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await database;
    return db.query('foods');
  }

  Future<List<Food>> getMealPlanForDate(String date) async {
    final db = await database;
    final result =
        await db.query('foods', where: 'date = ?', whereArgs: [date]);
    return result.map((map) => Food.fromMap(map)).toList();
  }

  Future<void> updateFood(
      int id, String name, int calories, String date) async {
    final db = await database;
    await db.update(
      'foods',
      {'name': name, 'calories': calories, 'date': date},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }
}

import '../db/app_database.dart';
import '../models/meat_item.dart';

class MeatItemRepository {
  Future<int> insert(MeatItem item) async {
    final db = await AppDatabase.instance.database;
    return db.insert('meat_items', item.toMap());
  }

  Future<List<MeatItem>> getAllOrderedByExpiry() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('meat_items', orderBy: 'expiryDate ASC');
    return maps.map(MeatItem.fromMap).toList();
  }

  Future<MeatItem?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'meat_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MeatItem.fromMap(maps.first);
  }

  Future<int> update(MeatItem item) async {
    final db = await AppDatabase.instance.database;
    return db.update(
      'meat_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('meat_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> existsSimilarItem({
    required String meatType,
    required DateTime expiryDate,
    required String imagePath,
  }) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'meat_items',
      where: 'meatType = ? AND expiryDate = ? AND imagePath = ?',
      whereArgs: [meatType, expiryDate.toIso8601String(), imagePath],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}

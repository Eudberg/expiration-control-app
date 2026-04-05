import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  AppDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meat_expiry.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meat_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meatType TEXT NOT NULL,
            expiryDate TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            initialQuantity REAL NOT NULL,
            remainingQuantity REAL NOT NULL,
            unit TEXT NOT NULL,
            imagePath TEXT NOT NULL,
            ocrText TEXT NOT NULL,
            status TEXT NOT NULL,
            notes TEXT NOT NULL
          )
        ''');
      },
    );
  }
}

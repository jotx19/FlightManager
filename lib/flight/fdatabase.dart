import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'flight.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flights.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        departureCity TEXT,
        destinationCity TEXT,
        departureTime TEXT,
        arrivalTime TEXT
      )
    ''');
  }

  Future<int> addFlight(Flight flight) async {
    final db = await database;
    return await db.insert('flights', flight.toMap());
  }

  Future<int> updateFlight(Flight flight) async {
    final db = await database;
    return await db.update(
      'flights',
      flight.toMap(),
      where: 'id = ?',
      whereArgs: [flight.id],
    );
  }

  Future<int> deleteFlight(int id) async {
    final db = await database;
    return await db.delete(
      'flights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Flight>> getFlights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('flights');

    return List.generate(maps.length, (i) {
      return Flight.fromMap(maps[i]);
    });
  }
}

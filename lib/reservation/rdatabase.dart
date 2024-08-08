import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../reservation/reservation.dart';

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
    final path = join(dbPath, 'reservations.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        flightId INTEGER,
        reservationName TEXT,
        reservationDate TEXT
      )
    ''');
  }

  Future<List<Reservation>> getReservations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reservations');

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  Future<int> addReservation(Reservation reservation) async {
    final db = await database;
    return await db.insert('reservations', reservation.toMap());
  }

  Future<int> updateReservation(Reservation reservation) async {
    final db = await database;
    return await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<int> deleteReservation(int id) async {
    final db = await database;
    return await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
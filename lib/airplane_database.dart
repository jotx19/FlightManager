import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'airplane.dart';
import 'airplane_dao.dart';

// Add this line to import the generated part
part 'airplane_database.g.dart';

@Database(version: 1, entities: [Airplane])
abstract class AirplaneDatabase extends FloorDatabase {
  AirplaneDao get airplaneDao;

  // Singleton pattern for database instance
  static final _instance = Completer<AirplaneDatabase>();

  static Future<AirplaneDatabase> get instance async {
    if (!_instance.isCompleted) {
      final database = await $FloorAirplaneDatabase
          .databaseBuilder('airplane_database.db')
          .build();
      _instance.complete(database);
    }
    return _instance.future;
  }

  // Provide a convenient way to get airplanes
  static Future<List<Airplane>> getAirplanes() async {
    final db = await instance;
    return db.airplaneDao.findAllAirplanes();
  }
}

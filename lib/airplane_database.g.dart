// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airplane_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAirplaneDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AirplaneDatabaseBuilder databaseBuilder(String name) =>
      _$AirplaneDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AirplaneDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AirplaneDatabaseBuilder(null);
}

class _$AirplaneDatabaseBuilder {
  _$AirplaneDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AirplaneDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AirplaneDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AirplaneDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AirplaneDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AirplaneDatabase extends AirplaneDatabase {
  _$AirplaneDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AirplaneDao? _airplaneDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Airplane` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` TEXT NOT NULL, `numberOfPassengers` INTEGER NOT NULL, `maxSpeed` REAL NOT NULL, `range` REAL NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AirplaneDao get airplaneDao {
    return _airplaneDaoInstance ??= _$AirplaneDao(database, changeListener);
  }
}

class _$AirplaneDao extends AirplaneDao {
  _$AirplaneDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'Airplane',
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'numberOfPassengers': item.numberOfPassengers,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                }),
        _airplaneUpdateAdapter = UpdateAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'numberOfPassengers': item.numberOfPassengers,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                }),
        _airplaneDeletionAdapter = DeletionAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'numberOfPassengers': item.numberOfPassengers,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final UpdateAdapter<Airplane> _airplaneUpdateAdapter;

  final DeletionAdapter<Airplane> _airplaneDeletionAdapter;

  @override
  Future<List<Airplane>> findAllAirplanes() async {
    return _queryAdapter.queryList('SELECT * FROM Airplane',
        mapper: (Map<String, Object?> row) => Airplane(
            id: row['id'] as int?,
            type: row['type'] as String,
            numberOfPassengers: row['numberOfPassengers'] as int,
            maxSpeed: row['maxSpeed'] as double,
            range: row['range'] as double));
  }

  @override
  Future<void> insertAirplane(Airplane airplane) async {
    await _airplaneInsertionAdapter.insert(airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAirplane(Airplane airplane) async {
    await _airplaneUpdateAdapter.update(airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAirplane(Airplane airplane) async {
    await _airplaneDeletionAdapter.delete(airplane);
  }
}

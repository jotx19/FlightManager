import 'package:flutter/material.dart';
import 'airplane.dart';
import 'airplane_database.dart';

class AirplaneListProvider extends ChangeNotifier {
  List<Airplane> _airplanes = [];

  List<Airplane> get airplanes => _airplanes;

  void addAirplane(Airplane airplane) async {
    final db = await AirplaneDatabase.instance;
    await db.airplaneDao.insertAirplane(airplane);
    loadAirplanes();
  }

  void updateAirplane(Airplane airplane) async {
    final db = await AirplaneDatabase.instance;
    await db.airplaneDao.updateAirplane(airplane);
    loadAirplanes();
  }

  void deleteAirplane(int? id) async {
    if (id != null) {
      final db = await AirplaneDatabase.instance;
      await db.airplaneDao.deleteAirplane(Airplane(id: id, type: '', numberOfPassengers: 0, maxSpeed: 0, range: 0));
      loadAirplanes();
    }
  }

  Future<void> loadAirplanes() async {
    final db = await AirplaneDatabase.instance;
    _airplanes = await db.airplaneDao.findAllAirplanes();
    notifyListeners();
  }
}

import 'package:floor/floor.dart';

@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String type;
  final int numberOfPassengers;
  final double maxSpeed;
  final double range;

  Airplane({
    this.id,
    required this.type,
    required this.numberOfPassengers,
    required this.maxSpeed,
    required this.range,
  });
}

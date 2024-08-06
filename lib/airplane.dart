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

  // Convert an Airplane object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'numberOfPassengers': numberOfPassengers,
      'maxSpeed': maxSpeed,
      'range': range,
    };
  }

  // Convert a Map object into an Airplane object
  factory Airplane.fromJson(Map<String, dynamic> json) {
    return Airplane(
      id: json['id'] as int?,
      type: json['type'] as String,
      numberOfPassengers: json['numberOfPassengers'] as int,
      maxSpeed: json['maxSpeed'] as double,
      range: json['range'] as double,
    );
  }
}

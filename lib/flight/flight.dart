class Flight {
  final int? id; // ID can be null initially
  final String departureCity;
  final String destinationCity;
  final DateTime departureTime;
  final DateTime arrivalTime;

  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  // Convert a Flight into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
    };
  }

  // Convert a Map into a Flight.
  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'],
      departureCity: map['departureCity'],
      destinationCity: map['destinationCity'],
      departureTime: DateTime.parse(map['departureTime']),
      arrivalTime: DateTime.parse(map['arrivalTime']),
    );
  }
}

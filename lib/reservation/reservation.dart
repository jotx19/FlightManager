class Reservation {
  final int? id; // ID can be null initially
  final int customerId;
  final int flightId;
  final String reservationName;
  final DateTime reservationDate;

  Reservation({
    this.id,
    required this.customerId,
    required this.flightId,
    required this.reservationName,
    required this.reservationDate,
  });

  // Convert a Reservation into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'flightId': flightId,
      'reservationName': reservationName,
      'reservationDate': reservationDate.toIso8601String(),
    };
  }

  // Convert a Map into a Reservation.
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      customerId: map['customerId'],
      flightId: map['flightId'],
      reservationName: map['reservationName'],
      reservationDate: DateTime.parse(map['reservationDate']),
    );
  }
}

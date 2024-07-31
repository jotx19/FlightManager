import 'package:flutter/material.dart';
import 'package:flightmanager/reservation/reservation.dart';
import 'package:flightmanager/reservation/reservationDetailPage.dart';
import '../reservation/rdatabase.dart';

class ReservationListPage extends StatefulWidget {
  @override
  _ReservationListPageState createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final DatabaseService _databaseService = DatabaseService();
  final List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final reservations = await _databaseService.getReservations();
      setState(() {
        _reservations.clear();
        _reservations.addAll(reservations);
      });
    } catch (e) {
      print('Error loading reservations: $e');
    }
  }

  void _navigateToReservationDetails({Reservation? reservation}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailsPage(
          reservation: reservation,
          onSave: (Reservation reservation) async {
            try {
              if (reservation.id == null) {
                await _databaseService.addReservation(reservation);
              } else {
                await _databaseService.updateReservation(reservation);
              }
              _loadReservations();
            } catch (e) {
              print('Error saving reservation: $e');
            }
          },
        ),
      ),
    );
  }

  void _deleteReservation(int id) async {
    try {
      await _databaseService.deleteReservation(id);
      _loadReservations();
    } catch (e) {
      print('Error deleting reservation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToReservationDetails(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return ListTile(
            title: Text(reservation.reservationName),
            subtitle: Text('Customer ID: ${reservation.customerId}, Flight ID: ${reservation.flightId}, Date: ${reservation.reservationDate.toLocal()}'),
            onTap: () => _navigateToReservationDetails(reservation: reservation),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteReservation(reservation.id!),
            ),
          );
        },
      ),
    );
  }
}

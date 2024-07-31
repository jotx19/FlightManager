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
      _showSnackBar('Error loading reservations: $e');
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
                _showSnackBar('Reservation added successfully.');
              } else {
                await _databaseService.updateReservation(reservation);
                _showSnackBar('Reservation updated successfully.');
              }
              _loadReservations();
            } catch (e) {
              _showSnackBar('Error saving reservation: $e');
            }
          },
        ),
      ),
    );
  }

  void _deleteReservation(int id) async {
    final confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      try {
        await _databaseService.deleteReservation(id);
        _showSnackBar('Reservation deleted successfully.');
        _loadReservations();
      } catch (e) {
        _showSnackBar('Error deleting reservation: $e');
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations List'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('How to use'),
                  content: Text(
                      'This application allows you to manage a list of reservations. You can add, update, and delete reservations.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _reservations.isEmpty
          ? Center(child: Text('No reservations available.'))
          : ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return ListTile(
            title: Text(reservation.reservationName),
            subtitle: Text(
                'Customer ID: ${reservation.customerId}, Flight ID: ${reservation.flightId}, Date: ${reservation.reservationDate.toLocal()}'),
            onTap: () => _navigateToReservationDetails(
                reservation: reservation),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteReservation(reservation.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToReservationDetails(),
        child: Icon(Icons.add),
      ),
    );
  }
}

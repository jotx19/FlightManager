import 'package:flutter/material.dart';
import '../flight/fdatabase.dart';
import '../flight/flight.dart';
import '../flight/flightDetailPage.dart';

class FlightsListPage extends StatefulWidget {
  @override
  _FlightsListPageState createState() => _FlightsListPageState();
}

class _FlightsListPageState extends State<FlightsListPage> {
  final DatabaseService _databaseService = DatabaseService();
  final List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    try {
      final flights = await _databaseService.getFlights();
      setState(() {
        _flights.clear();
        _flights.addAll(flights);
      });
    } catch (e) {
      _showSnackBar('Error loading flights: $e');
    }
  }

  void _navigateToFlightDetails({Flight? flight}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightDetailsPage(
          flight: flight,
          onSave: (Flight flight) async {
            try {
              if (flight.id == null) {
                await _databaseService.addFlight(flight);
                _showSnackBar('Flight added successfully.');
              } else {
                await _databaseService.updateFlight(flight);
                _showSnackBar('Flight updated successfully.');
              }
              _loadFlights();
            } catch (e) {
              _showSnackBar('Error saving flight: $e');
            }
          },
        ),
      ),
    );
  }

  void _deleteFlight(int id) async {
    final confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      try {
        await _databaseService.deleteFlight(id);
        _showSnackBar('Flight deleted successfully.');
        _loadFlights();
      } catch (e) {
        _showSnackBar('Error deleting flight: $e');
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this flight?'),
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
        title: Text('Flights List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToFlightDetails(),
          ),
        ],
      ),
      body: _flights.isEmpty
          ? Center(child: Text('No flights available.'))
          : ListView.builder(
        itemCount: _flights.length,
        itemBuilder: (context, index) {
          final flight = _flights[index];
          return ListTile(
            title: Text('${flight.departureCity} to ${flight.destinationCity}'),
            subtitle: Text('Departs: ${flight.departureTime}\nArrives: ${flight.arrivalTime}'),
            onTap: () => _navigateToFlightDetails(flight: flight),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteFlight(flight.id!),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../flight/fdatabase.dart';
import '../flight/flight.dart';
import '../flight/flightDetailPage.dart';
import '../flight/flightListPage.dart';

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
    final flights = await _databaseService.getFlights();
    setState(() {
      _flights.clear();
      _flights.addAll(flights);
    });
  }

  void _navigateToFlightDetails({Flight? flight}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightDetailsPage(
          flight: flight,
          onSave: (Flight flight) async {
            if (flight.id == null) {
              await _databaseService.addFlight(flight);
            } else {
              await _databaseService.updateFlight(flight);
            }
            _loadFlights();
          },
        ),
      ),
    );
  }

  void _deleteFlight(int id) async {
    await _databaseService.deleteFlight(id);
    _loadFlights();
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
      body: ListView.builder(
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

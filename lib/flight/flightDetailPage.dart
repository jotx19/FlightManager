import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'flight.dart';

class FlightDetailsPage extends StatefulWidget {
  final Flight? flight;
  final Function(Flight) onSave;

  FlightDetailsPage({this.flight, required this.onSave});

  @override
  _FlightDetailsPageState createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureCityController = TextEditingController();
  final TextEditingController _destinationCityController = TextEditingController();
  DateTime? _departureTime;
  DateTime? _arrivalTime;

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (widget.flight != null) {
      _loadFlightDetails(widget.flight!);
    } else {
      _promptLoadPreviousFlightDetails();
    }
  }

  Future<void> _saveFlightDetailsToStorage(Flight flight) async {
    await _secureStorage.write(key: 'departureCity', value: flight.departureCity);
    await _secureStorage.write(key: 'destinationCity', value: flight.destinationCity);
    await _secureStorage.write(key: 'departureTime', value: flight.departureTime.toIso8601String());
    await _secureStorage.write(key: 'arrivalTime', value: flight.arrivalTime.toIso8601String());
  }

  Future<Flight?> _loadFlightDetailsFromStorage() async {
    final departureCity = await _secureStorage.read(key: 'departureCity');
    final destinationCity = await _secureStorage.read(key: 'destinationCity');
    final departureTime = await _secureStorage.read(key: 'departureTime');
    final arrivalTime = await _secureStorage.read(key: 'arrivalTime');

    if (departureCity != null && destinationCity != null && departureTime != null && arrivalTime != null) {
      return Flight(
        departureCity: departureCity,
        destinationCity: destinationCity,
        departureTime: DateTime.parse(departureTime),
        arrivalTime: DateTime.parse(arrivalTime),
      );
    }
    return null;
  }

  void _loadFlightDetails(Flight flight) {
    _departureCityController.text = flight.departureCity;
    _destinationCityController.text = flight.destinationCity;
    _departureTime = flight.departureTime;
    _arrivalTime = flight.arrivalTime;
  }

  void _promptLoadPreviousFlightDetails() async {
    final previousFlight = await _loadFlightDetailsFromStorage();
    if (previousFlight != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Load Previous Flight'),
            content: Text('Do you want to load the details from the previous flight?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadFlightDetails(previousFlight);
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
    }
  }

  void _pickDateTime(BuildContext context, bool isDeparture) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isDeparture) {
            _departureTime = selectedDateTime;
          } else {
            _arrivalTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Text(
            'To add or edit a flight, fill in the departure and destination cities, then select the departure and arrival times. Click the save icon to save the flight.',
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? 'Add Flight' : 'Edit Flight'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInstructions(context),
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final flight = Flight(
                  id: widget.flight?.id,
                  departureCity: _departureCityController.text,
                  destinationCity: _destinationCityController.text,
                  departureTime: _departureTime!,
                  arrivalTime: _arrivalTime!,
                );
                widget.onSave(flight);
                _saveFlightDetailsToStorage(flight);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/planes.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _departureCityController,
                    decoration: InputDecoration(labelText: 'Departure City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the departure city';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _destinationCityController,
                    decoration: InputDecoration(labelText: 'Destination City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the destination city';
                      }
                      return null;
                    },
                  ),
                  ListTile(
                    title: Text(_departureTime == null
                        ? 'Select Departure Time'
                        : 'Departure: ${_departureTime!.toLocal()}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickDateTime(context, true),
                  ),
                  ListTile(
                    title: Text(_arrivalTime == null
                        ? 'Select Arrival Time'
                        : 'Arrival: ${_arrivalTime!.toLocal()}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickDateTime(context, false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

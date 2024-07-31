import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.flight != null) {
      _departureCityController.text = widget.flight!.departureCity;
      _destinationCityController.text = widget.flight!.destinationCity;
      _departureTime = widget.flight!.departureTime;
      _arrivalTime = widget.flight!.arrivalTime;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? 'Add Flight' : 'Edit Flight'),
        actions: [
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
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
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
    );
  }
}

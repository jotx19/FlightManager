import 'package:flightmanager/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReservationDetailsPage extends StatefulWidget {
  final Reservation? reservation;
  final Function(Reservation) onSave;

  ReservationDetailsPage({this.reservation, required this.onSave});

  @override
  _ReservationDetailsPageState createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reservationNameController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _flightIdController = TextEditingController();
  final _storage = FlutterSecureStorage();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _reservationNameController.text = widget.reservation!.reservationName;
      _customerIdController.text = widget.reservation!.customerId.toString();
      _flightIdController.text = widget.reservation!.flightId.toString();
      _selectedDate = widget.reservation!.reservationDate;
    } else {
      _loadLastUsedIds();
    }
  }

  Future<void> _loadLastUsedIds() async {
    _customerIdController.text = await _storage.read(key: 'lastCustomerId') ?? '';
    _flightIdController.text = await _storage.read(key: 'lastFlightId') ?? '';
  }

  Future<void> _saveLastUsedIds() async {
    await _storage.write(key: 'lastCustomerId', value: _customerIdController.text);
    await _storage.write(key: 'lastFlightId', value: _flightIdController.text);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservation == null ? 'Add Reservation' : 'Edit Reservation'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final reservation = Reservation(
                  id: widget.reservation?.id,
                  customerId: int.parse(_customerIdController.text),
                  flightId: int.parse(_flightIdController.text),
                  reservationName: _reservationNameController.text,
                  reservationDate: _selectedDate,
                );
                widget.onSave(reservation);
                _saveLastUsedIds();
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
                controller: _reservationNameController,
                decoration: InputDecoration(labelText: 'Reservation Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reservation name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerIdController,
                decoration: InputDecoration(labelText: 'Customer ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the customer ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _flightIdController,
                decoration: InputDecoration(labelText: 'Flight ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the flight ID';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Reservation Date: ${_selectedDate.toLocal()}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

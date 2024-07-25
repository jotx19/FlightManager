import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'airplane.dart';
import 'airplane_list_provider.dart';

class AirplaneDetailPage extends StatelessWidget {
  final Airplane airplane;

  AirplaneDetailPage({required this.airplane});

  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _passengersController = TextEditingController();
  final _speedController = TextEditingController();
  final _rangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Initialize controllers with airplane data
    _typeController.text = airplane.type;
    _passengersController.text = airplane.numberOfPassengers.toString();
    _speedController.text = airplane.maxSpeed.toString();
    _rangeController.text = airplane.range.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Airplane Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Airplane'),
                  content: Text('Are you sure you want to delete this airplane?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AirplaneListProvider>(context, listen: false)
                            .deleteAirplane(airplane.id!);
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Close the detail page
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
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
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the airplane type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passengersController,
                decoration: InputDecoration(labelText: 'Number of Passengers'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of passengers';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _speedController,
                decoration: InputDecoration(labelText: 'Max Speed'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the max speed';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rangeController,
                decoration: InputDecoration(labelText: 'Range'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the range';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedAirplane = Airplane(
                      id: airplane.id,
                      type: _typeController.text,
                      numberOfPassengers: int.parse(_passengersController.text),
                      maxSpeed: double.parse(_speedController.text),
                      range: double.parse(_rangeController.text),
                    );
                    Provider.of<AirplaneListProvider>(context, listen: false)
                        .updateAirplane(updatedAirplane);
                    Navigator.pop(context);
                  }
                },
                child: Text('Update Airplane'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

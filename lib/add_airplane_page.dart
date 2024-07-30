import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'airplane.dart';
import 'airplane_list_provider.dart';

class AddAirplanePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _passengersController = TextEditingController();
  final _speedController = TextEditingController();
  final _rangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Airplane',
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the airplane type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passengersController,
                decoration: InputDecoration(
                  labelText: 'Number of Passengers',
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of passengers';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _speedController,
                decoration: InputDecoration(
                  labelText: 'Max Speed',
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the max speed';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _rangeController,
                decoration: InputDecoration(
                  labelText: 'Range',
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the range';
                  }
                  return null;
                },
              ),
              SizedBox(height: 200),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final airplane = Airplane(
                      type: _typeController.text,
                      numberOfPassengers: int.parse(_passengersController.text),
                      maxSpeed: double.parse(_speedController.text),
                      range: double.parse(_rangeController.text),
                    );
                    Provider.of<AirplaneListProvider>(context, listen: false)
                        .addAirplane(airplane);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ), // foreground (text) color
                ),
                child: Text(
                  'Add Airplane',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

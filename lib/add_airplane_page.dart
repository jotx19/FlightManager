import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'airplane.dart';
import 'airplane_list_provider.dart';
import 'dart:convert';

class AddAirplanePage extends StatefulWidget {
  @override
  _AddAirplanePageState createState() => _AddAirplanePageState();
}

class _AddAirplanePageState extends State<AddAirplanePage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _passengersController = TextEditingController();
  final _speedController = TextEditingController();
  final _rangeController = TextEditingController();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  bool _copyPrevious = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousAirplane(); // Load data if available
  }

  void _loadPreviousAirplane() async {
    if (_copyPrevious) {
      String? airplaneData = await _prefs.getString('previous_airplane');
      if (airplaneData != null) {
        Airplane previousAirplane = Airplane.fromJson(jsonDecode(airplaneData));
        setState(() {
          _typeController.text = previousAirplane.type;
          _passengersController.text = previousAirplane.numberOfPassengers.toString();
          _speedController.text = previousAirplane.maxSpeed.toString();
          _rangeController.text = previousAirplane.range.toString();
        });
      }
    } else {
      _clearFields();
    }
  }

  void _clearFields() {
    setState(() {
      _typeController.clear();
      _passengersController.clear();
      _speedController.clear();
      _rangeController.clear();
    });
  }

  void _saveAirplane() async {
    if (_formKey.currentState!.validate()) {
      final airplane = Airplane(
        type: _typeController.text,
        numberOfPassengers: int.parse(_passengersController.text),
        maxSpeed: double.parse(_speedController.text),
        range: double.parse(_rangeController.text),
      );

      // Save the airplane data using Provider
      Provider.of<AirplaneListProvider>(context, listen: false).addAirplane(airplane);

      // Save the airplane details to EncryptedSharedPreferences
      await _prefs.setString('previous_airplane', jsonEncode(airplane.toJson()));

      Navigator.pop(context); // Go back after saving
    }
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Copy from previous airplane'),
                  value: _copyPrevious,
                  onChanged: (bool value) {
                    setState(() {
                      _copyPrevious = value;
                      _loadPreviousAirplane();
                    });
                  },
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAirplane,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
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
      ),
    );
  }
}

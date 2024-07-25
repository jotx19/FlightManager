import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'airplane.dart';
import 'add_airplane_page.dart';
import 'airplane_detail_page.dart';
import 'airplane_list_provider.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIST', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white24,
        actions: [
          IconButton(
            icon: Icon(Icons.error_outline, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Instructions'),
                  content: Text(
                      'To add an airplane, click the + button. Tap on an airplane to see details, update, or delete.',
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AirplaneListProvider>(
        builder: (context, provider, child) {
          if (provider.airplanes.isEmpty) {
            return Center(
              child: Text(
                'No airplanes available.',
                style: TextStyle(color: Colors.deepPurple, fontSize: 18),
              ),
            );
          }
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.white70,
                child: Column(
                  children: [
                    Text(
                      'List of Available Airplanes',
                      style: GoogleFonts.spaceGrotesk(
                        textStyle: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Circular border radius
                      child: Image.asset(
                        'assets/aeroplane.jpeg',
                        width: 400,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.airplanes.length,
                  itemBuilder: (context, index) {
                    final airplane = provider.airplanes[index];
                    return Dismissible(
                      key: Key(airplane.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        provider.deleteAirplane(airplane.id); // Corrected method name
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${airplane.type} deleted')),
                        );
                      },
                      background: Container(
                        color: Colors.red[100],
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(Icons.delete, color: Colors.black),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AirplaneDetailPage(airplane: airplane)),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                          color: Color(0xff2c3234),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            title: Text(
                              airplane.type,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            trailing: Icon(Icons.airplanemode_on_sharp, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAirplanePage()),
          );
        },
        child: Icon(Icons.add, color: Colors.black), // Set icon color to black
        backgroundColor: Colors.amber,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'airplane_list_page.dart';
import 'customer/customerPage.dart';
import 'airplane_list_provider.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  // Set the database factory
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AirplaneListProvider()..loadAirplanes()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Management System',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
            iconTheme: IconThemeData(color: Colors.black),
            toolbarTextStyle: TextTheme(
              headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
            ).bodyText2,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54),
            titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: MainPage(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // American English
          const Locale('en', 'GB'), // British English
        ],
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Management System',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AirplaneListPage()),
                );
              },
              child: Text('Airplane List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerPage()),
                );
              },
              child: Text('Customer List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Add other buttons for different parts of the project
          ],
        ),
      ),
    );
  }
}

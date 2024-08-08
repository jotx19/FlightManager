import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // To check the platform
import 'airplane_list_provider.dart';
import 'airplane_list_page.dart';
import 'customer/customerPage.dart';
import 'flight/flightListPage.dart';
import 'reservation/reservationListPage.dart';

void main() {
  // Platform-specific database initialization
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Mobile platforms will use the default sqflite database factory
    databaseFactory = databaseFactory;
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            iconTheme: IconThemeData(color: Colors.black),
            toolbarTextStyle: TextTheme(
              headline6: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ).bodyText2,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54),
            titleLarge: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
        locale: _locale,
        supportedLocales: [
          const Locale('en', 'US'), // American English
          const Locale('en', 'GB'), // British English
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MainPage(
          onLocaleChange: _setLocale,
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  MainPage({required this.onLocaleChange});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  List<QuickAccessItem> _quickAccessItems = [];
  List<QuickAccessItem> _filteredItems = [];
  String _selectedLanguage = 'en_US';

  @override
  void initState() {
    super.initState();
    _quickAccessItems = [
      QuickAccessItem('Airplane List', AirplaneListPage()),
      QuickAccessItem('Customer List', CustomerPage()),
      QuickAccessItem('Flights List', FlightsListPage()),
      QuickAccessItem('Reservations List', ReservationListPage()),
    ];
    _filteredItems = List.from(_quickAccessItems);

    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _quickAccessItems.where((item) {
        return item.label.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _changeLanguage(String languageCode) {
    Locale locale;
    switch (languageCode) {
      case 'en_US':
        locale = Locale('en', 'US');
        break;
      case 'en_GB':
        locale = Locale('en', 'GB');
        break;
      default:
        locale = Locale('en', 'US');
    }
    widget.onLocaleChange(locale);
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Management System'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            icon: Icon(Icons.language, color: Colors.black),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem(
                value: 'en_US',
                child: Text('English (US)'),
              ),
              DropdownMenuItem(
                value: 'en_GB',
                child: Text('English (UK)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/hero.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.2),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "Flight Management System",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                          hintText: "Search...",
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Management Options",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        makeItem(
                          image: 'assets/types.jpg',
                          title: 'Airplane',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AirplaneListPage()),
                            );
                          },
                        ),
                        makeItem(
                          image: 'assets/customer.jpeg',
                          title: 'Customer',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CustomerPage()),
                            );
                          },
                        ),
                        makeItem(
                          image: 'assets/travel.jpg',
                          title: 'Flights',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FlightsListPage()),
                            );
                          },
                        ),
                        makeItem(
                          image: 'assets/reservation.jpg',
                          title: 'Reservation',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReservationListPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Quick Access",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return quickAccessButton(
                          context: context,
                          label: _filteredItems[index].label,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => _filteredItems[index].page),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget makeItem({required String image, required String title, required Function() onTap}) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget quickAccessButton({required BuildContext context, required String label, required Function() onPressed}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }
}

class QuickAccessItem {
  final String label;
  final Widget page;

  QuickAccessItem(this.label, this.page);
}

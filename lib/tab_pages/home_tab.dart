import 'package:car_owner/screens/car_register%20_screen.dart';
import 'package:car_owner/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../data_handler/app_data.dart';

import '../screens/driver_account_creation.dart';
import '../main.dart';

class CarOwnerHomePage extends StatefulWidget {
  @override
  _CarOwnerHomePageState createState() => _CarOwnerHomePageState();
}

class _CarOwnerHomePageState extends State<CarOwnerHomePage> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  int _carCount = 0;
  int _driverCount = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      await _fetchCounts();
    } else {
      print('No user is currently logged in.');
    }
  }

  Future<void> _fetchCounts() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('car_owners').child(_currentUser!.uid);

      userRef.child('cars').once().then((snapshot) {
        setState(() {
          _carCount = snapshot.snapshot.children.length;
        });
      });

      userRef.child('drivers').once().then((snapshot) {
        setState(() {
          _driverCount = snapshot.snapshot.children.length;
        });
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _navigateAndLoad(Widget page) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _navigateToDriverTab() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    MainScreen.changeTab(context, 2); // 2 is the index of the Drivers tab
  }

  @override
  Widget build(BuildContext context) {
    AppData languageProvider = Provider.of<AppData>(context);
    var language = languageProvider.isEnglishSelected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        title: Text(language ? 'Car Owner Hub' : "የመኪና ባለቤት ገጽ"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              language ? 'Registration' : "ምዝገባ",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.0),

            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      language ? 'Register Cars' : "መኪኖች ይመዝገቡ",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: () => _navigateAndLoad(CarRegisterPage()),
                      icon: Icon(Icons.directions_car),
                      label: Text(language ? 'Register Car' : "መኪኖች ይመዝገቡ"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),

            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      language ? 'Register Drivers' : "ነጂዎችን ይመዝገቡ",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: _navigateToDriverTab,
                      icon: Icon(Icons.person),
                      label: Text(language ? 'Register Driver' : "ነጂዎችን ይመዝገቡ"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),

            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      language ? 'Car and Driver Counts' : "የመኪና እና የአሽከርካሪዎች ብዛት",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Number of Cars: $_carCount',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Number of Drivers: $_driverCount',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

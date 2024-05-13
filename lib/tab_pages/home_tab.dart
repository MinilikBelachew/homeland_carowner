import 'package:car_owner/methods/car_registration_assistant_methods.dart';
import 'package:car_owner/screens/car_register%20_screen.dart';
import 'package:car_owner/tab_pages/driver_account_creation.dart';
import 'package:flutter/material.dart';

class CarOwnerHomePage extends StatefulWidget {
  @override
  _CarOwnerHomePageState createState() => _CarOwnerHomePageState();
}

class _CarOwnerHomePageState extends State<CarOwnerHomePage> {
  // Add any state variables needed for car and driver registration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        title: Text('Car Owner Hub'),
        actions: [
          // Settings Menu Button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings menu click (optional)
              print('Settings Clicked');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Registration Section Title with modern text styling
            Text(
              'Registration',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.0),

            // Car Registration Section with rounded corners and elevated button
            Card(
              elevation: 4.0, // Add a slight elevation for depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Register Cars',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Implement functionality to navigate to car registration page
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to car registration page
                         Navigator.push(context, MaterialPageRoute(builder:(contex) =>  CarRegisterPage()));
                      },
                      icon: Icon(Icons.directions_car),
                      label: Text('Register Car'),
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

            // Driver Registration Section with similar styling
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
                      'Register Drivers',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Implement functionality to navigate to driver registration page
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to driver registration page
                        Navigator.push(context, MaterialPageRoute(builder:(contex) =>  DriverRegistrationForm()));
                      },
                      icon: Icon(Icons.person),
                      label: Text('Register Driver'),
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

            // Essential Car Owner Information Card with divider
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
                      'Essential Information:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Divider(
                      // Add a divider line
                      height: 1.0,
                      thickness: 1.0,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 10.0),
                    ListTile(
                      leading: Icon(Icons.assignment),
                      title: Text('Insurance'),
                      trailing: Icon(Icons.arrow_right),
                    ),
                    ListTile(
                      leading: Icon(Icons.playlist_add_check),
                      title: Text('Registration & Inspection'),
                      trailing: Icon(Icons.arrow_right),
                    ),
                    ListTile(
                      leading: Icon(Icons.local_gas_station),
                      title: Text('Maintenance Records'),
                      trailing: Icon(Icons.arrow_right),
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
}

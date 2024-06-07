import 'package:car_owner/config_maps.dart';
import 'package:car_owner/main.dart';
import 'package:car_owner/methods/car_registration_assistant_methods.dart';
import 'package:car_owner/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CarRegisterPage extends StatefulWidget {
  @override
  _CarRegisterPageState createState() => _CarRegisterPageState();
}

class _CarRegisterPageState extends State<CarRegisterPage> {
  final TextEditingController numberOfCarsController = TextEditingController();
  final List<CarDetail> carDetails = [];
  bool _isLoading = false;

  void addCarDetail() {
    setState(() {
      final numberOfCars = int.tryParse(numberOfCarsController.text) ?? 0;
      carDetails.clear();
      for (int i = 0; i < numberOfCars; i++) {
        carDetails.add(CarDetail());
      }
    });
  }

  Future<void> registerCars() async {
    try {
      if (currentfirebaseUser == null) {
        throw Exception('User not authenticated');
      }

      String userId = currentfirebaseUser!.uid;

      for (final carDetail in carDetails) {
        final carData = {
          'make': carDetail.makeController.text,
          'model': carDetail.modelController.text,
          'year': carDetail.yearController.text,
          'plateNumber': carDetail.plateNumberController.text,
          'bodyType': carDetail.bodyTypeController.text,
          'color': carDetail.colorController.text,
          'truckType': carDetail.truckType,
        };
        await car_ownerRref.child(userId).child("cars").push().set(carData);
      }

      // Navigate to the main screen after car registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      print('Error registering cars: $e');
      // Handle car registration errors here, for example, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering cars: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Cars'),
        backgroundColor: Colors.blue, // Example color change
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: numberOfCarsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Cars',
                errorText: _getNumberOfCarsError(), // Add error handling
              ),
            ),
            SizedBox(height: 5.0),
            ElevatedButton(
              onPressed: addCarDetail,
              child: Text('Add Car Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Example color change
              ),
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: PageView.builder(
                itemCount: carDetails.length,
                itemBuilder: (context, index) {
                  return CarDetailCard(
                      carDetail: carDetails[index], index: index + 1);
                },
                controller: PageController(viewportFraction: 0.8), // Adjust viewport size
                scrollDirection: Axis.horizontal,
                physics: PageScrollPhysics(), // Enable page-by-page scrolling
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _confirmRegistration(context), // Wrap in confirmation dialog
              child: Text('Register Cars'),
            ),
          ],
        ),
      ),
    );
  }

  String? _getNumberOfCarsError() {
    final text = numberOfCarsController.text;
    if (text.isEmpty) {
      return 'Please enter the number of cars';
    }
    final number = int.tryParse(text);
    if (number == null || number <= 0) {
      return 'Please enter a valid number of cars';
    }
    return null;
  }

  void _confirmRegistration(BuildContext context) async {
    final shouldRegister = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Car Registration'),
        content: Text('Are you sure you want to register these cars?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Register
            child: Text('Register'),
          ),
        ],
      ),
    );

    if (shouldRegister == true) {
      setState(() => _isLoading = true);
      await registerCars();
      setState(() => _isLoading = false);
      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cars registered successfully!')),
      );
    }
  }
}

class CarDetail {
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController bodyTypeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  String truckType = 'light trucks'; // Default value

// Add more fields as needed
}

class CarDetailCard extends StatelessWidget {
  final CarDetail carDetail;
  final int index;

  CarDetailCard({required this.carDetail, required this.index});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Car $index',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: carDetail.makeController,
                decoration: InputDecoration(labelText: 'Make'),
              ),
              TextField(
                controller: carDetail.modelController,
                decoration: InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: carDetail.yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carDetail.plateNumberController,
                decoration: InputDecoration(labelText: 'Plate Number'),
              ),
              TextField(
                controller: carDetail.bodyTypeController,
                decoration: InputDecoration(labelText: 'Body Type'),
              ),
              TextField(
                controller: carDetail.colorController,
                decoration: InputDecoration(labelText: 'Color'),
              ),
              DropdownButtonFormField<String>(
                value: carDetail.truckType,
                decoration: InputDecoration(labelText: 'Truck Type'),
                items: [
                  DropdownMenuItem(value: 'light trucks', child: Text('Light Trucks')),
                  DropdownMenuItem(value: 'medium trucks', child: Text('Medium Trucks')),
                  DropdownMenuItem(value: 'heavy trucks', child: Text('Heavy Trucks')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    carDetail.truckType = value;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:car_owner/config_maps.dart'
// import 'package:car_owner/main.dart';
// import 'package:car_owner/methods/car_registration_assistant_methods.dart';
// import 'package:car_owner/screens/main_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class CarRegisterPage extends StatefulWidget {
//   @override
//   _CarRegisterPageState createState() => _CarRegisterPageState();
// }
//
// class _CarRegisterPageState extends State<CarRegisterPage> {
//   final TextEditingController numberOfCarsController = TextEditingController();
//   final List<CarDetail> carDetails = [];
//   bool _isLoading = false;
//
//   void addCarDetail() {
//     setState(() {
//       final numberOfCars = int.tryParse(numberOfCarsController.text) ?? 0;
//       carDetails.clear();
//       for (int i = 0; i < numberOfCars; i++) {
//         carDetails.add(CarDetail());
//       }
//     });
//   }
//
//   Future<void> registerCars() async {
//     try {
//       String userId = currentfirebaseUser!.uid;
//
//       if (currentfirebaseUser == null) {
//         throw Exception('User not authenticated');
//       }
//
//       for (final carDetail in carDetails) {
//         final carData = {
//           'make': carDetail.makeController.text,
//           'model': carDetail.modelController.text,
//           'year': carDetail.yearController.text,
//           'plateNumber': carDetail.plateNumberController.text,
//           'bodyType': carDetail.bodyTypeController.text,
//           'color': carDetail.colorController.text,
//         };
//         car_ownerRref.child(userId).child("cars").push().set(carData);
//       }
//
//       // Navigate to the home screen or any other screen after car registration
//     } catch (e) {
//       print('Error registering cars: $e');
//       // Handle car registration errors here
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register Cars'),
//         backgroundColor: Colors.blue, // Example color change
//       ),
//       body: _isLoading
//           ? Center(
//         child: CircularProgressIndicator(),
//       )
//           : Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               controller: numberOfCarsController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Number of Cars',
//                 errorText: _getNumberOfCarsError(), // Add error handling
//               ),
//             ),
//             SizedBox(height: 5.0),
//             ElevatedButton(
//               onPressed: addCarDetail,
//               child: Text('Add Car Details'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueGrey, // Example color change
//               ),
//             ),
//             SizedBox(height: 5.0),
//             Expanded(
//               child: PageView.builder(
//                 itemCount: carDetails.length,
//                 itemBuilder: (context, index) {
//                   return CarDetailCard(carDetail: carDetails[index], index: index + 1);
//                 },
//                 controller: PageController(viewportFraction: 0.8), // Adjust viewport size
//                 scrollDirection: Axis.horizontal,
//                 physics: PageScrollPhysics(), // Enable page-by-page scrolling
//               ),
//             ),
//
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () => _confirmRegistration(context), // Wrap in confirmation dialog
//               child: Text('Register Cars'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String? _getNumberOfCarsError() {
//     final text = numberOfCarsController.text;
//     if (text.isEmpty) {
//       return 'Please enter the number of cars';
//     }
//     final number = int.tryParse(text);
//     if (number == null || number <= 0) {
//       return 'Please enter a valid number of cars';
//     }
//     return null;
//   }
//
//   void _confirmRegistration(BuildContext context) async {
//     final shouldRegister = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Car Registration'),
//         content: Text('Are you sure you want to register these cars?'),
//         actions: [
//           TextButton(
//             onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder:(contex) =>  MainScreen())), // Cancel
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true), // Register
//             child: Text('Register'),
//           ),
//         ],
//       ),
//     );
//
//
//
//     if (shouldRegister ?? false) {
//       setState(() => _isLoading = true);
//       await registerCars();
//       setState(() => _isLoading = false);
//       // Show success message or navigate to another screen
//     }
//   }
// }
//

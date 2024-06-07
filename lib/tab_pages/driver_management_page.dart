import 'dart:io';
import 'package:car_owner/screens/edit_driver_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/driver_account_creation.dart';

class Driver {
  final String key;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String frontIdImageUrl;
  final String backIdImageUrl;

  Driver({
    required this.key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.frontIdImageUrl,
    required this.backIdImageUrl,
  });
}

class DriverManagementPage extends StatefulWidget {
  @override
  _DriverManagementPageState createState() => _DriverManagementPageState();
}

class _DriverManagementPageState extends State<DriverManagementPage>  with AutomaticKeepAliveClientMixin {
  final DatabaseReference driversRef = FirebaseDatabase.instance
      .ref()
      .child('car_owners')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child('drivers');
  List<Driver> driversList = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    try {
      DatabaseEvent event = await driversRef.once();
      if (event.snapshot.value != null) {
        setState(() {
          driversList = (event.snapshot.value as Map<dynamic, dynamic>)
              .entries
              .map((entry) {
            var driverData = Map<String, dynamic>.from(entry.value);
            return Driver(
              key: entry.key,
              name: driverData['name'] ?? '',
              email: driverData['email'] ?? '',
              phoneNumber: driverData['phoneNumber'] ?? '',
              address: driverData['address'] ?? '',
              frontIdImageUrl: driverData['front_id_img'] ?? '',
              backIdImageUrl: driverData['back_id_img'] ?? '',
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          driversList = [];
        });
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> deleteDriver(String driverKey) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await driversRef.child(driverKey).remove();
      fetchDrivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Management'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
          child: Text('Error loading drivers. Please try again later.'))
          : driversList.isEmpty
          ? Center(child: Text('No drivers found.'))
          : ListView.builder(
        itemCount: driversList.length,
        itemBuilder: (context, index) {
          final driver = driversList[index];
          return Card(
            margin: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text(driver.name),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(driver.address),
                      Text(driver.phoneNumber),
                      //Text(driver.address),
                    ],
                  ),


                  Row(children: [
                    if (driver.frontIdImageUrl.isNotEmpty)
                      Image.network(
                        driver.frontIdImageUrl,
                        height: 50,
                        width: 50,
                      ),
                    if (driver.backIdImageUrl.isNotEmpty)
                      Image.network(
                        driver.backIdImageUrl,
                        height: 50,
                        width: 50,
                      ),

                  ],),

                ],
              ),
              trailing: Row(

                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditDriverInfoScreen(
                                driverKey: driver.key,
                                name: driver.name,
                                email: driver.email,
                                phoneNumber: driver.phoneNumber,
                                address: driver.address,
                                frontIdImg: driver.frontIdImageUrl,
                                backIdImg: driver.backIdImageUrl,
                              ),
                        ),
                      ).then((_) {
                        fetchDrivers();
                      });
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.redAccent.shade700,
                    onPressed: () => deleteDriver(driver.key),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DriverRegistrationForm()),
          ).then((_) {
            fetchDrivers();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}




//   @override
//   _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
// }
//
// class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneNumberController;
//   late TextEditingController _addressController;
//   File? _frontIdImage;
//   File? _backIdImage;
//
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _emailController = TextEditingController();
//     _phoneNumberController = TextEditingController();
//     _addressController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneNumberController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       // Form is valid, proceed with registration
//       // Code to handle registration
//     }
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedImage = await ImagePicker().pickImage(source: source);
//
//     if (pickedImage != null) {
//       setState(() {
//         if (_frontIdImage == null) {
//           _frontIdImage = File(pickedImage.path);
//         } else if (_backIdImage == null) {
//           _backIdImage = File(pickedImage.path);
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Registration'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.blueGrey[200]!, Colors.blueGrey[700]!],
//             ),
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a name';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an email';
//                     } else if (!RegExp(r'^[^@]+@[^@]+.[^@]+').hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _phoneNumberController,
//                   decoration: InputDecoration(
//                     labelText: 'Phone Number',
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a phone number';
//                     } else if (!RegExp(r'^\d+$').hasMatch(value)) {
//                       return 'Please enter a valid phone number';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     labelText: 'Address',
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an address';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => _pickImage(ImageSource.camera),
//                       child: Text('Take Front ID Image'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => _pickImage(ImageSource.camera),
//                       child: Text('Take Back ID Image'),
//                     ),
//                   ],
//                 ),
//                 if (_frontIdImage != null)
//                   Image.file(
//                     _frontIdImage!,
//                     height: 100,
//                     width: 100,
//                   ),
//                 if (_backIdImage != null)
//                   Image.file(
//                     _backIdImage!,
//                     height: 100,
//                     width: 100,
//                   ),
//                 SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _submitForm,
//                     child: Text('Register Driver'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




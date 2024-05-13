import 'dart:io';
import 'package:car_owner/config_maps.dart';
import 'package:car_owner/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class Driver {
  String name;
  String email;
  String phoneNumber;
  String password;
  String frontimagecontrol;
  String backimagecontrol;

  List<String> assignedCars;

  Driver(
      {required this.name,
      required this.email,
      required this.phoneNumber,
      required this.password,
      required this.assignedCars,
      required this.backimagecontrol,
      required this.frontimagecontrol});
}

class DriverRegistrationForm extends StatefulWidget {
  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  TextEditingController frontImageController = TextEditingController();
  TextEditingController backImageController = TextEditingController();

  bool _showPassword =
      false; // Declare a boolean variable to track password visibility

  final _formKey = GlobalKey<FormState>();
  final _driver = Driver(
    name: '',
    email: '',
    phoneNumber: '',
    password: '',
    assignedCars: [],
    backimagecontrol: '',
    frontimagecontrol: '',
  );
  final List<String> _availableCars = [];
  String? _selectedCar;

  @override
  void initState() {
    super.initState();
    _loadAvailableCars();
  }

  void _loadAvailableCars() async {
    try {
      final DatabaseReference carsRef =
          FirebaseDatabase.instance.reference().child('car_owners');
      final DatabaseEvent event = await carsRef.once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final Map<dynamic, dynamic> carOwnersMap =
            snapshot.value as Map<dynamic, dynamic>;
        carOwnersMap.forEach((carOwnerId, carOwnerData) {
          if (carOwnerData['cars'] != null) {
            final Map<dynamic, dynamic> carsMap =
                carOwnerData['cars'] as Map<dynamic, dynamic>;
            carsMap.forEach((carId, carData) {
              setState(() {
                _availableCars.add(carId);
              });
            });
          }
        });
      } else {
        print('No car owner data found in the database');
      }
    } catch (error) {
      print('Failed to load available cars: $error');
    }
  }

  String? frontImagePath;

  String? backImagePath;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 30),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  // Name field with icon
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _driver.name = value!;
                    },
                  ),
                  // Email field with validation message style
                  const SizedBox(height: 10.0), // Add spacing
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _driver.email = value!;
                    },
                    style: TextStyle(
                        color: Colors.grey[600]), // Optional: adjust text color
                  ),
                  // Phone number field with keyboard type
                  const SizedBox(height: 10.0), // Add spacing
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _driver.phoneNumber = value!;
                    },
                    keyboardType: TextInputType.phone, // Set keyboard type
                  ),
                  // Password field with toggle visibility
                  const SizedBox(height: 10.0), // Add spacing
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _driver.password = value!;
                    },
                  ),
                  // Car dropdown with custom styling
                  const SizedBox(height: 10.0),

                  SizedBox(
                    height: 10,
                  ),

                  TextFormField(
                    readOnly: true,
                    controller: frontImageController,
                    decoration: InputDecoration(
                      labelText: "Front ID Image",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _pickFrontImageCamera,
                          ),
                          IconButton(
                            icon: Icon(Icons.folder),
                            onPressed: _pickFrontImageGallery,
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter image';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      frontImageController.text = value!;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: backImageController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Back ID Image",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _pickBackImageCamera,
                          ),
                          IconButton(
                            icon: Icon(Icons.folder),
                            onPressed: _pickBackImageGallery,
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter image';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      backImageController.text = value!;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                  // Add spacing
                  DropdownButtonFormField<String>(
                    value: _selectedCar,
                    items: _availableCars.map((String carId) {
                      return DropdownMenuItem<String>(
                        value: carId,
                        child: Text(carId),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCar = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Car',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a car';
                      }
                      return null;
                    },
                    dropdownColor: Colors
                        .grey[200], // Set dropdown background color (optional)
                  ),
                  const SizedBox(height: 20.0), // Add spacing
                  // Register button with accent color
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Register Driver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Set button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadImages(String userId) async {
    if (frontImagePath != null) {
      await _uploadImage(userId, "front_image.jpg", frontImagePath!);
    }

    if (backImagePath != null) {
      await _uploadImage(userId, "back_image.jpg", backImagePath!);
    }
  }

  Future<void> _uploadImage(
      String userId, String imageName, String imagePath) async {
    try {
      File imageFile = File(imagePath);
      TaskSnapshot snapshot = await _storage
          .ref("drivers/$userId/$imageName")
          .putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      if (imageName == "front_image.jpg") {
        frontImagePath = downloadUrl;
      } else if (imageName == "back_image.jpg") {
        backImagePath = downloadUrl;
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _pickFrontImageCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        frontImagePath = pickedFile.path;
        frontImageController.text = pickedFile.path ?? '';
      });
    }
  }

  Future<void> _pickBackImageCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        backImagePath = pickedFile.path;
        backImageController.text = pickedFile.path ?? '';
      });
    }
  }

  Future<void> _pickFrontImageGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        frontImagePath = pickedFile.path;
        frontImageController.text = pickedFile.path ?? '';
      });
    }
  }

  Future<void> _pickBackImageGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        backImagePath = pickedFile.path;
        backImageController.text = pickedFile.path ?? '';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _registerDriver();
    }
  }

  void _registerDriver() async {
    try {
      String userId = currentfirebaseUser!.uid;

      DatabaseReference carRef =
          car_ownerRref.child(userId).child("cars").child(_selectedCar!);
      DataSnapshot carSnapshot = await carRef.get();

      if (!carSnapshot.exists) {
        throw Exception('Selected car does not exist in the database');
      }

      Map<dynamic, dynamic>? carData =
          carSnapshot.value as Map<dynamic, dynamic>?;

      if (carData == null) {
        throw Exception('Car data is null or not in the expected format');
      }

      String? bodyType = carData['bodyType'] as String?;
      String? color = carData['color'] as String?;
      String? make = carData['make'] as String?;
      String? model = carData['model'] as String?;
      String? plateNumber = carData['plateNumber'] as String?;
      String? year = carData['year'] as String?;

      if (bodyType == null ||
          color == null ||
          make == null ||
          model == null ||
          plateNumber == null ||
          year == null) {
        throw Exception(
            'Car data properties are null or not in the expected format');
      }

      // Register driver with retrieved car information
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _driver.email,
        password: _driver.password,
      );

      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(userCredential.user!.uid);

      // Generate a unique key for the driver
      String driverKey =
          FirebaseDatabase.instance.ref().child('drivers').push().key ?? '';

      // Set the driver's data using the unique key
      driverRef.set({
        'name': _driver.name,
        'email': _driver.email,
        'phoneNumber': _driver.phoneNumber,
        'password': _driver.password,
        'front_id_img':frontImagePath?? "",
        'back_id_img':backImagePath ?? "",
        'car_details': {
          'carId': _selectedCar,
          'bodyType': bodyType,
          'color': color,
          'make': make,
          'model': model,
          'plateNumber': plateNumber,
          'year': year,
        },
      });

      // Add a reference to the driver under the car owner's node using the unique key
      car_ownerRref.child(userId).child("drivers").child(driverKey).set({
        'name': _driver.name,
        'email': _driver.email,
        'phoneNumber': _driver.phoneNumber,
        'password': _driver.password,
        'front_id_img':frontImagePath?? "",
        'back_id_img':backImagePath ?? "",
        'carId': _selectedCar,
      });
      await uploadImages(userId);

      // Update car with driver ID (Optional)
      carRef.update({'driverId': userCredential.user!.uid});

      // Show success message or navigate to the next screen
    } catch (e) {
      print('Failed to register driver: $e');
      // Handle registration failure
    }
  }
}

// void _registerDriver() async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: _driver.email,
//       password: _driver.password,
//     );
//
//     // Fetch details of the assigned car
//     DatabaseReference carRef = FirebaseDatabase.instance.reference().child('car_owners').child(_selectedCar!);
//     DataSnapshot carSnapshot = await carRef.once().then((event) => event.snapshot);
//
//     if (carSnapshot.value != null) {
//       Map<String, dynamic>? assignedCarData = carSnapshot.value as Map<String, dynamic>?;
//
//       if (assignedCarData != null) {
//         // Create driver information
//         Map<String, dynamic> driverData = {
//           'name': _driver.name,
//           'email': _driver.email,
//           'phoneNumber': _driver.phoneNumber,
//           'assignedCar': assignedCarData,
//         };
//
//         // Save driver information to the database
//         DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers').child(userCredential.user!.uid);
//         driverRef.set(driverData);
//
//         // Update the assigned car with the driver's ID
//         carRef.update({'driverId': userCredential.user!.uid});
//
//         // Show success message or navigate to next screen
//       } else {
//         print('Error: Car details not found in the database');
//       }
//     }
//   } catch (e) {
//     print('Failed to register driver: $e');
//     // Handle registration failure
//   }
// }

// void _registerDriver() async {
//   try {
//     // 1. Check car data structure
//     DataSnapshot carSnapshot = await car_ownerRref.child(currentfirebaseUser!.uid).child(_selectedCar!).get();
//     // if (!(carSnapshot.value is Map<String, dynamic>)) {
//     //   throw Exception('Car data is not in the expected format');
//     // }
//
//     // 2. Extract car information from snapshot
//     //Map<String, dynamic> carData = carSnapshot.value as Map<String, dynamic>;
//     final carData = carSnapshot.value as Map<String, dynamic>?;
//
//     // 3. Check if car exists and handle errors
//     if (!carSnapshot.exists) {
//       throw Exception('Selected car does not exist in database');
//     }
//
//     // Extract car information directly from the car data map
//     String bodyType = carData?['bodyType']?? "";
//     String color = carData?['color']?? "";
//     String make = carData?['make']?? "";
//     String model = carData?['model'] ?? "";
//     String plateNumber = carData?['plateNumber']?? "";
//     String year = carData?['year']?? "";
//
//     // Register driver with retrieved car information
//     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: _driver.email,
//       password: _driver.password,
//     );
//     DatabaseReference driverRef = FirebaseDatabase.instance
//         .reference()
//         .child('drivers')
//         .child(userCredential.user!.uid);
//     driverRef.set({
//       'name': _driver.name,
//       'email': _driver.email,
//       'phoneNumber': _driver.phoneNumber,
//       'assignedCars': [carData], // Use the entire car data map
//     });
//
//     // Update car with driver ID (Optional)
//     // ... (same logic as before)
//
//     // Show success message or navigate to next screen
//   } catch (e) {
//     print('Failed to register driver: $e'); // Handle registration failure
//   }
// }

//
//

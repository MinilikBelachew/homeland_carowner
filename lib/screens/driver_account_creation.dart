
import 'dart:io';
import 'package:car_owner/config_maps.dart';
import 'package:car_owner/main.dart';
import 'package:car_owner/screens/main_screen.dart';
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
  String address;
  String frontImageControl;
  String backImageControl;
  List<String> assignedCars;

  Driver({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.address,
    required this.assignedCars,
    required this.frontImageControl,
    required this.backImageControl,
  });
}

class Car {
  String id;
  String make;
  String plateNumber;

  Car({
    required this.id,
    required this.make,
    required this.plateNumber,
  });
}

class DriverRegistrationForm extends StatefulWidget {
  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  TextEditingController frontImageController = TextEditingController();
  TextEditingController backImageController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _driver = Driver(
    name: '',
    email: '',
    phoneNumber: '',
    password: '',
    address: '',
    assignedCars: [],
    frontImageControl: '',
    backImageControl: '',
  );
  final List<Car> _availableCars = [];
  Car? _selectedCar;

  String? frontImagePath;
  String? backImagePath;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadAvailableCars();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvailableCars();
  }

  void _loadAvailableCars() async {
    try {
      setState(() {
        _availableCars.clear();
      });
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DatabaseReference carsRef = FirebaseDatabase.instance
            .ref()
            .child('car_owners')
            .child(user.uid)
            .child('cars');
        final DatabaseEvent event = await carsRef.once();
        final DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          final Map<dynamic, dynamic> carsMap =
              snapshot.value as Map<dynamic, dynamic>;
          carsMap.forEach((carId, carData) {
            setState(() {
              _availableCars.add(Car(
                id: carId,
                make: carData['make'],
                plateNumber: carData['plateNumber'],
              ));
            });
          });
        } else {
          print('No cars found for the current user in the database');
        }
      } else {
        print('No current user found');
      }
    } catch (error) {
      print('Failed to load available cars: $error');
    }
  }

  Future<void> _pickImage(
      {required bool isFront, required ImageSource source}) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          frontImagePath = pickedFile.path;
          //frontImageController.text = pickedFile.path;
        } else {
          backImagePath = pickedFile.path;
          //backImageController.text = pickedFile.path;
        }
      });
    }
  }

  Future<void> uploadImages(String userId) async {
    if (frontImagePath != null) {
      frontImagePath =
          await _uploadImage(userId, "front_image.jpg", frontImagePath!);
    }

    if (backImagePath != null) {
      backImagePath =
          await _uploadImage(userId, "back_image.jpg", backImagePath!);
    }
  }

  Future<String> _uploadImage(
      String userId, String imageName, String imagePath) async {
    try {
      File imageFile = File(imagePath);
      TaskSnapshot snapshot =
          await _storage.ref("drivers/$userId/$imageName").putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      await _registerDriver();
      setState(() {
        _isLoading = false;
      });
       // Reload available cars after registration


    }
  }


  Future<void> _registerDriver() async {
    try {

      String userId = currentfirebaseUser!.uid;

      DatabaseReference carRef =
          car_ownerRref.child(userId).child("cars").child(_selectedCar!.id);
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
      String? truckType = carData['truckType'] as String?; // Include truckType


      if (bodyType == null ||
          color == null ||
          make == null ||
          model == null ||
          plateNumber == null ||
          year == null ||
          truckType == null

      ) {
        throw Exception(
            'Car data properties are null or not in the expected format');
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _driver.email,
        password: _driver.password,
      );

      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(userCredential.user!.uid);

      String driverKey =
          FirebaseDatabase.instance.ref().child('drivers').push().key ?? '';
      await uploadImages(userId);
      driverRef.set({
        'name': _driver.name,
        'email': _driver.email,
        'phoneNumber': _driver.phoneNumber,
        'password': _driver.password,
        'address': _driver.address,
        'front_id_img': frontImagePath ?? "",
        'back_id_img': backImagePath ?? "",
        'car_details': {
          'carId': _selectedCar!.id,
          'bodyType': bodyType,
          'color': color,
          'make': make,
          'model': model,
          'plateNumber': plateNumber,
          'year': year,
          'truckType': truckType,
        },
      });

      car_ownerRref.child(userId).child("drivers").child(driverKey).set({
        'name': _driver.name,
        'email': _driver.email,
        'phoneNumber': _driver.phoneNumber,
        'password': _driver.password,
        'address': _driver.address,
        'front_id_img': frontImagePath ?? "",
        'back_id_img': backImagePath ?? "",
        'carId': _selectedCar!.id,
      });

      if (frontImagePath != null) {
        _driver.frontImageControl =
            await _uploadImage(userId, "front_image.jpg", frontImagePath!);
      }
      if (backImagePath != null) {
        _driver.backImageControl =
            await _uploadImage(userId, "back_image.jpg", backImagePath!);
      }
      //await uploadImages(userId);
      carRef.update({'driverId': userCredential.user!.uid});



      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Driver registered successfully'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to register driver: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Registration'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white10, Colors.blueGrey[100]!],
              ),
            ),
          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Driver Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _driver.address = value!;
                    },
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Login Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Assigned Car',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<Car>(
                    value: _selectedCar,
                    items: _availableCars.map((Car car) {
                      return DropdownMenuItem<Car>(
                        value: car,
                        child: Text('${car.make} - ${car.plateNumber}'),
                      );
                    }).toList(),
                    onChanged: (Car? value) {
                      setState(() {
                        _selectedCar = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Car',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a car';
                      }
                      return null;
                    },
                    dropdownColor: Colors.grey[200],
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Driver ID Images',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Front ID'),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(
                            isFront: true, source: ImageSource.camera),
                        icon: Icon(Icons.camera_alt),
                        label: Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(
                            isFront: true, source: ImageSource.gallery),
                        icon: Icon(Icons.folder),
                        label: Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Back ID'),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(
                            isFront: false, source: ImageSource.camera),
                        icon: Icon(Icons.camera_alt),
                        label: Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(
                            isFront: false, source: ImageSource.gallery),
                        icon: Icon(Icons.folder),
                        label: Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Register Driver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:io';
// import 'package:car_owner/config_maps.dart';
// import 'package:car_owner/main.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
//
// class Driver {
//   String name;
//   String email;
//   String phoneNumber;
//   String password;
//   String frontimagecontrol;
//   String backimagecontrol;
//
//   List<String> assignedCars;
//
//   Driver({
//     required this.name,
//     required this.email,
//     required this.phoneNumber,
//     required this.password,
//     required this.assignedCars,
//     required this.backimagecontrol,
//     required this.frontimagecontrol
//   });
// }
//
// class Car {
//   String id;
//   String make;
//   String plateNumber;
//
//   Car({
//     required this.id,
//     required this.make,
//     required this.plateNumber,
//   });
// }
//
// class DriverRegistrationForm extends StatefulWidget {
//   @override
//   _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
// }
//
// class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
//   TextEditingController frontImageController = TextEditingController();
//   TextEditingController backImageController = TextEditingController();
//
//   bool _showPassword = false;
//   bool _isLoading = false;
//
//   final _formKey = GlobalKey<FormState>();
//   final _driver = Driver(
//     name: '',
//     email: '',
//     phoneNumber: '',
//     password: '',
//     assignedCars: [],
//     backimagecontrol: '',
//     frontimagecontrol: '',
//   );
//   final List<Car> _availableCars = [];
//   Car? _selectedCar;
//
//   String? frontImagePath;
//   String? backImagePath;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAvailableCars();
//   }
//
//   void _loadAvailableCars() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final DatabaseReference carsRef = FirebaseDatabase.instance.reference().child('car_owners').child(user.uid).child('cars');
//         final DatabaseEvent event = await carsRef.once();
//         final DataSnapshot snapshot = event.snapshot;
//
//         if (snapshot.value != null) {
//           final Map<dynamic, dynamic> carsMap = snapshot.value as Map<dynamic, dynamic>;
//           carsMap.forEach((carId, carData) {
//             setState(() {
//               _availableCars.add(Car(
//                 id: carId,
//                 make: carData['make'],
//                 plateNumber: carData['plateNumber'],
//               ));
//             });
//           });
//         } else {
//           print('No cars found for the current user in the database');
//         }
//       } else {
//         print('No current user found');
//       }
//     } catch (error) {
//       print('Failed to load available cars: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Registration'),
//         backgroundColor: Colors.blueGrey[800],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white10, Colors.blueGrey[100]!],
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     'Driver Information',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Name',
//                       prefixIcon: Icon(Icons.person),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a name';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.name = value!;
//                     },
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Contact Information',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter an email';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.email = value!;
//                     },
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 15.0),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Phone Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a phone number';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.phoneNumber = value!;
//                     },
//                     keyboardType: TextInputType.phone,
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Login Information',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _showPassword ? Icons.visibility_off : Icons.visibility,
//                         ),
//                         onPressed: () =>
//                             setState(() => _showPassword = !_showPassword),
//                       ),
//                     ),
//                     obscureText: !_showPassword,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a password';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.password = value!;
//                     },
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Assigned Car',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   DropdownButtonFormField<Car>(
//                     value: _selectedCar,
//                     items: _availableCars.map((Car car) {
//                       return DropdownMenuItem<Car>(
//                         value: car,
//                         child: Text('${car.make} - ${car.plateNumber}'),
//                       );
//                     }).toList(),
//                     onChanged: (Car? value) {
//                       setState(() {
//                         _selectedCar = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Select Car',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null) {
//                         return 'Please select a car';
//                       }
//                       return null;
//                     },
//                     dropdownColor: Colors.grey[200],
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Driver ID Images',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Front ID'),
//                       ElevatedButton.icon(
//                         onPressed: _pickFrontImageCamera,
//                         icon: Icon(Icons.camera_alt),
//                         label: Text('Camera'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _pickFrontImageGallery,
//                         icon: Icon(Icons.folder),
//                         label: Text('Gallery'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Back ID'),
//                       ElevatedButton.icon(
//                         onPressed: _pickBackImageCamera,
//                         icon: Icon(Icons.camera_alt),
//                         label: Text('Camera'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _pickBackImageGallery,
//                         icon: Icon(Icons.folder),
//                         label: Text('Gallery'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _submitForm,
//                       child: Text('Register Driver'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueGrey[800],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> uploadImages(String userId) async {
//     if (frontImagePath != null) {
//       frontImagePath = await _uploadImage(userId, "front_image.jpg", frontImagePath!);
//     }
//
//     if (backImagePath != null) {
//       backImagePath = await _uploadImage(userId, "back_image.jpg", backImagePath!);
//     }
//   }
//
//
//   // Future<void> _uploadImage(String userId, String imageName, String imagePath) async {
//   //   try {
//   //     File imageFile = File(imagePath);
//   //     TaskSnapshot snapshot = await _storage.ref("drivers/$userId/$imageName").putFile(imageFile);
//   //     String downloadUrl = await snapshot.ref.getDownloadURL();
//   //
//   //     if (imageName == "front_image.jpg") {
//   //       frontImagePath = downloadUrl;
//   //     } else if (imageName == "back_image.jpg") {
//   //       backImagePath = downloadUrl;
//   //     }
//   //   } catch (e) {
//   //     print("Error uploading image: $e");
//   //   }
//   // }
//   Future<String> _uploadImage(String userId, String imageName, String imagePath) async {
//     try {
//       File imageFile = File(imagePath);
//       TaskSnapshot snapshot = await _storage.ref("drivers/$userId/$imageName").putFile(imageFile);
//       String downloadUrl = await snapshot.ref.getDownloadURL();  // Get download URL
//       return downloadUrl;
//     } catch (e) {
//       print("Error uploading image: $e");
//       return "";
//     }
//   }
//
//   Future<void> _pickFrontImageCamera() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         frontImagePath = pickedFile.path;
//         frontImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickBackImageCamera() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickFrontImageGallery() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         frontImagePath = pickedFile.path;
//         frontImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickBackImageGallery() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       setState(() {
//         _isLoading=true;
//       });
//       _registerDriver();
//       setState(() {
//         _isLoading=true;
//       });
//     }
//   }
//
//   void _registerDriver() async {
//     try {
//       String userId = currentfirebaseUser!.uid;
//       print(userId);
//
//       DatabaseReference carRef = car_ownerRref.child(userId).child("cars").child(_selectedCar!.id);
//       DataSnapshot carSnapshot = await carRef.get();
//
//       if (!carSnapshot.exists) {
//         throw Exception('Selected car does not exist in the database');
//       }
//
//       Map<dynamic, dynamic>? carData = carSnapshot.value as Map<dynamic, dynamic>?;
//
//       if (carData == null) {
//         throw Exception('Car data is null or not in the expected format');
//       }
//
//       String? bodyType = carData['bodyType'] as String?;
//       String? color = carData['color'] as String?;
//       String? make = carData['make'] as String?;
//       String? model = carData['model'] as String?;
//       String? plateNumber = carData['plateNumber'] as String?;
//       String? year = carData['year'] as String?;
//
//       if (bodyType == null || color == null || make == null || model == null || plateNumber == null || year == null) {
//         throw Exception('Car data properties are null or not in the expected format');
//       }
//
//       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _driver.email,
//         password: _driver.password,
//       );
//
//       DatabaseReference driverRef = FirebaseDatabase.instance
//           .ref()
//           .child('drivers')
//           .child(userCredential.user!.uid);
//
//       String driverKey = FirebaseDatabase.instance.ref().child('drivers').push().key ?? '';
//
//       driverRef.set({
//         'name': _driver.name,
//         'email': _driver.email,
//         'phoneNumber': _driver.phoneNumber,
//         'password': _driver.password,
//         'front_id_img': frontImagePath ?? "",
//         'back_id_img': backImagePath ?? "",
//         'car_details': {
//           'carId': _selectedCar!.id,
//           'bodyType': bodyType,
//           'color': color,
//           'make': make,
//           'model': model,
//           'plateNumber': plateNumber,
//           'year': year,
//         },
//       });
//
//       car_ownerRref.child(userId).child("drivers").child(driverKey).set({
//         'name': _driver.name,
//         'email': _driver.email,
//         'phoneNumber': _driver.phoneNumber,
//         'password': _driver.password,
//         'front_id_img': frontImagePath ?? "",
//         'back_id_img': backImagePath ?? "",
//         'carId': _selectedCar!.id,
//       });
//
//       await uploadImages(userId);
//
//       carRef.update({'driverId': userCredential.user!.uid});
//
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Success'),
//           content: Text('Driver registered successfully'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to register driver: $e'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
//

// import 'dart:io';
// import 'package:car_owner/config_maps.dart';
// import 'package:car_owner/main.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
//
// class Driver {
//   String name;
//   String email;
//   String phoneNumber;
//   String password;
//   String frontimagecontrol;
//   String backimagecontrol;
//
//   List<String> assignedCars;
//
//   Driver({
//     required this.name,
//     required this.email,
//     required this.phoneNumber,
//     required this.password,
//     required this.assignedCars,
//     required this.backimagecontrol,
//     required this.frontimagecontrol
//   });
// }
//
// class Car {
//   String id;
//   String make;
//   String plateNumber;
//
//   Car({
//     required this.id,
//     required this.make,
//     required this.plateNumber,
//   });
// }
//
// class DriverRegistrationForm extends StatefulWidget {
//   @override
//   _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
// }
//
// class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
//   TextEditingController frontImageController = TextEditingController();
//   TextEditingController backImageController = TextEditingController();
//
//   bool _showPassword = false;
//
//   final _formKey = GlobalKey<FormState>();
//   final _driver = Driver(
//     name: '',
//     email: '',
//     phoneNumber: '',
//     password: '',
//     assignedCars: [],
//     backimagecontrol: '',
//     frontimagecontrol: '',
//   );
//   final List<Car> _availableCars = [];
//   Car? _selectedCar;
//
//   String? frontImagePath;
//   String? backImagePath;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAvailableCars();
//   }
//
//   void _loadAvailableCars() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final DatabaseReference carsRef = FirebaseDatabase.instance.reference().child('car_owners').child(user.uid).child('cars');
//         final DatabaseEvent event = await carsRef.once();
//         final DataSnapshot snapshot = event.snapshot;
//
//         if (snapshot.value != null) {
//           final Map<dynamic, dynamic> carsMap = snapshot.value as Map<dynamic, dynamic>;
//           carsMap.forEach((carId, carData) {
//             setState(() {
//               _availableCars.add(Car(
//                 id: carId,
//                 make: carData['make'],
//                 plateNumber: carData['plateNumber'],
//               ));
//             });
//           });
//         } else {
//           print('No cars found for the current user in the database');
//         }
//       } else {
//         print('No current user found');
//       }
//     } catch (error) {
//       print('Failed to load available cars: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Registration'),
//         backgroundColor: Colors.blueGrey[800],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white10, Colors.blueGrey[100]!],
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     'Driver Information',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Name',
//                       prefixIcon: Icon(Icons.person),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a name';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.name = value!;
//                     },
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Contact Information',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter an email';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.email = value!;
//                     },
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 15.0),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Phone Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a phone number';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.phoneNumber = value!;
//                     },
//                     keyboardType: TextInputType.phone,
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Login Information',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _showPassword ? Icons.visibility_off : Icons.visibility,
//                         ),
//                         onPressed: () =>
//                             setState(() => _showPassword = !_showPassword),
//                       ),
//                     ),
//                     obscureText: !_showPassword,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a password';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _driver.password = value!;
//                     },
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Assigned Car',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   DropdownButtonFormField<Car>(
//                     value: _selectedCar,
//                     items: _availableCars.map((Car car) {
//                       return DropdownMenuItem<Car>(
//                         value: car,
//                         child: Text('${car.make} - ${car.plateNumber}'),
//                       );
//                     }).toList(),
//                     onChanged: (Car? value) {
//                       setState(() {
//                         _selectedCar = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Select Car',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null) {
//                         return 'Please select a car';
//                       }
//                       return null;
//                     },
//                     dropdownColor: Colors.grey[200],
//                   ),
//                   SizedBox(height: 15.0),
//                   Text(
//                     'Driver ID Images',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Front ID'),
//                       ElevatedButton.icon(
//                         onPressed: _pickFrontImageCamera,
//                         icon: Icon(Icons.camera_alt),
//                         label: Text('Camera'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _pickFrontImageGallery,
//                         icon: Icon(Icons.folder),
//                         label: Text('Gallery'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Back ID'),
//                       ElevatedButton.icon(
//                         onPressed: _pickBackImageCamera,
//                         icon: Icon(Icons.camera_alt),
//                         label: Text('Camera'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _pickBackImageGallery,
//                         icon: Icon(Icons.folder),
//                         label: Text('Gallery'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[400],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _submitForm,
//                       child: Text('Register Driver'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueGrey[800],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> uploadImages(String userId) async {
//     if (frontImagePath != null) {
//       await _uploadImage(userId, "front_image.jpg", frontImagePath!);
//     }
//
//     if (backImagePath != null) {
//       await _uploadImage(userId, "back_image.jpg", backImagePath!);
//     }
//   }
//
//   // Future<void> _uploadImage(String userId, String imageName, String imagePath) async {
//   //   try {
//   //     File imageFile = File(imagePath);
//   //     TaskSnapshot snapshot = await _storage.ref("drivers/$userId/$imageName").putFile(imageFile);
//   //     String downloadUrl = await snapshot.ref.getDownloadURL();
//   //
//   //     if (imageName == "front_image.jpg") {
//   //       frontImagePath = downloadUrl;
//   //     } else if (imageName == "back_image.jpg") {
//   //       backImagePath = downloadUrl;
//   //     }
//   //   } catch (e) {
//   //     print("Error uploading image: $e");
//   //   }
//   // }
//   Future<String> _uploadImage(String userId, String imageName, String imagePath) async {
//     try {
//       File imageFile = File(imagePath);
//       TaskSnapshot snapshot = await _storage.ref("drivers/$userId/$imageName").putFile(imageFile);
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print("Error uploading image: $e");
//       return "";
//     }
//   }
//
//   Future<void> _pickFrontImageCamera() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         frontImagePath = pickedFile.path;
//         frontImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickBackImageCamera() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickFrontImageGallery() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         frontImagePath = pickedFile.path;
//         frontImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   Future<void> _pickBackImageGallery() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path;
//       });
//     }
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       _registerDriver();
//     }
//   }
//
//   void _registerDriver() async {
//     try {
//       String userId = currentfirebaseUser!.uid;
//       print(userId);
//
//       DatabaseReference carRef = car_ownerRref.child(userId).child("cars").child(_selectedCar!.id);
//       DataSnapshot carSnapshot = await carRef.get();
//
//       if (!carSnapshot.exists) {
//         throw Exception('Selected car does not exist in the database');
//       }
//
//       Map<dynamic, dynamic>? carData = carSnapshot.value as Map<dynamic, dynamic>?;
//
//       if (carData == null) {
//         throw Exception('Car data is null or not in the expected format');
//       }
//
//       String? bodyType = carData['bodyType'] as String?;
//       String? color = carData['color'] as String?;
//       String? make = carData['make'] as String?;
//       String? model = carData['model'] as String?;
//       String? plateNumber = carData['plateNumber'] as String?;
//       String? year = carData['year'] as String?;
//
//       if (bodyType == null || color == null || make == null || model == null || plateNumber == null || year == null) {
//         throw Exception('Car data properties are null or not in the expected format');
//       }
//
//       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _driver.email,
//         password: _driver.password,
//       );
//
//       DatabaseReference driverRef = FirebaseDatabase.instance
//           .ref()
//           .child('drivers')
//           .child(userCredential.user!.uid);
//
//       String driverKey = FirebaseDatabase.instance.ref().child('drivers').push().key ?? '';
//
//       driverRef.set({
//         'name': _driver.name,
//         'email': _driver.email,
//         'phoneNumber': _driver.phoneNumber,
//         'password': _driver.password,
//         'front_id_img': frontImagePath ?? "",
//         'back_id_img': backImagePath ?? "",
//         'car_details': {
//           'carId': _selectedCar!.id,
//           'bodyType': bodyType,
//           'color': color,
//           'make': make,
//           'model': model,
//           'plateNumber': plateNumber,
//           'year': year,
//         },
//       });
//
//       car_ownerRref.child(userId).child("drivers").child(driverKey).set({
//         'name': _driver.name,
//         'email': _driver.email,
//         'phoneNumber': _driver.phoneNumber,
//         'password': _driver.password,
//         'front_id_img': frontImagePath ?? "",
//         'back_id_img': backImagePath ?? "",
//         'carId': _selectedCar!.id,
//       });
//
//       await uploadImages(userId);
//
//       carRef.update({'driverId': userCredential.user!.uid});
//
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Success'),
//           content: Text('Driver registered successfully'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to register driver: $e'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
//

// Future<void> _submitForm() async {
//   if (_formKey.currentState!.validate()) {
//     _formKey.currentState!.save();
//
//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: _driver.email,
//         password: _driver.password,
//       );
//       final User? user = userCredential.user;
//
//
//       if (user != null) {
//         await FirebaseDatabase.instance
//             .ref()
//             .child('drivers')
//             .child(user.uid)
//             .set({
//           'name': _driver.name,
//           'email': _driver.email,
//           'phoneNumber': _driver.phoneNumber,
//           'assignedCars': _selectedCar != null ? [_selectedCar!.id] : [],
//           'frontimagecontrol': frontImageController.text,
//           'backimagecontrol': backImageController.text,
//         });
//
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Success'),
//             content: Text('Driver registered successfully'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     } catch (error) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to register driver: $error'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }

// import 'dart:io';
// import 'package:car_owner/config_maps.dart';
// import 'package:car_owner/main.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
//
// class Driver {
//   String name;
//   String email;
//   String phoneNumber;
//   String password;
//   String frontimagecontrol;
//   String backimagecontrol;
//
//   List<String> assignedCars;
//
//   Driver(
//       {required this.name,
//       required this.email,
//       required this.phoneNumber,
//       required this.password,
//       required this.assignedCars,
//       required this.backimagecontrol,
//       required this.frontimagecontrol});
// }
//
// class DriverRegistrationForm extends StatefulWidget {
//   @override
//   _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
// }
//
// class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
//   TextEditingController frontImageController = TextEditingController();
//   TextEditingController backImageController = TextEditingController();
//
//   bool _showPassword =
//       false; // Declare a boolean variable to track password visibility
//
//   final _formKey = GlobalKey<FormState>();
//   final _driver = Driver(
//     name: '',
//     email: '',
//     phoneNumber: '',
//     password: '',
//     assignedCars: [],
//     backimagecontrol: '',
//     frontimagecontrol: '',
//   );
//   final List<String> _availableCars = [];
//   String? _selectedCar;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAvailableCars();
//   }
//
//   void _loadAvailableCars() async {
//     try {
//       final DatabaseReference carsRef =
//           FirebaseDatabase.instance.reference().child('car_owners');
//       final DatabaseEvent event = await carsRef.once();
//       final DataSnapshot snapshot = event.snapshot;
//
//       if (snapshot.value != null) {
//         final Map<dynamic, dynamic> carOwnersMap =
//             snapshot.value as Map<dynamic, dynamic>;
//         carOwnersMap.forEach((carOwnerId, carOwnerData) {
//           if (carOwnerData['cars'] != null) {
//             final Map<dynamic, dynamic> carsMap =
//                 carOwnerData['cars'] as Map<dynamic, dynamic>;
//             carsMap.forEach((carId, carData) {
//               setState(() {
//                 _availableCars.add(carId);
//               });
//             });
//           }
//         });
//       } else {
//         print('No car owner data found in the database');
//       }
//     } catch (error) {
//       print('Failed to load available cars: $error');
//     }
//   }
//
//   String? frontImagePath;
//
//   String? backImagePath;
//
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Registration'), // Add an app bar with title
//         backgroundColor: Colors.blueGrey[800], // Set app bar color
//       ),
//       body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white10, Colors.blueGrey[100]!],
//             ),
//           ),
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start, // Align elements left
//               children: <Widget>[
//                 // Name field with icon
//                 Text(
//                   'Driver Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ), // Add heading
//                 SizedBox(height: 10),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     prefixIcon: Icon(Icons.person),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a name';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     _driver.name = value!;
//                   },
//                   style: TextStyle(fontSize:14), // Reduce text field size
//                 ),
//                 // Email field with validation message style
//                 SizedBox(height: 15.0), // Adjust spacing
//                 Text(
//                   'Contact Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ), // Add heading
//                 SizedBox(height: 10),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an email';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     _driver.email = value!;
//                   },
//                   style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14), // Reduce text field size
//                 ),
//                 SizedBox(height: 15.0), // Adjust spacing
//                 TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Phone Number',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a phone number';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     _driver.phoneNumber = value!;
//                   },
//                   keyboardType: TextInputType.phone, // Set keyboard type
//                   style: TextStyle(fontSize: 14), // Reduce text field size
//                 ),
//                 // Password field with toggle visibility
//                 SizedBox(height: 15.0), // Adjust spacing
//                 Text(
//                   'Login Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ), // Add heading
//                 SizedBox(height: 10),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _showPassword ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () =>
//                           setState(() => _showPassword = !_showPassword),
//                     ),
//                   ),
//                   obscureText: !_showPassword,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a password';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     _driver.password = value!;
//                   },
//                   style: TextStyle(fontSize: 14), // Reduce text field size
//                 ),
//
//                 // Car dropdown with custom styling
//                 SizedBox(height: 15.0), // Adjust spacing
//                 Text(
//                   'Assigned Car',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ), // Add heading
//                 SizedBox(height: 10),
//
//                 DropdownButtonFormField<String>(
//                   value: _selectedCar,
//                   items: _availableCars.map((String carId) {
//                     return DropdownMenuItem<String>(
//                       value: carId,
//                       child: Text(carId),
//                     );
//                   }).toList(),
//                   onChanged: (String? value) {
//                     setState(() {
//                       _selectedCar = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select Car',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a car';
//                     }
//                     return null;
//                   },
//                   dropdownColor:
//                       Colors.grey[200], // Set dropdown background color
//                 ),
//
//                 // ID Image Upload Section
//                 SizedBox(height: 15.0), // Adjust spacing
//                 Text(
//                   'Driver ID Images',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ), // Add heading
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Front ID'),
//                     ElevatedButton.icon(
//                       onPressed: _pickFrontImageCamera,
//                       icon: Icon(Icons.camera_alt),
//                       label: Text('Camera'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.blueGrey[400], // Subtle background color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _pickFrontImageGallery,
//                       icon: Icon(Icons.folder),
//                       label: Text('Gallery'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.blueGrey[400], // Subtle background color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Back ID'),
//                     ElevatedButton.icon(
//                       onPressed: _pickBackImageCamera,
//                       icon: Icon(Icons.camera_alt),
//                       label: Text('Camera'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.blueGrey[400], // Subtle background color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _pickBackImageGallery,
//                       icon: Icon(Icons.folder),
//                       label: Text('Gallery'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.blueGrey[400], // Subtle background color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Register button with accent color
//                 SizedBox(height: 20.0), // Add spacing
//                 ElevatedButton(
//                   onPressed: _submitForm,
//                   child: Text('Register Driver'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal[700], // Set button color
//                     foregroundColor: Colors.white, // Set button text color
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     minimumSize: Size(double.infinity, 50), // Set button width
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> uploadImages(String userId) async {
//     if (frontImagePath != null) {
//       await _uploadImage(userId, "front_image.jpg", frontImagePath!);
//     }
//
//     if (backImagePath != null) {
//       await _uploadImage(userId, "back_image.jpg", backImagePath!);
//     }
//   }
//
//   Future<void> _uploadImage(
//       String userId, String imageName, String imagePath) async {
//     try {
//       File imageFile = File(imagePath);
//       TaskSnapshot snapshot =
//           await _storage.ref("drivers/$userId/$imageName").putFile(imageFile);
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       if (imageName == "front_image.jpg") {
//         frontImagePath = downloadUrl;
//       } else if (imageName == "back_image.jpg") {
//         backImagePath = downloadUrl;
//       }
//     } catch (e) {
//       print("Error uploading image: $e");
//     }
//   }
//
//   Future<void> _pickFrontImageCamera() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         frontImagePath = pickedFile.path;
//         frontImageController.text = pickedFile.path ?? '';
//       });
//     }
//   }
//
//   Future<void> _pickBackImageCamera() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path ?? '';
//       });
//     }
//   }
//
//   Future<void> _pickFrontImageGallery() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         frontImagePath = pickedFile.path;
//         frontImageController.text = pickedFile.path ?? '';
//       });
//     }
//   }
//
//   Future<void> _pickBackImageGallery() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path ?? '';
//       });
//     }
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       _registerDriver();
//     }
//   }
//
//   void _registerDriver() async {
//     try {
//       String userId = currentfirebaseUser!.uid;
//       print(userId);
//
//       DatabaseReference carRef =
//           car_ownerRref.child(userId).child("cars").child(_selectedCar!);
//       DataSnapshot carSnapshot = await carRef.get();
//
//       if (!carSnapshot.exists) {
//         throw Exception('Selected car does not exist in the database');
//       }
//
//       Map<dynamic, dynamic>? carData =
//           carSnapshot.value as Map<dynamic, dynamic>?;
//
//       if (carData == null) {
//         throw Exception('Car data is null or not in the expected format');
//       }
//
//       String? bodyType = carData['bodyType'] as String?;
//       String? color = carData['color'] as String?;
//       String? make = carData['make'] as String?;
//       String? model = carData['model'] as String?;
//       String? plateNumber = carData['plateNumber'] as String?;
//       String? year = carData['year'] as String?;
//
//       if (bodyType == null ||
//           color == null ||
//           make == null ||
//           model == null ||
//           plateNumber == null ||
//           year == null) {
//         throw Exception(
//             'Car data properties are null or not in the expected format');
//       }
//
//       // Register driver with retrieved car information
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _driver.email,
//         password: _driver.password,
//       );
//
//       DatabaseReference driverRef = FirebaseDatabase.instance
//           .ref()
//           .child('drivers')
//           .child(userCredential.user!.uid);
//
//       // Generate a unique key for the driver
//       String driverKey =
//           FirebaseDatabase.instance.ref().child('drivers').push().key ?? '';
//
//       // Set the driver's data using the unique key
//       driverRef.set({
//         'name': _driver.name,
//         'email': _driver.email,
//         'phoneNumber': _driver.phoneNumber,
//         'password': _driver.password,
//         'front_id_img': frontImagePath ?? "",
//         'back_id_img': backImagePath ?? "",
//         'car_details': {
//           'carId': _selectedCar,
//           'bodyType': bodyType,
//           'color': color,
//           'make': make,
//           'model': model,
//           'plateNumber': plateNumber,
//           'year': year,
//         },
//       });
//
//       // Add a reference to the driver under the car owner's node using the unique key
//       car_ownerRref.child(userId).child("drivers").child(driverKey).set({
//         'name': _driver.name,
//         'email': _driver.email,
//         'phoneNumber': _driver.phoneNumber,
//         'password': _driver.password,
//         'front_id_img': frontImagePath ?? "",
//         'back_id_img': backImagePath ?? "",
//         'carId': _selectedCar,
//       });
//       await uploadImages(userId);
//
//       // Update car with driver ID (Optional)
//       carRef.update({'driverId': userCredential.user!.uid});
//
//       Navigator.pop(context);
//
//       // Show success message or navigate to the next screen
//     } catch (e) {
//       print('Failed to register driver: $e');
//       // Handle registration failure
//     }
//   }
// }
//
// // void _registerDriver() async {
// //   try {
// //     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
// //       email: _driver.email,
// //       password: _driver.password,
// //     );
// //
// //     // Fetch details of the assigned car
// //     DatabaseReference carRef = FirebaseDatabase.instance.reference().child('car_owners').child(_selectedCar!);
// //     DataSnapshot carSnapshot = await carRef.once().then((event) => event.snapshot);
// //
// //     if (carSnapshot.value != null) {
// //       Map<String, dynamic>? assignedCarData = carSnapshot.value as Map<String, dynamic>?;
// //
// //       if (assignedCarData != null) {
// //         // Create driver information
// //         Map<String, dynamic> driverData = {
// //           'name': _driver.name,
// //           'email': _driver.email,
// //           'phoneNumber': _driver.phoneNumber,
// //           'assignedCar': assignedCarData,
// //         };
// //
// //         // Save driver information to the database
// //         DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers').child(userCredential.user!.uid);
// //         driverRef.set(driverData);
// //
// //         // Update the assigned car with the driver's ID
// //         carRef.update({'driverId': userCredential.user!.uid});
// //
// //         // Show success message or navigate to next screen
// //       } else {
// //         print('Error: Car details not found in the database');
// //       }
// //     }
// //   } catch (e) {
// //     print('Failed to register driver: $e');
// //     // Handle registration failure
// //   }
// // }
//
// // void _registerDriver() async {
// //   try {
// //     // 1. Check car data structure
// //     DataSnapshot carSnapshot = await car_ownerRref.child(currentfirebaseUser!.uid).child(_selectedCar!).get();
// //     // if (!(carSnapshot.value is Map<String, dynamic>)) {
// //     //   throw Exception('Car data is not in the expected format');
// //     // }
// //
// //     // 2. Extract car information from snapshot
// //     //Map<String, dynamic> carData = carSnapshot.value as Map<String, dynamic>;
// //     final carData = carSnapshot.value as Map<String, dynamic>?;
// //
// //     // 3. Check if car exists and handle errors
// //     if (!carSnapshot.exists) {
// //       throw Exception('Selected car does not exist in database');
// //     }
// //
// //     // Extract car information directly from the car data map
// //     String bodyType = carData?['bodyType']?? "";
// //     String color = carData?['color']?? "";
// //     String make = carData?['make']?? "";
// //     String model = carData?['model'] ?? "";
// //     String plateNumber = carData?['plateNumber']?? "";
// //     String year = carData?['year']?? "";
// //
// //     // Register driver with retrieved car information
// //     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
// //       email: _driver.email,
// //       password: _driver.password,
// //     );
// //     DatabaseReference driverRef = FirebaseDatabase.instance
// //         .reference()
// //         .child('drivers')
// //         .child(userCredential.user!.uid);
// //     driverRef.set({
// //       'name': _driver.name,
// //       'email': _driver.email,
// //       'phoneNumber': _driver.phoneNumber,
// //       'assignedCars': [carData], // Use the entire car data map
// //     });
// //
// //     // Update car with driver ID (Optional)
// //     // ... (same logic as before)
// //
// //     // Show success message or navigate to next screen
// //   } catch (e) {
// //     print('Failed to register driver: $e'); // Handle registration failure
// //   }
// // }
//
// //
// //

import 'dart:io';
import 'package:car_owner/config_maps.dart';
import 'package:car_owner/screens/car_info_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_owner/main.dart';
import 'package:car_owner/screens/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:car_owner/screens/main_screen.dart';
import '../widgets/progess_dialog.dart';
import 'forgot_password.dart';

class SignupScreen extends StatefulWidget {
  static const String idScreen = "register";

  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController addressTextEditingController = TextEditingController();
  bool _showPassword = false;
  TextEditingController frontImageController = TextEditingController();
  TextEditingController backImageController = TextEditingController();

  String? frontImagePath;
  File? _frontimagenew;
  String? backImagePath;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.only(bottom: 50, top: 60),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.lightBlueAccent.shade100],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image(
                  image: AssetImage("images/home.png"),
                  width: 300,
                  height: 330,
                  alignment: Alignment.center,
                  color: Colors.teal,
                ),
                SizedBox(height: 15),
                Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Brand Bold",
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 1),
                      TextField(
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.blue.shade200, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.blue.shade200, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10.0),
                      IntlPhoneField(
                        initialCountryCode: "ET",
                        showCountryFlag: true,
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down_circle_rounded,
                          color: Colors.black,
                        ),
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.blue.shade200, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.blue.shade200, width: 1.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: addressTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Address",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.blue.shade200, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      TextField(
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
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        controller: backImageController,
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
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.lightBlueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          if (nameTextEditingController.text.length < 4) {
                            displayToastMessage(
                                "Name should be at least 4 characters", context);
                          } else if (!emailTextEditingController.text
                              .contains("@")) {
                            displayToastMessage(
                                "Email address is not valid", context);
                          } else if (phoneTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Phone number is mandatory", context);
                          }
                          else if (addressTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Address is mandatory", context);
                          }
                          else if (passwordTextEditingController.text.length <
                              7) {
                            displayToastMessage(
                                "Password must be at least 6 characters.",
                                context);
                          } else if (backImageController.text.isEmpty) {
                            displayToastMessage("Please enter ID", context);
                          } else if (frontImageController.text.isEmpty) {
                            displayToastMessage("Please enter ID.", context);
                          } else {
                            registerNewUser(context);
                          }
                        },
                        child: Text(
                          "Signup",
                          style: TextStyle(fontSize: 18, fontFamily: "Brand-Bold"),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder:(contex) =>  ForgotPasswordScreen()));

                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      " Have an Account?",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginScreen.idScreen, (route) => false);
                        // Navigator.push(context, MaterialPageRoute(builder:(contex) => const SignupScreen()));
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Registering, please wait",);
      },
    );

    final User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text).catchError((errmsg) {
      Navigator.pop(context);
      displayToastMessage("Error" + errmsg.toString(), context);
    })).user;

    if (user != null) {
      // Send email verification
      await user.sendEmailVerification();

      await uploadImages(user.uid);

      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
        "password": passwordTextEditingController.text.trim(),
        "address": addressTextEditingController.text.trim(),
        "frontImage": frontImagePath ?? "",
        "backImage": backImagePath ?? "",
      };

      await car_ownerRref.child(user.uid).set(userDataMap);
      currentfirebaseUser = user;

      Navigator.pop(context);
      displayToastMessage("A verification email has been sent. Please verify your email.", context);

      // Navigate to login screen after registration
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMessage("Account has not been created", context);
    }
  }

  Future<void> uploadImages(String userId) async {
    if (frontImagePath != null) {
      frontImagePath = await _uploadImage(userId, "front_image.jpg", frontImagePath!);
    }

    if (backImagePath != null) {
      backImagePath = await _uploadImage(userId, "back_image.jpg", backImagePath!);
    }
  }

  Future<void> _pickFrontImageCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        frontImagePath = pickedFile.path;
        frontImageController.text = pickedFile.path;
      });
    }
  }

  Future<void> _pickBackImageCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        backImagePath = pickedFile.path;
        backImageController.text = pickedFile.path;
      });
    }
  }

  Future<void> _pickFrontImageGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        frontImagePath = pickedFile.path;
        frontImageController.text = pickedFile.path;
      });
    }
  }

  Future<void> _pickBackImageGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        backImagePath = pickedFile.path;
        backImageController.text = pickedFile.path;
      });
    }
  }

  Future<String> _uploadImage(String userId, String imageName, String imagePath) async {
    try {
      File imageFile = File(imagePath);
      TaskSnapshot snapshot = await _storage.ref("car_owners/$userId/$imageName").putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }
}

void displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}




// import 'dart:io';
// import 'package:car_owner/config_maps.dart';
// import 'package:car_owner/screens/car_info_screen.dart';
// import 'package:car_owner/screens/main_screen.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:car_owner/main.dart';
// import 'package:car_owner/screens/login_screen.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../widgets/progess_dialog.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// // Secure storage instance
// final _secureStorage = FlutterSecureStorage();
// final FirebaseAuth fAuth = FirebaseAuth.instance; // Initialize FirebaseAuth instance
// //final DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users"); // Initialize DatabaseReference
//
// class SignupScreen extends StatefulWidget {
//   static const String idScreen = "register";
//
//   SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   TextEditingController nameTextEditingController = TextEditingController();
//   TextEditingController emailTextEditingController = TextEditingController();
//   TextEditingController phoneTextEditingController = TextEditingController();
//   TextEditingController passwordTextEditingController = TextEditingController();
//   TextEditingController frontImageController = TextEditingController();
//   TextEditingController backImageController = TextEditingController();
//
//   String? frontImagePath;
//   File? _frontimagenew;
//   String? backImagePath;
//
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Container(
//           padding: EdgeInsets.only(bottom: 50, top: 60),
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white, Colors.lightBlueAccent.shade100],
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Image(
//                   image: AssetImage("images/home.png"),
//                   width: 300,
//                   height: 330,
//                   alignment: Alignment.center,
//                   color: Colors.teal,
//                 ),
//                 SizedBox(height: 15),
//                 Text(
//                   "Register",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontFamily: "Brand Bold",
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 1),
//                       TextField(
//                         controller: nameTextEditingController,
//                         keyboardType: TextInputType.text,
//                         decoration: InputDecoration(
//                           labelText: "Name",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: Colors.grey.shade200, width: 1.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         controller: emailTextEditingController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: "Email",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: Colors.grey.shade200, width: 1.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10.0),
//                       IntlPhoneField(
//                         initialCountryCode: "ET",
//                         showCountryFlag: true,
//                         dropdownIcon: Icon(
//                           Icons.arrow_drop_down_circle_rounded,
//                           color: Colors.black,
//                         ),
//                         controller: phoneTextEditingController,
//                         keyboardType: TextInputType.phone,
//                         decoration: InputDecoration(
//                           labelText: "Phone Number",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: Colors.grey.shade200, width: 1.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         controller: passwordTextEditingController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           labelText: "Password",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: Colors.grey.shade200, width: 1.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         readOnly: true,
//                         controller: frontImageController,
//                         decoration: InputDecoration(
//                           labelText: "Front ID Image",
//                           labelStyle: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.camera_alt),
//                                 onPressed: _pickFrontImageCamera,
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.folder),
//                                 onPressed: _pickFrontImageGallery,
//                               ),
//                             ],
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         readOnly: true,
//                         controller: backImageController,
//                         decoration: InputDecoration(
//                           labelText: "Back ID Image",
//                           labelStyle: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.camera_alt),
//                                 onPressed: _pickBackImageCamera,
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.folder),
//                                 onPressed: _pickBackImageGallery,
//                               ),
//                             ],
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () {
//                           if (nameTextEditingController.text.length < 4) {
//                             displayToastMessage(
//                                 "Name must be atleast 4 Characters", context);
//                           } else if (!emailTextEditingController.text
//                               .contains("@")) {
//                             displayToastMessage(
//                                 "Email address is not Valid", context);
//                           } else if (phoneTextEditingController.text.isEmpty) {
//                             displayToastMessage("Phone Number is mandatory", context);
//                           } else if (passwordTextEditingController.text.length < 6) {
//                             displayToastMessage(
//                                 "Password must be atleast 6 Characters", context);
//                           } else if (frontImageController.text.isEmpty ||
//                               backImageController.text.isEmpty) {
//                             displayToastMessage(
//                                 "Please upload both front and back ID images", context);
//                           } else {
//                             registerNewUser(context);
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue.shade300,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(24.0),
//                           ),
//                         ),
//                         child: Container(
//                           height: 50.0,
//                           child: Center(
//                             child: Text(
//                               "Create Account",
//                               style: TextStyle(
//                                 fontSize: 18.0,
//                                 fontFamily: "Brand Bold",
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamedAndRemoveUntil(
//                         context, LoginScreen.idScreen, (route) => false);
//                   },
//                   child: Text(
//                     "Already have an account? Login Here",
//                     style: TextStyle(color: Colors.blueAccent),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickFrontImageCamera() async {
//     final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedImage != null) {
//       setState(() {
//         frontImagePath = pickedImage.path;
//         _frontimagenew = File(pickedImage.path);
//         frontImageController.text = pickedImage.name;
//       });
//     }
//   }
//
//   Future<void> _pickFrontImageGallery() async {
//     final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       setState(() {
//         frontImagePath = pickedImage.path;
//         _frontimagenew = File(pickedImage.path);
//         frontImageController.text = pickedImage.name;
//       });
//     }
//   }
//
//   Future<void> _pickBackImageCamera() async {
//     final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedImage != null) {
//       setState(() {
//         backImagePath = pickedImage.path;
//         backImageController.text = pickedImage.name;
//       });
//     }
//   }
//
//   Future<void> _pickBackImageGallery() async {
//     final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       setState(() {
//         backImagePath = pickedImage.path;
//         backImageController.text = pickedImage.name;
//       });
//     }
//   }
//
//   Future<String> uploadFile(File file,String userId) async {
//     String fileName = file.path.split('/').last;
//     Reference storageReference =
//     FirebaseStorage.instance.ref("car_owners/${userId}/$fileName");
//     UploadTask uploadTask = storageReference.putFile(file);
//     await uploadTask.whenComplete(() => null);
//     return await storageReference.getDownloadURL();
//   }
//
//   Future<void> registerNewUser(BuildContext context) async {
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return ProgressDialog(message: "Registering, Please wait...");
//         });
//
//     try {
//       final UserCredential userCredential = await fAuth
//           .createUserWithEmailAndPassword(
//           email: emailTextEditingController.text,
//           password: passwordTextEditingController.text);
//
//       final User? user = userCredential.user;
//
//       if (user != null) {
//         String? token = await user.getIdToken();
//         if (token != null) {
//           await _saveEncryptedData('auth_token', token); // Save the encrypted token
//         }
//
//         // Upload front and back images
//         String frontImageUrl = await uploadFile(_frontimagenew!,user.uid);
//         String backImageUrl = await uploadFile(File(backImagePath!),user.uid);
//
//         Map<String, String> userDataMap = {
//           "name": nameTextEditingController.text.trim(),
//           "email": emailTextEditingController.text.trim(),
//           "phone": phoneTextEditingController.text.trim(),
//           "frontImage": frontImageUrl,
//           "backImage": backImageUrl,
//         };
//
//         car_ownerRref.child(user.uid).set(userDataMap);
//         currentfirebaseUser = user;
//         displayToastMessage(
//             "Congratulations, your account has been created.", context);
//
//         Navigator.pushNamedAndRemoveUntil(
//             context, MainScreen.idScreen, (route) => false);
//       } else {
//         Navigator.pop(context);
//         displayToastMessage("New user account has not been Created.", context);
//       }
//     } on FirebaseAuthException catch (e) {
//       Navigator.pop(context);
//       displayToastMessage("Error: ${e.message}", context);
//     }
//   }
//
//   Future<String> _encryptData(String data) async {
//     final key = encrypt.Key.fromUtf8('my 32 length key................'); // 32 chars
//     final iv = encrypt.IV.fromLength(16);
//     final encrypter = encrypt.Encrypter(encrypt.AES(key));
//
//     final encrypted = encrypter.encrypt(data, iv: iv);
//     return encrypted.base64;
//   }
//
//   Future<String> _decryptData(String encryptedData) async {
//     final key = encrypt.Key.fromUtf8('my 32 length key................'); // 32 chars
//     final iv = encrypt.IV.fromLength(16);
//     final encrypter = encrypt.Encrypter(encrypt.AES(key));
//
//     final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
//     return decrypted;
//   }
//
//   Future<void> _saveEncryptedData(String key, String data) async {
//     String encryptedData = await _encryptData(data);
//     await _secureStorage.write(key: key, value: encryptedData);
//   }
//
//   Future<String?> _getEncryptedData(String key) async {
//     String? encryptedData = await _secureStorage.read(key: key);
//     if (encryptedData != null) {
//       return await _decryptData(encryptedData);
//     }
//     return null;
//   }
// }
//
// void displayToastMessage(String message, BuildContext context) {
//   Fluttertoast.showToast(msg: message);
// }
//









//
// import 'dart:io';
//
//
// import 'package:car_owner/config_maps.dart';
// import 'package:car_owner/screens/car_info_screen.dart';
// import 'package:car_owner/screens/car_info_screen.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:car_owner/main.dart';
// import 'package:car_owner/screens/login_screen.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// import 'package:car_owner/screens/main_screen.dart';
//
//
// import '../widgets/progess_dialog.dart';
//
// class SignupScreen extends StatefulWidget {
//   static const String idScreen="register";
//
//
//   SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   TextEditingController nameTextEditingController=TextEditingController();
//
//   TextEditingController emailTextEditingController=TextEditingController();
//
//   TextEditingController phoneTextEditingController=TextEditingController();
//
//   TextEditingController passwordTextEditingController=TextEditingController();
//
//   TextEditingController frontImageController = TextEditingController();
//
//   TextEditingController backImageController = TextEditingController();
//
//   String? frontImagePath;
//   File? _frontimagenew;
//
//   String? backImagePath;
//
//
//
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child:
//       Scaffold(
//         backgroundColor: Colors.transparent,
//
//         body: Container(
//           padding: EdgeInsets.only(bottom: 50,top: 60),
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white, Colors.lightBlueAccent.shade100],
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//
//               children: [
//                 Image(
//                   image: AssetImage("images/home.png"),
//                   width: 300,
//                   height: 330,
//                   alignment: Alignment.center,
//                   color: Colors.teal,
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Text(
//                   "Register",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontFamily: "Brand Bold",
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 1,
//                       ),
//                       TextField(
//                         controller: nameTextEditingController,
//                         keyboardType: TextInputType.text,
//                         decoration: InputDecoration(
//
//                           labelText: "Name",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400, // Lighter grey for better contrast
//                             fontSize: 14, // Increase label size for readability
//                           ),
//                           enabledBorder: OutlineInputBorder( // Style the border
//                             borderRadius: BorderRadius.circular(10.0), // Rounded corners
//                             borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0), // Light border
//                           ),
//                           focusedBorder: OutlineInputBorder( // Style the border when focused
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16), // Increase text size for better readability
//                       ),
//                       SizedBox(height: 10,),
//                       TextField(
//                         controller: emailTextEditingController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: "Email",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400, // Lighter grey for better contrast
//                             fontSize: 14, // Increase label size for readability
//                           ),
//                           enabledBorder: OutlineInputBorder( // Style the border
//                             borderRadius: BorderRadius.circular(10.0), // Rounded corners
//                             borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0), // Light border
//                           ),
//                           focusedBorder: OutlineInputBorder( // Style the border when focused
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16), // Increase text size for better readability
//                       ),
//
//                       SizedBox(
//                         height: 10.0, // Add some space between TextFields
//                       ),
//
//                       IntlPhoneField(
//                         initialCountryCode: "ET",
//                         showCountryFlag: true,
//                         dropdownIcon: Icon(
//                           Icons.arrow_drop_down_circle_rounded,
//                           color: Colors.black,
//                         ),
//
//
//                         controller: phoneTextEditingController,
//                         keyboardType: TextInputType.phone,
//
//                         decoration: InputDecoration(
//                           labelText: "Phone Number",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400, // Lighter grey for better contrast
//                             fontSize: 14, // Increase label size for readability
//                           ),
//                           enabledBorder: OutlineInputBorder( // Style the border
//                             borderRadius: BorderRadius.circular(10.0), // Rounded corners
//                             borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0), // Light border
//                           ),
//                           focusedBorder: OutlineInputBorder( // Style the border when focused
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16), // Increase text size for better readability
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: passwordTextEditingController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           labelText: "Password",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400, // Lighter grey for better contrast
//                             fontSize: 14, // Increase label size for readability
//                           ),
//                           enabledBorder: OutlineInputBorder( // Style the border
//                             borderRadius: BorderRadius.circular(10.0), // Rounded corners
//                             borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0), // Light border
//                           ),
//                           focusedBorder: OutlineInputBorder( // Style the border when focused
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16), // Increase text size for better readability
//                       ),
//                       SizedBox(height: 10,),
//                       TextField(
//                         readOnly: true,
//                         controller: frontImageController,
//                         decoration: InputDecoration(
//                           labelText: "Front ID Image",
//                           labelStyle: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.camera_alt),
//                                 onPressed: _pickFrontImageCamera,
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.folder),
//                                 onPressed: _pickFrontImageGallery,
//                               ),
//                             ],
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         readOnly: true,
//                         controller: backImageController,
//                         decoration: InputDecoration(
//                           labelText: "Back ID Image",
//                           labelStyle: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.camera_alt),
//                                 onPressed: _pickBackImageCamera,
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.folder),
//                                 onPressed: _pickBackImageGallery,
//                               ),
//                             ],
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               foregroundColor:  Colors.black87 , backgroundColor:
//                           Colors.lightBlueAccent,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                               minimumSize: const Size(double.infinity, 50)),
//
//                           onPressed: () {
//                             if(nameTextEditingController.text.length < 4) {
//                               displayToastMessage("Name should be at least 4 character", context);
//                             }
//                             else if(!emailTextEditingController.text.contains("@")) {
//                               displayToastMessage("email address is not valid", context);
//
//
//                             }
//                             else if(phoneTextEditingController.text.isEmpty)
//                             {
//                               displayToastMessage("Phone number is Manadatory", context);
//                             }
//                             else if(passwordTextEditingController.text.length < 7)
//                             {
//                               displayToastMessage("password must be at least 6 characters.", context);
//                             } else if(backImageController.text.isEmpty)
//                             {
//                               displayToastMessage("please Enter id", context);
//                             }
//                             else if(frontImageController.text.isEmpty)
//                             {
//                               displayToastMessage("please Enter id.", context);
//                             }
//
//                             else {
//                               registerNewUser(context);
//                             }
//
//
//
//                           },
//                           child: Text(
//                             "Signup",
//                             style: TextStyle(
//                                 fontSize: 18,
//                                 fontFamily: "Brand-Bold"
//                             ),
//                           ))
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: (){
//                     // Navigator.push(context, MaterialPageRoute(builder:(contex) => const ForgotPasswordScreen()));
//
//
//                   },
//                   child: Text("Forgot Password?",style: TextStyle(
//                       color:  Colors.blue
//                   ),),
//                 ),
//                 const SizedBox(height: 30,),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//
//                   children: [
//                     const Text(" have An Account?",style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 15
//                     ),),
//                     const SizedBox(width: 5,),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
//                         // Navigator.push(context, MaterialPageRoute(builder:(contex) => const SignupScreen()));
//
//
//                       },
//                       child: Text("Login",style: TextStyle(
//                           fontSize: 15,
//                           color:  Colors.lightBlue
//                       ),),
//
//                     )
//                   ],
//                 )
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
//
//   void registerNewUser(BuildContext context) async{
//
//     showDialog(context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context)
//         {
//           return ProgressDialog(message: "Registering, please wait",);
//         }
//     );
//
//     final User? user=(await _firebaseAuth.createUserWithEmailAndPassword(email: emailTextEditingController.text,
//         password: passwordTextEditingController.text).catchError((errmsg){
//       Navigator.pop(context);
//       displayToastMessage("Error" + errmsg.toString(), context);
//
//     })).user;
//
//     if(user != null)
//     {
//       Map userDataMap = {
//         "name":nameTextEditingController.text.trim(),
//         "email":emailTextEditingController.text.trim(),
//         "phone":phoneTextEditingController.text.trim(),
//         "password":passwordTextEditingController.text.trim(),
//         "frontImage": frontImagePath ?? "",
//         "backImage": backImagePath ?? "",
//
//       };
//       uploadImages(user.uid);
//       await car_ownerRref.child(user.uid).set(userDataMap);
//       currentfirebaseUser=user;
//
//
//
//       displayToastMessage("Your Account has been created", context);
//
//       Navigator.pushNamedAndRemoveUntil(
//           context, MainScreen.idScreen, (route) => false);
//       //  Navigator.pushNamed(context, CarInfoScreen.idScreen);
//     }
//     else{
//       Navigator.pop(context);
//       displayToastMessage("Account has not been created", context);
//
//     }
//
//
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
//   Future<void> _pickFrontImageCamera() async {
//     final pickedFile =
//     await ImagePicker().pickImage(source: ImageSource.camera);
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
//     await ImagePicker().pickImage(source: ImageSource.camera);
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
//     await ImagePicker().pickImage(source: ImageSource.gallery);
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
//     await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         backImagePath = pickedFile.path;
//         backImageController.text = pickedFile.path ?? '';
//       });
//     }
//   }
//   Future<void> _uploadImage(String userId, String imageName, String imagePath) async {
//     try {
//       File imageFile = File(imagePath);
//       TaskSnapshot snapshot = await _storage.ref("car_owners/$userId/$imageName").putFile(imageFile);
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       if (imageName == "front_image.jpg") {
//         frontImagePath = downloadUrl;
//       } else if (imageName == "back_image.jpg") {
//         backImagePath = downloadUrl;
//
//       }
//
//       print("dfjgkljjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"+downloadUrl);
//     } catch (e) {
//       print("Error uploading image: $e");
//     }
//   }
//
//
// }
//
// displayToastMessage(String message,BuildContext context)
// {
//   Fluttertoast.showToast(msg: message);
// }

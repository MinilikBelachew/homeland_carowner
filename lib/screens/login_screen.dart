
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:car_owner/main.dart';
import 'package:car_owner/screens/main_screen.dart';
import 'package:car_owner/screens/signup_screen.dart';
import 'package:car_owner/widgets/progess_dialog.dart';

import '../config_maps.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  LoginScreen({super.key});
  final myGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Colors.lightBlueAccent],
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
      Scaffold(
        body: Container(
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
                  height: 300,
                  color: Colors.teal,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Login",
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
                      SizedBox(
                        height: 1,
                      ),
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(

                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400, // Lighter grey for better contrast
                            fontSize: 14, // Increase label size for readability
                          ),
                          enabledBorder: OutlineInputBorder( // Style the border
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            borderSide: BorderSide(color: Colors.black, width: 1.0), // Light border
                          ),
                          focusedBorder: OutlineInputBorder( // Style the border when focused
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
                          ),
                        ),
                        style: TextStyle(fontSize: 16), // Increase text size for better readability
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "password",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade400, // Lighter grey for better contrast
                            fontSize: 14, // Increase label size for readability
                          ),
                          enabledBorder: OutlineInputBorder( // Style the border
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            borderSide: BorderSide(color: Colors.blue, width: 1.0), // Light border
                          ),
                          focusedBorder: OutlineInputBorder( // Style the border when focused
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
                          ),
                        ),
                        style: TextStyle(fontSize: 16), // Increase text size for better readability
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(height: 10,),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor:
                              Colors.lightBlueAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(double.infinity, 50)),

                          onPressed: () {
                            if (!emailTextEditingController.text.contains("@")) {
                              displayToastMessage(
                                  "Email Address Is not Valid", context);
                            }
                            else if (passwordTextEditingController.text.isEmpty) {
                              displayToastMessage("Password is not correct",
                                  context);
                            }
                            else {
                              loginAndAuthenticationUser(context);
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Brand-Bold"
                            ),
                          ))
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder:(contex) => const ForgotPasswordScreen()));


                  },
                  child: Text("Forgot Password?", style: TextStyle(
                      color: Colors.blue
                  ),),
                ),
                const SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text("Don't have An Account?", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15
                    ),),
                    const SizedBox(width: 5,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, SignupScreen.idScreen, (route) => false);
                        // Navigator.push(context, MaterialPageRoute(builder:(contex) => const SignupScreen()));


                      },
                      child: Text("Register", style: TextStyle(
                          fontSize: 15,
                          color: Colors.lightBlue
                      ),),

                    )
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  void loginAndAuthenticationUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Authenticating, please wait...");
      },
    );

    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        final snapshot = await car_ownerRref.child(user.uid).once();

        if (snapshot.snapshot.value != null) {
          currentfirebaseUser= firebaseUser;

          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage("You are logged in", context);
        } else {
          Navigator.pop(context);
          await _firebaseAuth.signOut();
          displayToastMessage(
              "No record exists for this account. Please create a new Account",
              context);
        }
      } else {
        Navigator.pop(context);
        displayToastMessage("Error Occurred", context);
      }
    } catch (error) {
      Navigator.pop(context);
      displayToastMessage("Error: $error", context);
    }
  }
}
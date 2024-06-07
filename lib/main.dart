
import 'package:car_owner/data_handler/app_data.dart';
import 'package:car_owner/screens/car_info_screen.dart';
import 'package:car_owner/screens/login_screen.dart';
import 'package:car_owner/screens/main_screen.dart';
import 'package:car_owner/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import "package:firebase_auth/firebase_auth.dart";

import 'config_maps.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBJ0H1IflNFaMKt7Pnfu4uatPPQ4XvVnrA",
          appId: "1:771185889083:android:71d4511c5407eb3312b11e",
          messagingSenderId: "771185889083",
          projectId: "homeland-95f19",
          databaseURL:"https://homeland-95f19-default-rtdb.firebaseio.com/",
          storageBucket: "homeland-95f19.appspot.com"

      )
  );
   FirebaseDatabase.instance.setPersistenceEnabled(true);
  //await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  currentfirebaseUser= FirebaseAuth.instance.currentUser;


  runApp(const MyApp());
}

DatabaseReference useRref=FirebaseDatabase.instance.ref().child("users");
DatabaseReference driverRref=FirebaseDatabase.instance.ref().child("drivers");

DatabaseReference car_ownerRref=FirebaseDatabase.instance.ref().child("car_owners");
DatabaseReference newRequestRref=FirebaseDatabase.instance.ref().child("Ride Request");



//DatabaseReference rideRequestRref=FirebaseDatabase.instance.ref().child("drivers").child(currentfirebaseUser!.uid).child("newRide");


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>AppData(),
      child: MaterialApp(
          title: 'Driver',
          theme: ThemeData(
            primarySwatch: Colors.teal, // Choose your preferred primary color
            hintColor: Colors.lightBlueAccent,

            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),

          initialRoute:  LoginScreen.idScreen,
          routes: {
            SignupScreen.idScreen:(context) => SignupScreen(),
            LoginScreen.idScreen:(context) => LoginScreen(),
            MainScreen.idScreen:(context)=> MainScreen(),
            CarInfoScreen.idScreen:(context)=> CarInfoScreen()

          },


          debugShowCheckedModeBanner: false

      ),
    );
  }
}



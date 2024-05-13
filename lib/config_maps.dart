import 'dart:async';


import 'package:firebase_auth/firebase_auth.dart';

import 'models/all_user.dart';
import 'models/drivers.dart';
String mapkey="AIzaSyAleDgZbox33LEXbNbOFjEf9duUA1rjyTA";

User? firebaseUser;
Users? userCurrentInf;
User? currentfirebaseUser;



Drivers? driversInformation;
String title="";
double startCounter=0.0;

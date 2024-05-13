import 'package:car_owner/main.dart';
import 'package:car_owner/screens/main_screen.dart';
import 'package:car_owner/screens/signup_screen.dart';
import 'package:flutter/material.dart';

import '../config_maps.dart';

class CarInfoScreen extends StatelessWidget {
  CarInfoScreen({super.key});
  static const String idScreen = "carinfo";
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 22,
              ),
              Image.asset(
                "images/home2.png",
                width: 390,
                height: 2250,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 31),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Enter Car Details",
                      style: TextStyle(fontFamily: "Brand-Bold", fontSize: 24),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: InputDecoration(
                          labelText: "Car Color",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: InputDecoration(
                          labelText: "Car Model",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: InputDecoration(
                          labelText: "Car Number",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          if (carModelTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Please write the car Model", context);
                          } else if (carNumberTextEditingController
                              .text.isEmpty) {
                            displayToastMessage(
                                "Please write the car Number", context);
                          } else if (carColorTextEditingController
                              .text.isEmpty) {
                            displayToastMessage(
                                "Please write the car Color", context);
                          } else {
                            saveCarInfo(context);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Next",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveCarInfo(context) {
    String userId = currentfirebaseUser!.uid;
    Map carInfoMap = {
      "car_color": carColorTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text
    };
    car_ownerRref.child(userId).set(carInfoMap);
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}

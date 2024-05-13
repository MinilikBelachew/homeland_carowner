import 'package:firebase_database/firebase_database.dart';

class Drivers
{
  String? name;
  String? phone;
  String? email;
  String? id;
  String? car_color;
  String? car_model;
  String? car_number;
  Drivers({
    this.name,this.phone,this.email,this.id,this.car_color,this.car_number,this.car_model
});

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      phone = values["phone"] as String?;
      email = values["email"] as String?;
      name = values["name"] as String?;

      // Nested properties
      Map<dynamic, dynamic>? carDetails = values["car_details"] as Map<dynamic, dynamic>?;

      if (carDetails != null) {
        car_color = carDetails["car_color"] as String?;
        car_model = carDetails["car_model"] as String?;
        car_number = carDetails["car_number"] as String?;
      }
    }
  }





}
import 'package:firebase_database/firebase_database.dart';

class Users
{
  String? id;
  String? email;
  String? name;
  String? phone;

  Users({
    this.id,
    this.phone,
    this.name,
    this.email
});



  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    final data = dataSnapshot.value as Map<String, dynamic>?;
    email = data?["email"] ?? "";
    name = data?["name"] ?? "";
    phone = data?["phone"] ?? "";
  }

}



// Users.fromSnapshot(DataSnapshot dataSnapshot) {
//   id = dataSnapshot.key;
//   email = (dataSnapshot.value as Map<String, dynamic>)["email"];
//   name = (dataSnapshot.value as Map<String, dynamic>)["name"];
//   phone = (dataSnapshot.value as Map<String, dynamic>)["phone"];
// }

// Users.fromSnapshot(DataSnapshot dataSnapshot) {
//   if (dataSnapshot.value != null) {
//     id = dataSnapshot.key;
//     email = dataSnapshot.value!["email"];
//     name = dataSnapshot.value["name"];
//     phone = dataSnapshot.value["phone"];
//   }
// }
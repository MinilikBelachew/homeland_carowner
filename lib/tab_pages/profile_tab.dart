//
//
//
//
//
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
//
// class CarOwnerProfilePage extends StatefulWidget {
//   @override
//   _CarOwnerProfilePageState createState() => _CarOwnerProfilePageState();
// }
//
// class _CarOwnerProfilePageState extends State<CarOwnerProfilePage> {
//   final DatabaseReference _carOwnerRef = FirebaseDatabase.instance.ref().child('car_owners');
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _phoneController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//
//   String _frontImage = '';
//   String _backImage = '';
//
//   bool _isEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchCarOwnerData();
//   }
//
//   void _fetchCarOwnerData() async {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       String userId = currentUser.uid;
//       DatabaseEvent event = await _carOwnerRef.child(userId).once();
//       DataSnapshot snapshot = event.snapshot; // Access the DataSnapshot from the event
//       if (snapshot.value != null) {
//         Map<dynamic, dynamic> carOwnerData = snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           _nameController.text = carOwnerData['name'];
//           _emailController.text = carOwnerData['email'];
//           _phoneController.text = carOwnerData['phone'];
//           _passwordController.text = carOwnerData['password'];
//           _frontImage = carOwnerData['frontImage'];
//           _backImage = carOwnerData['backImage'];
//         });
//       }
//     }
//   }
//
//   void _updateCarOwnerData() {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       String userId = currentUser.uid;
//       _carOwnerRef.child(userId).update({
//         'name': _nameController.text,
//         'email': _emailController.text,
//         'phone': _phoneController.text,
//         'password': _passwordController.text,
//       }).then((_) {
//         setState(() {
//           _isEditing = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
//       }).catchError((error) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $error')));
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               setState(() {
//                 _isEditing = !_isEditing;
//                 if (!_isEditing) {
//                   _updateCarOwnerData();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               controller: _nameController,
//               readOnly: !_isEditing,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextFormField(
//               controller: _emailController,
//               readOnly: true,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextFormField(
//               controller: _phoneController,
//               readOnly: !_isEditing,
//               decoration: InputDecoration(labelText: 'Phone'),
//             ),
//             TextFormField(
//               controller: _passwordController,
//               readOnly: !_isEditing,
//               decoration: InputDecoration(labelText: 'Password'),
//             ),
//             SizedBox(height: 20),
//             if (_frontImage.isNotEmpty)
//               Image.network(
//                 _frontImage,
//                 width: 100,
//                 height: 100,
//                 fit: BoxFit.cover,
//               ),
//             // Display back image
//             if (_backImage.isNotEmpty)
//               Image.network(
//                 _backImage,
//                 width: 100,
//                 height: 100,
//                 fit: BoxFit.cover,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarOwnerProfilePage extends StatefulWidget {
  @override
  _CarOwnerProfilePageState createState() => _CarOwnerProfilePageState();
}

class _CarOwnerProfilePageState extends State<CarOwnerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _frontImage = '';
  String _backImage = '';

  bool _isEditing = false;

  // Shared Preferences instance
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPrefs();
    _fetchCarOwnerData();
  }

  Future<void> _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCarOwnerDataFromPrefs();
  }

  void _loadCarOwnerDataFromPrefs() {
    setState(() {
      _nameController.text = _prefs.getString('name') ?? '';
      _emailController.text = _prefs.getString('email') ?? '';
      _phoneController.text = _prefs.getString('phone') ?? '';
      _passwordController.text = _prefs.getString('password') ?? '';
    });
  }

  void _fetchCarOwnerData() async {
    // Consider implementing Firebase data fetching here if needed
    // ...
  }

  void _saveCarOwnerDataToPrefs() async {
    await _prefs.setString('name', _nameController.text);
    await _prefs.setString('email', _emailController.text);
    await _prefs.setString('phone', _phoneController.text);
    await _prefs.setString('password', _passwordController.text);
  }

  void _updateCarOwnerData() async {
    // Update data on Firebase if needed
    // ...

    _saveCarOwnerDataToPrefs();

    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _updateCarOwnerData();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              readOnly: !_isEditing,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneController,
              readOnly: !_isEditing,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _passwordController,
              readOnly: !_isEditing,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            if (_frontImage.isNotEmpty)
              Image.network(
                _frontImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            // Display back image
            if (_backImage.isNotEmpty)
              Image.network(
                _backImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}

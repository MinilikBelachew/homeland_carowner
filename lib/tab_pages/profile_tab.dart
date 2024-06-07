import 'package:car_owner/config_maps.dart';
import 'package:car_owner/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  dynamic _frontImage; // Can be File or String (URL)
  dynamic _backImage; // Can be File or String (URL)
  dynamic _profileImage; // Can be File or String (URL)
  final picker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    _fetchProfileDataFromFirebase();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchProfileDataFromFirebase() async {
    try {
      if (currentfirebaseUser != null) {
        final profileRef = FirebaseDatabase.instance
            .ref()
            .child('car_owners')
            .child(currentfirebaseUser!.uid);
        final snapshot = await profileRef.once().then((event) => event.snapshot);

        if (snapshot.value != null) {
          final profileData = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _nameController.text = profileData['name'] ?? '';
            _emailController.text = profileData['email'] ?? '';
            _phoneController.text = profileData['phone'] ?? '';
            _backImage = profileData['backImage'];
            _frontImage = profileData['frontImage'];
            _profileImage = profileData['profileImage'];
          });
        }
      }
    } catch (error) {
      print('Error loading profile data: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading profile data')));
    }
  }

  Future<void> _updateProfileData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (currentfirebaseUser != null) {
          final profileRef = FirebaseDatabase.instance
              .ref()
              .child('car_owners')
              .child(currentfirebaseUser!.uid);
          await profileRef.update({
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'backImage': _backImage,
            'frontImage': _frontImage,
            'profileImage': _profileImage,
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated successfully')));
        }
      } catch (error) {
        print('Error updating profile data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile data')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source, {required bool isFront, bool isProfile = false}) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(pickedFile.path);
          } else if (isFront) {
            _frontImage = File(pickedFile.path);
          } else {
            _backImage = File(pickedFile.path);
          }
        });
        _uploadImageToFirebase(File(pickedFile.path), isFront: isFront, isProfile: isProfile);
      }
    } catch (error) {
      print('Error picking image: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking image')));
    }
  }

  Future<void> _uploadImageToFirebase(File image, {required bool isFront, bool isProfile = false}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (currentfirebaseUser != null) {
        final storage = FirebaseStorage.instance;
        String imageName;
        if (isProfile) {
          imageName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        } else if (isFront) {
          imageName = 'front_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        } else {
          imageName = 'back_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }
        final ref = storage.ref().child('car_owners').child(currentfirebaseUser!.uid).child(imageName);
        final uploadTask = ref.putFile(image);
        final taskSnapshot = await uploadTask;
        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          if (isProfile) {
            _profileImage = downloadURL;
          } else if (isFront) {
            _frontImage = downloadURL;
          } else {
            _backImage = downloadURL;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image uploaded successfully')));
      }
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading image')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.idScreen, (route) => false);
    } catch (error) {
      print('Error logging out: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error logging out')));
    }
  }

  void _showImageSourceActionSheet({required bool isFront, bool isProfile = false}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Photo Library'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery, isFront: isFront, isProfile: isProfile);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera, isFront: isFront, isProfile: isProfile);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: GestureDetector(
                    onTap: _isEditing
                        ? () => _showImageSourceActionSheet(isFront: false, isProfile: true)
                        : null,
                    child:
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage is File
                          ? FileImage(_profileImage)
                          : (_profileImage is String)
                          ? NetworkImage(_profileImage)
                          : AssetImage('images/user_icon.png')
                      as ImageProvider,
                      child: _isEditing
                          ? IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () =>
                            _showImageSourceActionSheet(isFront: false, isProfile: true),
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                  ),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text('Front Image'),
                GestureDetector(
                  onTap: _isEditing
                      ? () => _showImageSourceActionSheet(isFront: true)
                      : null,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: _frontImage != null
                        ? _frontImage is String
                        ? Image.network(_frontImage, fit: BoxFit.cover)
                        : Image.file(_frontImage, fit: BoxFit.cover)
                        : Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Back Image'),
                GestureDetector(
                  onTap: _isEditing
                      ? () => _showImageSourceActionSheet(isFront: false)
                      : null,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: _backImage != null
                        ? _backImage is String
                        ? Image.network(_backImage, fit: BoxFit.cover)
                        : Image.file(_backImage, fit: BoxFit.cover)
                        : Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isEditing)
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateProfileData,
                      child: Text('Save Changes'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}









//
//
// import 'package:car_owner/config_maps.dart';
// import 'package:car_owner/screens/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io';
// import 'dart:convert';
//
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   dynamic _frontImage; // Can be File or String (URL)
//   dynamic _backImage; // Can be File or String (URL)
//   dynamic _profileImage; // Can be File or String (URL)
//   final picker = ImagePicker();
//   bool _isEditing = false;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//   }
//   Future<void> _loadProfileData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (prefs.containsKey('profileData')) {
//       setState(() {
//         Map<String, dynamic> profileData = json.decode(prefs.getString('profileData')!);
//         // Populate UI with data from local storage
//         _nameController.text = profileData['name'] ?? '';
//         _emailController.text = profileData['email'] ?? '';
//         _phoneController.text = profileData['phone'] ?? '';
//         _backImage = profileData['backImage'];
//         _frontImage = profileData['frontImage'];
//         _profileImage = profileData['profileImage'];
//       });
//     } else {
//       _fetchProfileDataFromFirebase();
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _fetchProfileDataFromFirebase() async {
//     try {
//       //final user = FirebaseAuth.instance.currentUser;
//       if (currentfirebaseUser != null) {
//         final profileRef = FirebaseDatabase.instance
//             .ref()
//             .child('car_owners')
//             .child(currentfirebaseUser!.uid);
//         final snapshot =
//         await profileRef.once().then((event) => event.snapshot);
//
//         if (snapshot.value != null) {
//           final profileData = Map<String, dynamic>.from(snapshot.value as Map);
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString('profileData', json.encode(profileData));
//           setState(() {
//             _nameController.text = profileData['name'] ?? '';
//             _emailController.text = profileData['email'] ?? '';
//             _phoneController.text = profileData['phone'] ?? '';
//             _backImage = profileData['backImage'];
//             _frontImage = profileData['frontImage'];
//             _profileImage = profileData['profileImage'];
//           });
//         }
//       }
//     } catch (error) {
//       print('Error loading profile data: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error loading profile data')));
//     }
//   }
//
//   Future<void> _updateProfileData() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         //final user = FirebaseAuth.instance.currentUser;
//         if (currentfirebaseUser != null) {
//           final profileRef = FirebaseDatabase.instance
//               .ref()
//               .child('car_owners')
//               .child(currentfirebaseUser!.uid);
//           await profileRef.update({
//             'name': _nameController.text,
//             'email': _emailController.text,
//             'phone': _phoneController.text,
//             'backImage': _backImage,
//             'frontImage': _frontImage,
//             'profileImage': _profileImage,
//           });
//
//           // Update local storage
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           Map<String, dynamic> profileData = {
//             'name': _nameController.text,
//             'email': _emailController.text,
//             'phone': _phoneController.text,
//             'backImage': _backImage,
//             'frontImage': _frontImage,
//             'profileImage': _profileImage,
//           };
//           prefs.setString('profileData', json.encode(profileData));
//
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Profile updated successfully')));
//         }
//       } catch (error) {
//         print('Error updating profile data: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error updating profile data')));
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // Future<void> _updateProfileData() async {
//   //   if (_formKey.currentState!.validate()) {
//   //     setState(() {
//   //       _isLoading = true;
//   //     });
//   //     try {
//   //       final user = FirebaseAuth.instance.currentUser;
//   //       if (user != null) {
//   //         final profileRef = FirebaseDatabase.instance
//   //             .reference()
//   //             .child('car_owners')
//   //             .child(user.uid);
//   //         await profileRef.update({
//   //           'name': _nameController.text,
//   //           'email': _emailController.text,
//   //           'phone': _phoneController.text,
//   //           'backImage': _backImage,
//   //           'frontImage': _frontImage,
//   //           'profileImage': _profileImage,
//   //         });
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //             SnackBar(content: Text('Profile updated successfully')));
//   //       }
//   //     } catch (error) {
//   //       print('Error updating profile data: $error');
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(content: Text('Error updating profile data')));
//   //     } finally {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }
//
//   Future<void> _pickImage(ImageSource source, {required bool isFront, bool isProfile = false}) async {
//     try {
//       final pickedFile = await picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() {
//           if (isProfile) {
//             _profileImage = File(pickedFile.path);
//           } else if (isFront) {
//             _frontImage = File(pickedFile.path);
//           } else {
//             _backImage = File(pickedFile.path);
//           }
//         });
//         _uploadImageToFirebase(File(pickedFile.path), isFront: isFront, isProfile: isProfile);
//       }
//     } catch (error) {
//       print('Error picking image: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error picking image')));
//     }
//   }
//   // Future<void> _uploadImageToFirebase(File image, {required bool isFront, bool isProfile = false}) async {
//   //   setState(() {
//   //     _isLoading = true;
//   //   });
//   //   try {
//   //     //final user = FirebaseAuth.instance.currentUser;
//   //     if (currentfirebaseUser != null) {
//   //       final storage = FirebaseStorage.instance;
//   //       String imageName;
//   //       if (isProfile) {
//   //         imageName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//   //       } else if (isFront) {
//   //         imageName = 'front_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//   //       } else {
//   //         imageName = 'back_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//   //       }
//   //
//   //       // Check if there's an existing image to replace
//   //       String? oldImageUrl;
//   //       if (isProfile) {
//   //         oldImageUrl = _profileImage;
//   //       } else if (isFront) {
//   //         oldImageUrl = _frontImage;
//   //       } else {
//   //         oldImageUrl = _backImage;
//   //       }
//   //       if (oldImageUrl != null) {
//   //         // Extract the image name from the URL
//   //         String oldImageName = oldImageUrl.split('/').last.split('?').first;
//   //         // Create a reference to the old image
//   //         Reference oldImageRef = storage.refFromURL(oldImageUrl);
//   //         // Delete the old image
//   //         await oldImageRef.delete();
//   //       }
//   //
//   //       final ref = storage.ref().child('car_owners').child(currentfirebaseUser!.uid).child(imageName);
//   //       final uploadTask = ref.putFile(image);
//   //       final taskSnapshot = await uploadTask;
//   //       final downloadURL = await taskSnapshot.ref.getDownloadURL();
//   //       setState(() {
//   //         if (isProfile) {
//   //           _profileImage = downloadURL;
//   //         } else if (isFront) {
//   //           _frontImage = downloadURL;
//   //         } else {
//   //           _backImage = downloadURL;
//   //         }
//   //       });
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(content: Text('Image uploaded successfully')));
//   //     }
//   //   } catch (error) {
//   //     print('Error uploading image: $error');
//   //     ScaffoldMessenger.of(context)
//   //         .showSnackBar(SnackBar(content: Text('Error uploading image')));
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
//
//
//
//   Future<void> _uploadImageToFirebase(File image, {required bool isFront, bool isProfile = false}) async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       //final user = FirebaseAuth.instance.currentUser;
//       if (currentfirebaseUser != null) {
//         final storage = FirebaseStorage.instance;
//         String imageName;
//         if (isProfile) {
//           imageName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         } else if (isFront) {
//           imageName = 'front_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         } else {
//           imageName = 'back_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         }
//         final ref = storage.ref().child('car_owners').child(currentfirebaseUser!.uid).child(imageName);
//         final uploadTask = ref.putFile(image);
//         final taskSnapshot = await uploadTask;
//         final downloadURL = await taskSnapshot.ref.getDownloadURL();
//         setState(() {
//           if (isProfile) {
//             _profileImage = downloadURL;
//           } else if (isFront) {
//             _frontImage = downloadURL;
//           } else {
//             _backImage = downloadURL;
//           }
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Image uploaded successfully')));
//       }
//     } catch (error) {
//       print('Error uploading image: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error uploading image')));
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushNamedAndRemoveUntil(
//           context, LoginScreen.idScreen, (route) => false);
//     } catch (error) {
//       print('Error logging out: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error logging out')));
//     }
//   }
//
//   void _showImageSourceActionSheet({required bool isFront, bool isProfile = false}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.gallery, isFront: isFront, isProfile: isProfile);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.camera, isFront: isFront, isProfile: isProfile);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout, color: Colors.red),
//             onPressed: _logout,
//           ),
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.black),
//             onPressed: () {
//               if (_isEditing) {
//                 _updateProfileData();
//               }
//               setState(() {
//                 _isEditing = !_isEditing;
//               });
//             },
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueGrey[800]!, Colors.blueGrey[400]!],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundImage: _profileImage is File
//                           ? FileImage(_profileImage)
//                           : (_profileImage is String)
//                           ? NetworkImage(_profileImage)
//                           : AssetImage('images/user_icon.png')
//                       as ImageProvider,
//                       child: _isEditing
//                           ? IconButton(
//                         icon: Icon(Icons.camera_alt),
//                         onPressed: () =>
//                             _showImageSourceActionSheet(isFront: false, isProfile: true),
//                       )
//                           : null,
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.blueGrey[400]!, Colors.blueGrey[300]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             labelText: 'Name',
//                             filled: true,
//                             fillColor: Colors.transparent,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             contentPadding: const EdgeInsets.all(22.0),
//                           ),
//                           readOnly: !_isEditing,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.blueGrey[400]!, Colors.blueGrey[300]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: _emailController,
//                           decoration: InputDecoration(
//                             labelText: 'Email',
//                             filled: true,
//                             fillColor: Colors.transparent,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                           ),
//                           readOnly: true,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.blueGrey[400]!, Colors.blueGrey[300]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: _phoneController,
//                           decoration: InputDecoration(
//                             labelText: 'Phone Number',
//                             filled: true,
//                             fillColor: Colors.transparent,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                           ),
//                           readOnly: !_isEditing,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your phone number';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//                             onTap: () {
//                               if (_frontImage is String) {
//                                 launch(_frontImage);
//                               }
//                             },
//                             child: Container(
//                               height: 150,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.8),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: _frontImage is File
//                                   ? Image.file(_frontImage, fit: BoxFit.cover)
//                                   : (_frontImage is String)
//                                   ? Image.network(_frontImage, fit: BoxFit.cover)
//                                   : Center(child: Text('No Front Image')),
//                             ),
//                           ),
//                         ),
//                         if (_isEditing)
//                           IconButton(
//                             icon: Icon(Icons.photo_size_select_actual_outlined),
//                             onPressed: () =>
//                                 _showImageSourceActionSheet(isFront: true),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//                             onTap: () {
//                               if (_backImage is String) {
//                                 launch(_backImage);
//                               }
//                             },
//                             child: Container(
//                               height: 150,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.8),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: _backImage is File
//                                   ? Image.file(_backImage, fit: BoxFit.cover)
//                                   : (_backImage is String)
//                                   ? Image.network(_backImage, fit: BoxFit.cover)
//                                   : Center(child: Text('No Back Image')),
//                             ),
//                           ),
//                         ),
//                         if (_isEditing)
//                           IconButton(
//                             icon: Icon(Icons.photo_size_select_actual_outlined),
//                             onPressed: () =>
//                                 _showImageSourceActionSheet(isFront: false),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _isEditing ? _updateProfileData : null,
//                       child: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (_isLoading)
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:car_owner/screens/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io';
// import 'dart:convert';
//
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   dynamic _frontImage; // Can be File or String (URL)
//   dynamic _backImage; // Can be File or String (URL)
//   dynamic _profileImage; // Can be File or String (URL)
//   final picker = ImagePicker();
//   bool _isEditing = false;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//   }
//
//   Future<void> _loadProfileData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (prefs.containsKey('profileData')) {
//       setState(() {
//         Map<String, dynamic> profileData =
//             json.decode(prefs.getString('profileData')!);
//         _nameController.text = profileData['name'] ?? '';
//         _emailController.text = profileData['email'] ?? '';
//         _phoneController.text = profileData['phone'] ?? '';
//         _backImage = profileData['backImage'];
//         _frontImage = profileData['frontImage'];
//         _profileImage = profileData['profileImage'];
//       });
//     } else {
//       _fetchProfileDataFromFirebase();
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _fetchProfileDataFromFirebase() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final profileRef = FirebaseDatabase.instance
//             .ref()
//             .child('car_owners')
//             .child(user.uid);
//         final snapshot =
//             await profileRef.once().then((event) => event.snapshot);
//
//         if (snapshot.value != null) {
//           final profileData = Map<String, dynamic>.from(snapshot.value as Map);
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString('profileData', json.encode(profileData));
//           setState(() {
//             _nameController.text = profileData['name'] ?? '';
//             _emailController.text = profileData['email'] ?? '';
//             _phoneController.text = profileData['phone'] ?? '';
//             _backImage = profileData['backImage'];
//             _frontImage = profileData['frontImage'];
//             _profileImage = profileData['profileImage'];
//           });
//         }
//       }
//     } catch (error) {
//       print('Error loading profile data: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error loading profile data')));
//     }
//   }
//
//   Future<void> _updateProfileData() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           final profileRef = FirebaseDatabase.instance
//               .reference()
//               .child('car_owners')
//               .child(user.uid);
//           await profileRef.update({
//             'name': _nameController.text,
//             'email': _emailController.text,
//             'phone': _phoneController.text,
//             'backImage': _backImage,
//             'frontImage': _frontImage,
//             'profileImage': _profileImage,
//           });
//
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           Map<String, dynamic> profileData = {
//             'name': _nameController.text,
//             'email': _emailController.text,
//             'phone': _phoneController.text,
//             'backImage': _backImage,
//             'frontImage': _frontImage,
//             'profileImage': _profileImage,
//           };
//           prefs.setString('profileData', json.encode(profileData));
//
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Profile updated successfully')));
//         }
//       } catch (error) {
//         print('Error updating profile data: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error updating profile data')));
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _pickImage(ImageSource source,
//       {required bool isFront, bool isProfile = false}) async {
//     try {
//       final pickedFile = await picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() {
//           if (isProfile) {
//             _profileImage = File(pickedFile.path);
//           } else if (isFront) {
//             _frontImage = File(pickedFile.path);
//           } else {
//             _backImage = File(pickedFile.path);
//           }
//         });
//         _uploadImageToFirebase(File(pickedFile.path),
//             isFront: isFront, isProfile: isProfile);
//       }
//     } catch (error) {
//       print('Error picking image: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error picking image')));
//     }
//   }
//
//   Future<void> _uploadImageToFirebase(File image,
//       {required bool isFront, bool isProfile = false}) async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final storage = FirebaseStorage.instance;
//         String imageName;
//         if (isProfile) {
//           imageName =
//               'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         } else if (isFront) {
//           imageName =
//               'front_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         } else {
//           imageName = 'back_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         }
//         final ref =
//             storage.ref().child('car_owners').child(user.uid).child(imageName);
//         final uploadTask = ref.putFile(image);
//         final taskSnapshot = await uploadTask;
//         final downloadURL = await taskSnapshot.ref.getDownloadURL();
//         setState(() {
//           if (isProfile) {
//             _profileImage = downloadURL;
//           } else if (isFront) {
//             _frontImage = downloadURL;
//           } else {
//             _backImage = downloadURL;
//           }
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Image uploaded successfully')));
//       }
//     } catch (error) {
//       print('Error uploading image: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error uploading image')));
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushNamedAndRemoveUntil(
//           context, LoginScreen.idScreen, (route) => false);
//     } catch (error) {
//       print('Error logging out: $error');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error logging out')));
//     }
//   }
//
//   void _showImageSourceActionSheet(
//       {required bool isFront, bool isProfile = false}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.gallery,
//                       isFront: isFront, isProfile: isProfile);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.camera,
//                       isFront: isFront, isProfile: isProfile);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout, color: Colors.red),
//             onPressed: _logout,
//           ),
//           IconButton(
//             icon:
//                 Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.black),
//             onPressed: () {
//               if (_isEditing) {
//                 _updateProfileData();
//               }
//               setState(() {
//                 _isEditing = !_isEditing;
//               });
//             },
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueGrey[800]!, Colors.blueGrey[400]!],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundImage: _profileImage is File
//                           ? FileImage(_profileImage)
//                           : (_profileImage is String)
//                               ? NetworkImage(_profileImage)
//                               : AssetImage('images/user_icon.png')
//                                   as ImageProvider,
//                       child: _isEditing
//                           ? IconButton(
//                               icon: Icon(Icons.camera_alt),
//                               onPressed: () => _showImageSourceActionSheet(
//                                   isFront: false, isProfile: true),
//                             )
//                           : null,
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.blueGrey[400]!,
//                             Colors.blueGrey[300]!
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             labelText: 'Name',
//                             filled: true,
//                             fillColor: Colors.transparent,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             contentPadding: const EdgeInsets.all(22.0),
//                           ),
//                           readOnly: !_isEditing,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.blueGrey[400]!,
//                             Colors.blueGrey[300]!
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: _emailController,
//                           decoration: InputDecoration(
//                             labelText: 'Email',
//                             filled: true,
//                             fillColor: Colors.transparent,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                           ),
//                           readOnly: true,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.blueGrey[400]!,
//                             Colors.blueGrey[300]!
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: _phoneController,
//                           decoration: InputDecoration(
//                             labelText: 'Phone Number',
//                             filled: true,
//                             fillColor: Colors.transparent,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                           ),
//                           readOnly: !_isEditing,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your phone number';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//                             onTap: () {
//                               if (_backImage is String) {
//                                 launch(_backImage);
//                               }
//                             },
//                             child: Container(
//                               height: 150,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.8),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: _backImage is File
//                                   ? Image.file(_backImage, fit: BoxFit.cover)
//                                   : (_backImage is String)
//                                       ? Image.network(_backImage,
//                                           fit: BoxFit.cover)
//                                       : Center(child: Text('No Back Image')),
//                             ),
//                           ),
//                         ),
//                         if (_isEditing)
//                           IconButton(
//                             icon: Icon(Icons.photo_size_select_actual_outlined),
//                             onPressed: () =>
//                                 _showImageSourceActionSheet(isFront: false),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _isEditing ? _updateProfileData : null,
//                       child: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (_isLoading)
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }
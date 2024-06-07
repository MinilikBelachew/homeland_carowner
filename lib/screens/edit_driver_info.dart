import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditDriverInfoScreen extends StatefulWidget {
  final String driverKey;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String frontIdImg;
  final String backIdImg;

  EditDriverInfoScreen({
    required this.driverKey,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.frontIdImg,
    required this.backIdImg,
  });

  @override
  _EditDriverInfoScreenState createState() => _EditDriverInfoScreenState();
}

class _EditDriverInfoScreenState extends State<EditDriverInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;

  File? _frontIdImageFile;
  File? _backIdImageFile;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateDriverInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload the images if they were updated
        String frontIdImgUrl = widget.frontIdImg;
        String backIdImgUrl = widget.backIdImg;

        if (_frontIdImageFile != null) {
          frontIdImgUrl = await _uploadImage(_frontIdImageFile!);
        }
        if (_backIdImageFile != null) {
          backIdImgUrl = await _uploadImage(_backIdImageFile!);
        }

        await FirebaseDatabase.instance
            .ref()
            .child('car_owners')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('drivers')
            .child(widget.driverKey)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text,
          'front_id_img': frontIdImgUrl,
          'back_id_img': backIdImgUrl,
        });

        Navigator.pop(context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update driver info: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    // Implement image upload logic here
    // Return the URL of the uploaded image
    return 'https://example.com/uploaded_image.jpg'; // Placeholder URL
  }

  Future<void> _pickImage(ImageSource source, bool isFrontImage) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isFrontImage) {
          _frontIdImageFile = File(pickedFile.path);
        } else {
          _backIdImageFile = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Driver Info'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_nameController, 'Name'),
                    SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email'),
                    SizedBox(height: 20),
                    _buildTextField(_phoneNumberController, 'Phone Number'),
                    SizedBox(height: 20),
                    _buildTextField(_addressController, 'Address'),
                    SizedBox(height: 20),
                    Text(
                      'ID Images:',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildImageDisplay('Front ID Image', widget.frontIdImg, true),
                    SizedBox(height: 10),
                    _buildImageDisplay('Back ID Image', widget.backIdImg, false),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateDriverInfo,
                      child: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildImageDisplay(String label, String imageUrl, bool isFrontImage) {
    File? imageFile = isFrontImage ? _frontIdImageFile : _backIdImageFile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.0)),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery, isFrontImage),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Camera'),
              onPressed: () => _pickImage(ImageSource.camera, isFrontImage),
            ),
            TextButton.icon(
              icon: Icon(Icons.photo),
              label: Text('Gallery'),
              onPressed: () => _pickImage(ImageSource.gallery, isFrontImage),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/DialogBox/errorDialog.dart';
import 'package:jemeel/DialogBox/loadingDialog.dart';
import 'package:jemeel/config/config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        setState(() {
          _nameTextEditingController.text = userDoc['fullName'] ?? '';
          _phoneNumberTextEditingController.text = userDoc['phonenumber'] ?? '';
          _addressTextEditingController.text = userDoc['address'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Crown.primraryColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Full Name Field
                buildTextField(
                  controller: _nameTextEditingController,
                  hintText: "Full Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),

                // Phone Number Field
                buildTextField(
                  controller: _phoneNumberTextEditingController,
                  hintText: "Phone Number",
                  icon: Icons.phone,
                ),
                const SizedBox(height: 10),
                // Address Field
                buildTextField(
                  controller: _addressTextEditingController,
                  hintText: "Address",
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    saveUserProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Crown.primraryColor,
                    minimumSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      cursorColor: Colors.black,
      style: const TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.5),
        ),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Crown.primraryColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Crown.secondaryColor.withOpacity(0.5),
          ),
        ),
        prefixIcon: Icon(icon, color: Crown.primraryColor),
      ),
    );
  }

  Future<void> saveUserProfile() async {
    if (_nameTextEditingController.text.isNotEmpty &&
        _phoneNumberTextEditingController.text.isNotEmpty &&
        _addressTextEditingController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (c) {
          return const LoadingAlertDialog(
            message: "Saving changes, please wait...",
          );
        },
      );

      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            "fullName": _nameTextEditingController.text.trim(),
            "phonenumber": _phoneNumberTextEditingController.text.trim(),
            "address": _addressTextEditingController.text.trim(),
          });

          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to update profile. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorAlertDialog(
            message: "Please fill in all fields",
          );
        },
      );
    }
  }
}

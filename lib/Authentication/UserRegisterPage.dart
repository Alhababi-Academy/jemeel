import 'package:cloud_firestore/cloud_firestore.dart'; // للتعامل مع Cloud Firestore
import 'package:firebase_auth/firebase_auth.dart'; // للتعامل مع Firebase Auth
import 'package:flutter/material.dart';
import 'package:jemeel/Authentication/UserLogin.dart';
import 'package:jemeel/DialogBox/errorDialog.dart';
import 'package:jemeel/DialogBox/loadingDialog.dart';
import 'package:jemeel/config/config.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController =
      TextEditingController();
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        backgroundColor: Crown.primraryColor,
        title: const Text(
          'Create Account',
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
                // Logo
                Image.asset("images/logo2.png",
                    height: 300), // Add logo for branding
                const SizedBox(height: 30),

                // Full Name Field
                buildTextField(
                  controller: _nameTextEditingController,
                  hintText: "Full Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),

                // Email Field
                buildTextField(
                  controller: _emailTextEditingController,
                  hintText: "Email",
                  icon: Icons.email,
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
                const SizedBox(height: 10),

                // Password Field
                buildTextField(
                  controller: _passwordTextEditingController,
                  hintText: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // Confirm Password Field
                buildTextField(
                  controller: _confirmPasswordTextEditingController,
                  hintText: "Confirm Password",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    registerNewUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Crown.primraryColor,
                    minimumSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Register",
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
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.black, // Cursor color
      style: const TextStyle(
        color: Colors.black, // Set input text color to black
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.5), // Hint text color
        ),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Crown.primraryColor, // Border color when focused
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Crown.secondaryColor
                .withOpacity(0.5), // Border color when not focused
          ),
        ),
        prefixIcon: Icon(icon, color: Crown.primraryColor), // Icon color
      ),
    );
  }

  Future<void> registerNewUser() async {
    if (_emailTextEditingController.text.isNotEmpty &&
        _nameTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text.isNotEmpty &&
        _confirmPasswordTextEditingController.text.isNotEmpty &&
        _phoneNumberTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text ==
            _confirmPasswordTextEditingController.text) {
      registerUser();
    } else {
      displayDialog();
    }
  }

  displayDialog() {
    showDialog(
      context: context,
      builder: (c) {
        return const ErrorAlertDialog(
          message: "Please complete the form",
        );
      },
    );
  }

  registerUser() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingAlertDialog(
            message: "Validating data, wait...",
          );
        });
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((ID) {
      saveUserInfo(ID.user!.uid);
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future saveUserInfo(String currentUser) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUser).set({
      "uid": currentUser,
      "email": _emailTextEditingController.text.trim(),
      "fullName": _nameTextEditingController.text.trim(),
      "phonenumber": _phoneNumberTextEditingController.text.trim(),
      "address": _addressTextEditingController.text.trim(),
      "RegistredTime": DateTime.now(),
      "status": "",
      "type": "user",
    }).then((value) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const UserLogin()));
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  _AddDriverPageState createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add a new driver to Firestore
  Future<void> _addDriver() async {
    if (_emailController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      await _firestore.collection("users").add({
        "email": _emailController.text.trim(),
        "fullName": _nameController.text.trim(),
        "phonenumber": _phoneNumberController.text.trim(),
        "address": _addressController.text.trim(),
        "type": "driver",
        "RegistredTime": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver added successfully!")),
      );

      // Clear input fields
      _emailController.clear();
      _nameController.clear();
      _phoneNumberController.clear();
      _addressController.clear();
      _passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Crown.backgroundColor,
      appBar: AppBar(
        title: const Text("Add Driver"),
        backgroundColor: Crown.primraryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add a New Driver",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              buildTextField(_nameController, "Full Name", Icons.person),
              const SizedBox(height: 10),
              buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 10),
              buildTextField(
                  _phoneNumberController, "Phone Number", Icons.phone),
              const SizedBox(height: 10),
              buildTextField(_addressController, "Address", Icons.location_on),
              const SizedBox(height: 10),
              buildTextField(
                _passwordController,
                "Password",
                Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addDriver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Crown.primraryColor,
                  ),
                  child: const Text(
                    "Add Driver",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields with improved styles
  Widget buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.black,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Crown.primraryColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        prefixIcon: Icon(icon, color: Crown.primraryColor),
      ),
    );
  }
}

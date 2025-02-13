import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jemeel/config/config.dart';

class ManageAddressPage extends StatefulWidget {
  const ManageAddressPage({super.key});

  @override
  _ManageAddressPageState createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends State<ManageAddressPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  List<Map<String, dynamic>> addresses = [];
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _fetchUserAddresses();
  }

  Future<void> _fetchUserAddresses() async {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(userId).get();
      setState(() {
        addresses = List<Map<String, dynamic>>.from(
            userDoc['addresses'] ?? []); // Fetch all addresses
      });
    }
  }

  Future<void> _addAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      final newAddress = {
        "name": _nameController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "addressLine": _addressLineController.text.trim(),
        "latitude": latitude ?? 0.0,
        "longitude": longitude ?? 0.0,
      };

      setState(() {
        addresses.add(newAddress);
      });

      await _firestore.collection("users").doc(userId).set({
        "addresses": addresses,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address added successfully")),
      );

      _clearFields();
    }
  }

  Future<void> _deleteAddress(int index) async {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      setState(() {
        addresses.removeAt(index);
      });

      await _firestore.collection("users").doc(userId).set({
        "addresses": addresses,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address deleted successfully")),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _addressLineController.clear();
    _phoneController.clear();
    latitude = null;
    longitude = null;
  }

  String _extractShortAddress(String fullAddress) {
    List<String> parts = fullAddress.split(",");
    return parts.isNotEmpty ? parts.first.trim() : fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Addresses"),
        backgroundColor: Crown.primraryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Addresses:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                addresses.isEmpty
                    ? const Text("No addresses available")
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address = addresses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(address['name'] ?? "No Name"),
                                subtitle: Text(
                                  address['addressLine'] ?? "No Address",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteAddress(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 20),
                const Text(
                  "Add a New Address:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name is required.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number is required.";
                    }
                    final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
                    if (!phoneRegExp.hasMatch(value)) {
                      return "Enter a valid phone number.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _addressLineController,
                  focusNode: _addressFocusNode,
                  googleAPIKey: "AIzaSyBpLzaDvyWfvVvxD9xO3fM1i5FfCbjJ9nE",
                  inputDecoration: const InputDecoration(
                    labelText: "Search Address",
                    border: OutlineInputBorder(),
                  ),
                  debounceTime: 800,
                  isLatLngRequired: true,
                  itemClick: (prediction) async {
                    List<Location> locations =
                        await locationFromAddress(prediction.description!);
                    if (locations.isNotEmpty) {
                      setState(() {
                        latitude = locations.first.latitude;
                        longitude = locations.first.longitude;
                        _addressLineController.text =
                            _extractShortAddress(prediction.description!);
                      });

                      Future.delayed(const Duration(milliseconds: 100), () {
                        _addressFocusNode.requestFocus();
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _addAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Crown.buttonColor,
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text(
                      "Add Address",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
}

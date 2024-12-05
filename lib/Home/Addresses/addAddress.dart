import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';
import 'package:geolocator/geolocator.dart'; // For geolocation
import 'package:geocoding/geocoding.dart'; // For reverse geocoding

class ManageAddressPage extends StatefulWidget {
  const ManageAddressPage({super.key});

  @override
  _ManageAddressPageState createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends State<ManageAddressPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();

  List<Map<String, dynamic>> addresses = [];

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
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      final newAddress = {
        "name": _nameController.text.trim(),
        "city": _cityController.text.trim(),
        "zipCode": _zipCodeController.text.trim(),
        "addressLine": _addressLineController.text.trim(),
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
    _cityController.clear();
    _zipCodeController.clear();
    _addressLineController.clear();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Location services are disabled. Please enable them.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Enable them in settings.'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print("Position fetched: ${position.latitude}, ${position.longitude}");

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _cityController.text = place.locality ?? "Unknown City";
          _zipCodeController.text = place.postalCode ?? "Unknown Zip Code";
          _addressLineController.text =
              "${place.street}, ${place.subLocality}, ${place.administrativeArea}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location fetched successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch address details")),
        );
      }
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch data: $e")),
      );
    }
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
                      height: 200, // Fixed height for the address list
                      child: ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(address['name'] ?? "No Name"),
                              subtitle: Text(
                                "${address['addressLine']}, ${address['city']} - ${address['zipCode']}",
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                  labelText: "Zip Code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressLineController,
                decoration: const InputDecoration(
                  labelText: "Address Line",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Use Current Location"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Crown.secondaryColor,
                  minimumSize: const Size(200, 50),
                ),
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
    );
  }
}

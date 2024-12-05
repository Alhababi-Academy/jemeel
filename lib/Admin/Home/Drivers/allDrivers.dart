import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/Home/Drivers/addDriver.dart';
import 'package:jemeel/config/config.dart';

class AllDriversPage extends StatefulWidget {
  const AllDriversPage({super.key});

  @override
  _AllDriversPageState createState() => _AllDriversPageState();
}

class _AllDriversPageState extends State<AllDriversPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all drivers from Firestore
  Stream<QuerySnapshot> _fetchDrivers() {
    return _firestore
        .collection("users")
        .where("type", isEqualTo: "driver")
        .snapshots();
  }

  // Edit driver details
  void _editDriver(
      BuildContext context, String driverId, Map<String, dynamic> driverData) {
    final TextEditingController nameController =
        TextEditingController(text: driverData['fullName']);
    final TextEditingController emailController =
        TextEditingController(text: driverData['email']);
    final TextEditingController phoneController =
        TextEditingController(text: driverData['phonenumber']);
    final TextEditingController addressController =
        TextEditingController(text: driverData['address']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Driver"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Full Name"),
              const SizedBox(height: 10),
              _buildTextField(emailController, "Email"),
              const SizedBox(height: 10),
              _buildTextField(phoneController, "Phone Number"),
              const SizedBox(height: 10),
              _buildTextField(addressController, "Address"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection("users").doc(driverId).update({
                  "fullName": nameController.text.trim(),
                  "email": emailController.text.trim(),
                  "phonenumber": phoneController.text.trim(),
                  "address": addressController.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Driver updated successfully!")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete driver
  Future<void> _deleteDriver(String driverId) async {
    await _firestore.collection("users").doc(driverId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Driver deleted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Crown.backgroundColor,
      appBar: AppBar(
        title: const Text("All Drivers"),
        backgroundColor: Crown.primraryColor,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDriverPage()),
          );
        },
        backgroundColor: Crown.buttonColor,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchDrivers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No drivers found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var drivers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              var driver = drivers[index].data() as Map<String, dynamic>;
              String driverId = drivers[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    size: 40,
                    color: Crown.primraryColor,
                  ),
                  title: Text(
                    driver['fullName'] ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver['email'] ?? "No Email"),
                      Text("Phone: ${driver['phonenumber'] ?? "N/A"}"),
                      Text("Address: ${driver['address'] ?? "N/A"}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editDriver(context, driverId, driver),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDriver(driverId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to build text fields in the edit dialog
  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Crown.primraryColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }
}

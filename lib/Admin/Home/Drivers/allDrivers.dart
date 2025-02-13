import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  // Update driver status
  void _updateDriverStatus(
      BuildContext context, String driverId, String currentStatus) {
    final TextEditingController statusController =
        TextEditingController(text: currentStatus);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Driver Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: ["Pending", "Accepted"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    statusController.text = value;
                  }
                },
              ),
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
                  "status": statusController.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Driver status updated successfully!")),
                );
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
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
                      Text("Status: ${driver['status'] ?? "Pending"}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _updateDriverStatus(
                            context, driverId, driver['status'] ?? "Pending"),
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
}

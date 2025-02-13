import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all orders from Firestore
  Stream<QuerySnapshot> _fetchAllOrders() {
    return _firestore
        .collection("orders")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // Fetch drivers from Firestore
  Future<List<Map<String, dynamic>>> _fetchDrivers() async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .where("type", isEqualTo: "driver")
        .where("status", isEqualTo: "Accepted")
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "fullName": doc['fullName'],
        "email": doc['email'],
        "phonenumber": doc['phonenumber'],
      };
    }).toList();
  }

  // Update order status
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection("orders").doc(orderId).update({
      "status": newStatus,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order status updated to $newStatus.")),
    );
  }

  // Assign a delivery person
  Future<void> _assignDeliveryPerson(String orderId, String deliveryPersonId,
      String deliveryPersonName, String deliveryPhoneNumber) async {
    await _firestore.collection("orders").doc(orderId).update({
      "deliveryPersonId": deliveryPersonId,
      "deliveryPerson": deliveryPersonName,
      "deliveryPhoneNumber": deliveryPhoneNumber,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Delivery person assigned: $deliveryPersonName.")),
    );
  }

  // Show dialog to assign a delivery person
  void _showAssignDeliveryDialog(String orderId) async {
    List<Map<String, dynamic>> drivers = await _fetchDrivers();
    String? selectedDriverId;
    String? selectedDriverName;
    String? deliveryPhoneNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Assign Delivery Person"),
          content: DropdownButtonFormField(
            items: drivers.map((driver) {
              return DropdownMenuItem(
                value: driver["id"],
                child: Text("${driver['fullName']} (${driver['phonenumber']})"),
              );
            }).toList(),
            onChanged: (value) {
              selectedDriverId = value as String?;
              selectedDriverName = drivers
                  .firstWhere((driver) => driver["id"] == value)["fullName"];

              deliveryPhoneNumber = drivers
                  .firstWhere((driver) => driver["id"] == value)['phonenumber'];
              print("phoneNumber $deliveryPhoneNumber");
            },
            decoration: const InputDecoration(
              labelText: "Select Driver",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDriverId != null && selectedDriverName != null) {
                  _assignDeliveryPerson(orderId, selectedDriverId!,
                      selectedDriverName!, deliveryPhoneNumber!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please select a delivery person.")),
                  );
                }
              },
              child: const Text("Assign"),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to change order status
  void _showStatusDialog(String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = currentStatus;
        return AlertDialog(
          title: const Text("Update Order Status"),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: "Pending", child: Text("Pending")),
              DropdownMenuItem(
                  value: "Out for Delivery", child: Text("Out for Delivery")),
              DropdownMenuItem(value: "On the Way", child: Text("On the Way")),
              DropdownMenuItem(value: "Delivered", child: Text("Delivered")),
            ],
            onChanged: (value) {
              selectedStatus = value!;
            },
            decoration: const InputDecoration(
              labelText: "Select Status",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateOrderStatus(orderId, selectedStatus);
                Navigator.pop(context);
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
        title: const Text(
          "Admin Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Crown.primraryColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading orders",
                style: TextStyle(color: Crown.errorColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              String orderId = orders[index].id;

              String productImage = order['productImage'] ??
                  "https://via.placeholder.com/150"; // Fallback image

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          productImage,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 100),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Order Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['productName'] ?? "Unknown Product",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Crown.textColor,
                            ),
                          ),
                          Text(
                            "₱${order['productPrice']}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Crown.primraryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Order Details
                      Text(
                        "Size: ${order['selectedSize'] ?? "N/A"}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Crown.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        "Status: ${order['status'] ?? "N/A"}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: order['status'] == "Pending"
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Delivery Person
                      Text(
                        "Delivery Person: ${order['deliveryPerson'] ?? "Not Assigned"}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Crown.textSecondaryColor,
                        ),
                      ),
                      Text(
                        "Delivery Phone Number: ${order['deliveryPhoneNumber'] ?? "Not Assigned"}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Crown.textSecondaryColor,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Admin Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _showStatusDialog(orderId, order['status']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Crown.buttonColor,
                            ),
                            child: const Text(
                              "Change Status",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showAssignDeliveryDialog(orderId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Crown.secondaryColor,
                            ),
                            child: const Text(
                              "Assign Delivery",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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

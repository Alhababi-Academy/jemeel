import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch user's orders from Firestore
  Stream<QuerySnapshot> _fetchUserOrders() {
    String userId = _auth.currentUser?.uid ?? "";
    return _firestore
        .collection("bookings")
        .where("userId", isEqualTo: userId)
        // .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Crown.backgroundColor,
      appBar: AppBar(
        title: const Text("Your Orders"),
        backgroundColor: Crown.primraryColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchUserOrders(),
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

                      // Address
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Delivery Address:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Crown.textColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${order['address']['addressLine'] ?? ""}, ${order['address']['city'] ?? ""} - ${order['address']['zipCode'] ?? ""}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Crown.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Payment Method
                      Text(
                        "Payment Method: ${order['paymentMethod'] ?? "N/A"}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Crown.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Booking Date
                      Text(
                        "Order Date: ${order['bookingDate'] ?? "N/A"}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Crown.textSecondaryColor,
                        ),
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

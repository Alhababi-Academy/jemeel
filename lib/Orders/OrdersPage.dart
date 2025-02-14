import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Home/chats/chat_page.dart';
import 'package:jemeel/Orders/TrackOrger.dart';
import 'package:jemeel/config/config.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminId = "MNf93LHCTmhzEZfv3xsCI5KjIgA2"; // Admin ID

  // Fetch user's orders from Firestore
  Stream<QuerySnapshot> _fetchUserOrders() {
    String userId = _auth.currentUser?.uid ?? "";
    return _firestore
        .collection("orders")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // Open or create a chat between the user and admin
  Future<void> _openChatWithAdmin(
      String orderId, Map<String, dynamic> orderDetails) async {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    try {
      // Ensure the chat room exists
      QuerySnapshot chatQuery = await _firestore
          .collection("chats")
          .where("participants", arrayContains: userId)
          .where("orderId", isEqualTo: orderId)
          .get();

      DocumentReference chatRef;
      if (chatQuery.docs.isEmpty) {
        // Create a new chat room document if none exists
        chatRef = await _firestore.collection("chats").add({
          "participants": [userId, adminId],
          "orderId": orderId,
          "orderDetails": orderDetails,
          "createdAt": FieldValue.serverTimestamp(),
          "lastMessage": "",
          "lastMessageAt": FieldValue.serverTimestamp(),
        });
      } else {
        chatRef = chatQuery.docs.first.reference;
      }

      // Navigate to the chat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatId: chatRef.id,
            orderDetails: orderDetails,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open chat: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Crown.primraryColor,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading orders"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              String orderId = orders[index].id;
              String deliveryPerson = order['deliveryPerson'] ?? "";

              String productImage = order['productImage'] ??
                  "https://via.placeholder.com/150"; // Fallback image

              // Address details including latitude and longitude
              String addressLine = order['address']['addressLine'] ?? "";
              String city = order['address']['city'] ?? "";
              String phoneNumber = order['address']['phoneNumber'] ?? "";
              String zipCode = order['address']['zipCode'] ?? "";
              double latitude = order['address']['latitude'] ?? 0.0;
              double longitude = order['address']['longitude'] ?? 0.0;

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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₱${order['productPrice']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Size: ${order['selectedSize'] ?? "N/A"}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                            ],
                          ),
                          IconButton(
                            onPressed: () => _openChatWithAdmin(orderId, order),
                            icon: const Icon(
                              Icons.chat,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Address
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Delivery Detailes:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$addressLine, $city - $zipCode",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            phoneNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Latitude: $latitude",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Longitude: $longitude",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (deliveryPerson != "") ...[
                        const Divider(height: 20, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Delivery Assigned:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${order['deliveryPerson']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${order['deliveryPhoneNumber']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DriverTrackingPage(
                                      orderId: orderId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delivery_dining_sharp,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const Divider(height: 20, thickness: 1),

                      // Payment Method
                      Text(
                        "Payment Method: ${order['paymentMethod'] ?? "N/A"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Booking Date
                      Text(
                        "Order Date: ${order['bookingDate'] ?? "N/A"}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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

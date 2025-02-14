import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Home/chats/chat_page.dart';
import 'package:jemeel/config/config.dart';

// If you plan to open a chat with admin, you can import your ChatPage:
// import 'package:jemeel/Home/chats/chat_page.dart';

class RentalOrdersPage extends StatefulWidget {
  const RentalOrdersPage({super.key});

  @override
  _RentalOrdersPageState createState() => _RentalOrdersPageState();
}

class _RentalOrdersPageState extends State<RentalOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Optional: admin ID if you want to open a chat with them
  final String adminId =
      "MNf93LHCTmhzEZfv3xsCI5KjIgA2"; // Replace with actual Admin UID

  // Stream of the user's rentals from Firestore
  Stream<QuerySnapshot> _fetchUserRentals() {
    final String userId = _auth.currentUser?.uid ?? "";
    return _firestore
        .collection("rentedClothes") // <-- Query "rentedClothes"
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp",
            descending: true) // Make sure 'timestamp' exists in your docs
        .snapshots();
  }

  // (Optional) If you want the user to chat with admin about a rental
  Future<void> _openChatWithAdmin(
      String rentalId, Map<String, dynamic> rentalDetails) async {
    final String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    try {
      // Check if a chat already exists for this user + rentalId
      QuerySnapshot chatQuery = await _firestore
          .collection("chats")
          .where("participants", arrayContains: userId)
          .where("orderId", isEqualTo: rentalId) // or "rentalId" field
          .get();

      DocumentReference chatRef;
      if (chatQuery.docs.isEmpty) {
        // Create new chat if none exists
        chatRef = await _firestore.collection("chats").add({
          "participants": [userId, adminId],
          "orderId": rentalId, // or "rentalId"
          "orderDetails": rentalDetails,
          "createdAt": FieldValue.serverTimestamp(),
          "lastMessage": "",
          "lastMessageAt": FieldValue.serverTimestamp(),
        });
      } else {
        chatRef = chatQuery.docs.first.reference;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatId: chatRef.id,
            orderDetails: rentalDetails,
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Your Rentals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Crown.primraryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchUserRentals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading rental orders"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No rentals found."));
          }

          final rentals = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rentalData = rentals[index].data() as Map<String, dynamic>;
              final String rentalId = rentals[index].id;

              // Extract fields from Firestore
              final String productImage = rentalData['productImage'] ??
                  "https://via.placeholder.com/150"; // fallback image
              final String productName = rentalData['productName'] ?? "Unknown";
              final double productPrice =
                  (rentalData['productPrice'] ?? 0).toDouble();
              final String status = rentalData['status'] ?? "Pending";
              final String paymentMethod = rentalData['paymentMethod'] ?? "N/A";

              // For date/time fields
              final String rentalDate = rentalData['rentalDate'] ?? "N/A";
              final String pickupDate = rentalData['pickupDate'] ?? "N/A";
              final String returnDate = rentalData['returnDate'] ?? "N/A";

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
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Product Name & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₱${productPrice.toStringAsFixed(2)} / day",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Status & Chat Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: status == "Pending"
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          // Chat button
                          IconButton(
                            onPressed: () =>
                                _openChatWithAdmin(rentalId, rentalData),
                            icon: const Icon(
                              Icons.chat,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Pickup & Return Dates
                      Text(
                        "Pickup Date: $pickupDate",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "Return Date: $returnDate",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      // Payment & Rental Date
                      Text(
                        "Payment Method: $paymentMethod",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Rented On: $rentalDate",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
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

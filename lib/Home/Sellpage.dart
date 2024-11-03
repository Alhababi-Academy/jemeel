import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class ClothesForSellPage extends StatefulWidget {
  const ClothesForSellPage({super.key});

  @override
  _ClothesForSellPageState createState() => _ClothesForSellPageState();
}

class _ClothesForSellPageState extends State<ClothesForSellPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to fetch clothes for sell from Firestore
  Stream<QuerySnapshot> _fetchClothesForSell() {
    return _firestore.collection("clothes").snapshots();
  }

  // Placeholder function for handling the "Buy" action
  void _handleBuy(String productId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Buying product with ID: $productId")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothes for Sell'),
        centerTitle: true,
        backgroundColor: Jemeel.primraryColor,
      ),
      drawer: Drawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchClothesForSell(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading products"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No clothes available for sell"));
          }

          // Display each product in a list view
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return _buildProductCard(data, doc.id);
            }).toList(),
          );
        },
      ),
    );
  }

  // Widget to build each product card
  Widget _buildProductCard(Map<String, dynamic> productData, String productId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            productData['images'] != null && productData['images'].isNotEmpty
                ? Image.network(
                    productData['images'][0],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  )
                : const Icon(Icons.image, size: 150, color: Colors.grey),
            const SizedBox(height: 10),

            // Product name
            Text(
              productData['name'] ?? 'No name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Jemeel.textColor,
              ),
            ),
            const SizedBox(height: 5),

            // Product price
            Text(
              'Price: \$${productData['price']?.toStringAsFixed(2) ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),

            // Product details
            Text(
              productData['details'] ?? 'No details available',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),

            // Buy button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _handleBuy(productId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Jemeel.buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Buy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

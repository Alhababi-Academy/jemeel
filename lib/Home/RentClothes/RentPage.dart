import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Home/RentClothes/ProductDetailesRent.dart';
import 'package:jemeel/config/config.dart';
import 'package:jemeel/widgets/UserDrawer.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  _RentPageState createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to fetch rentable clothes
  Stream<QuerySnapshot> _fetchClothesForRent() {
    return _firestore.collection("rentalClothes").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Clothes for Rent'),
        centerTitle: true,
        backgroundColor: Crown.primraryColor,
      ),
      drawer: const UserDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchClothesForRent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading products"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No clothes available for rent"));
          }

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

  Widget _buildProductCard(Map<String, dynamic> productData, String productId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsRent(productId: productId),
          ),
        );
      },
      child: Card(
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
              Text(
                productData['name'] ?? 'No name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Crown.primraryColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '\$${productData['rentalPrice']?.toStringAsFixed(2) ?? 'N/A'} / day',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                productData['details'] ?? 'No details available',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

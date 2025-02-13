// all_rental_clothes_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/Home/Clothes/RentalClothes/EditRentalClothesPage.dart';
import 'package:jemeel/Admin/Home/Clothes/RentalClothes/UploadClothesForRent.dart';
import 'package:jemeel/config/config.dart';
import 'package:shimmer/shimmer.dart';

class AllRentalClothesPage extends StatefulWidget {
  const AllRentalClothesPage({super.key});

  @override
  _AllRentalClothesPageState createState() => _AllRentalClothesPageState();
}

class _AllRentalClothesPageState extends State<AllRentalClothesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Clothes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Crown.primraryColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UploadRentalClothesPage()),
        ),
        backgroundColor: Crown.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('rentalClothes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final clothing = ClothingItem.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id);
                return _buildRentalClothingCard(clothing);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRentalClothingCard(ClothingItem clothing) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        clothing.images.isNotEmpty ? clothing.images[0] : '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.error)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '₱${clothing.rentalPrice.toStringAsFixed(2)}/day',
                              style: TextStyle(
                                color: Crown.primraryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clothing.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (clothing.brand.isNotEmpty)
                      Text(clothing.brand,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Crown.primraryColor, size: 20),
                        onPressed: () => _editRentalClothes(clothing),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () => _confirmDelete(clothing),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Add _buildShimmerLoader, _buildEmptyState, _confirmDelete, _deleteClothes
  // from previous implementation, updating collection reference to 'rentalClothes'

  void _confirmDelete(ClothingItem clothing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClothes(clothing);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClothes(ClothingItem clothing) async {
    try {
      // Delete images from storage
      for (String url in clothing.images) {
        await _storage.refFromURL(url).delete();
      }

      // Delete document from Firestore
      await _firestore.collection('rentalClothes').doc(clothing.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted successfully'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deletion failed: ${e.toString()}'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _editRentalClothes(ClothingItem clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRentalClothesPage(clothingItem: clothing),
      ),
    );
  }
}

class ClothingItem {
  final String id;
  final String name;
  final String brand;
  final double rentalPrice;
  final String rentalDuration;
  final String details;
  final List<String> images;
  final String status;
  final DateTime uploadTime; // Change from String to DateTime

  ClothingItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.rentalPrice,
    required this.rentalDuration,
    required this.details,
    required this.images,
    required this.status,
    required this.uploadTime,
  });

  factory ClothingItem.fromMap(Map<String, dynamic> map, String id) {
    return ClothingItem(
      id: id,
      name: map['name'] ?? 'No Name',
      brand: map['brand'] ?? '',
      rentalPrice: (map['rentalPrice'] ?? 0.0).toDouble(),
      rentalDuration: map['rentalDuration'] ?? '',
      details: map['details'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      status: map['status'] ?? 'Available',
      uploadTime:
          (map['uploadTime'] as Timestamp).toDate(), // Convert Timestamp
    );
  }
}

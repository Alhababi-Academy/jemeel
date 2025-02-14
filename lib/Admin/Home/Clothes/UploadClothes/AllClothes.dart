import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/Home/Clothes/UploadClothes/EditUploadClothes.dart';
import 'package:jemeel/Admin/Home/Clothes/UploadClothes/UploadClothes.dart';
import 'package:jemeel/config/config.dart';
import 'package:shimmer/shimmer.dart';

class AllClothesPage extends StatefulWidget {
  const AllClothesPage({super.key});

  @override
  _AllClothesPageState createState() => _AllClothesPageState();
}

class _AllClothesPageState extends State<AllClothesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        title: const Text('All Clothes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Crown.primraryColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadClothesPage()),
        ),
        backgroundColor: Crown.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('clothes')
              .orderBy('uploadTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoader();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No clothes available',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 18)),
                  ],
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7, // Adjusted aspect ratio
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var clothing = ClothingItem.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id);
                return _buildClothingCard(clothing);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildClothingCard(ClothingItem clothing) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(12.0),
          height: 320, // Fixed height constraint
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5, // 60% of space for image
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
                        child: Text(
                          '₱${clothing.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Crown.primraryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 1, // 30% of space for text
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clothing.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
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
                        onPressed: () => _editClothes(clothing),
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () => _confirmDelete(clothing),
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
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

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  void _editClothes(ClothingItem clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClothesPage(clothingItem: clothing),
      ),
    ).then((_) {
      // Optional: Add any refresh logic if needed
      setState(() {}); // This will refresh the list after editing
    });
  }

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
      for (String url in clothing.images) {
        await _storage.refFromURL(url).delete();
      }
      await _firestore.collection('clothes').doc(clothing.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Item deleted successfully',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
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
}

class ClothingItem {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String details;
  final List<String> images;
  final String uploadTime;

  ClothingItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.details,
    required this.images,
    required this.uploadTime,
  });

  factory ClothingItem.fromMap(Map<String, dynamic> map, String id) {
    return ClothingItem(
      id: id,
      name: map['name'] ?? 'No Name',
      brand: map['brand'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      details: map['details'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      uploadTime: map['uploadTime'] ?? '',
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedSize;
  Map<String, dynamic>? selectedAddress;
  String selectedPaymentMethod = "COD";
  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchUserAddresses();
  }

  // Fetch product details by ID
  Future<DocumentSnapshot> _fetchProductDetails() {
    return _firestore.collection("clothes").doc(widget.productId).get();
  }

  // Fetch user's saved addresses
  Future<void> _fetchUserAddresses() async {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(userId).get();
      setState(() {
        addresses = List<Map<String, dynamic>>.from(
            userDoc['addresses'] ?? []); // Fetch all addresses
      });
    }
  }

  // Handle booking action
  Future<void> _handleBuy(DocumentSnapshot productData) async {
    if (selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a size before purchasing."),
          backgroundColor: Crown.errorColor,
        ),
      );
      return;
    }

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select an address."),
          backgroundColor: Crown.errorColor,
        ),
      );
      return;
    }

    // Create booking data
    Map<String, dynamic> bookingData = {
      "userId": _auth.currentUser?.uid ?? "Unknown",
      "userEmail": _auth.currentUser?.email ?? "Unknown",
      "productId": widget.productId,
      "productImage": productData['images'][0],
      "productName": productData["name"] ?? "Unknown",
      "productPrice": productData["price"] ?? 0,
      "selectedSize": selectedSize,
      "address": selectedAddress,
      "deliveryPerson": "", // Initially empty
      "paymentMethod": selectedPaymentMethod,
      "status": "Pending",
      "bookingDate": DateTime.now().toIso8601String(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Save booking to Firestore
    await _firestore.collection("bookings").add(bookingData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Booking saved successfully."),
        backgroundColor: Crown.successColor,
      ),
    );

    Navigator.pop(context); // Navigate back after successful booking
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Crown.backgroundColor,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Crown.primraryColor,
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading product details",
                style: TextStyle(color: Crown.errorColor),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "Product not found",
                style: TextStyle(color: Crown.textSecondaryColor),
              ),
            );
          }

          var productData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product images
                productData['images'] != null &&
                        productData['images'].isNotEmpty
                    ? SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productData['images'].length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Image.network(
                                productData['images'][index],
                                height: 250,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error,
                                      color: Crown.errorColor, size: 150);
                                },
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.image, size: 250, color: Crown.secondaryColor),
                const SizedBox(height: 20),

                // Product name
                Text(
                  productData['name'] ?? 'No name',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Crown.textColor,
                  ),
                ),
                const SizedBox(height: 10),

                // Product brand
                Text(
                  'Brand: ${productData['brand'] ?? 'N/A'}',
                  style:
                      TextStyle(fontSize: 16, color: Crown.textSecondaryColor),
                ),
                const SizedBox(height: 10),

                // Product price
                Text(
                  '\$${productData['price']?.toString() ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Crown.primraryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Product details
                Text(
                  productData['details'] ?? 'No details available',
                  style:
                      TextStyle(fontSize: 16, color: Crown.textSecondaryColor),
                ),
                const SizedBox(height: 20),

                // Available sizes
                Text(
                  'Choose Size:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Crown.textColor),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: (productData['sizes'] as List<dynamic>?)
                          ?.map((size) => ChoiceChip(
                                label: Text(size.toString()),
                                selected: selectedSize == size,
                                selectedColor:
                                    Crown.primraryColor.withOpacity(0.2),
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: selectedSize == size
                                      ? Crown.primraryColor
                                      : Crown.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (isSelected) {
                                  setState(() {
                                    selectedSize =
                                        isSelected ? size.toString() : null;
                                  });
                                },
                              ))
                          .toList() ??
                      [
                        Text("No sizes available",
                            style: TextStyle(color: Crown.textSecondaryColor))
                      ],
                ),
                const SizedBox(height: 20),

                // Select address
                Text(
                  'Choose Address:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Crown.textColor),
                ),
                const SizedBox(height: 10),
                addresses.isEmpty
                    ? const Text(
                        "No addresses available. Please add one in your profile.")
                    : Column(
                        children: addresses.map((address) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(address['name'] ?? "No Name"),
                              subtitle: Text(
                                  "${address['addressLine']}, ${address['city']} - ${address['zipCode']}"),
                              trailing: Radio<Map<String, dynamic>>(
                                value: address,
                                groupValue: selectedAddress,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAddress = value;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),

                // Payment methods
                Text(
                  'Payment Method:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Crown.textColor),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text("Gcash (Not available)"),
                        leading: Radio<String>(
                          value: "Gcash",
                          groupValue: selectedPaymentMethod,
                          onChanged: null, // Disabled for now
                        ),
                      ),
                      ListTile(
                        title: const Text("Paymaya (Not available)"),
                        leading: Radio<String>(
                          value: "Paymaya",
                          groupValue: selectedPaymentMethod,
                          onChanged: null, // Disabled for now
                        ),
                      ),
                      ListTile(
                        title: const Text("Cash on Delivery (COD)"),
                        leading: Radio<String>(
                          value: "COD",
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Buy button
                Center(
                  child: ElevatedButton(
                    onPressed: () => _handleBuy(snapshot.data!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Crown.buttonColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

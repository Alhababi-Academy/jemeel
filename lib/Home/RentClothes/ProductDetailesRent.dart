import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ProductDetailsRent extends StatefulWidget {
  final String productId;
  const ProductDetailsRent({super.key, required this.productId});

  @override
  _ProductDetailsRentState createState() => _ProductDetailsRentState();
}

class _ProductDetailsRentState extends State<ProductDetailsRent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _selectedPickUpDate;
  DateTime? _selectedReturnDate;
  String selectedPaymentMethod = "COD"; // Default to COD

  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchUserAddresses();
  }

  // Fetch product details from Firestore
  Future<DocumentSnapshot> _fetchProductDetails() {
    return _firestore.collection("rentalClothes").doc(widget.productId).get();
  }

  // Fetch user addresses
  Future<void> _fetchUserAddresses() async {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(userId).get();
      setState(() {
        addresses = List<Map<String, dynamic>>.from(userDoc['addresses'] ?? []);
      });
    }
  }

  // Show the date range picker
  void _pickDateRange(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Rental Date Range'),
          content: SizedBox(
            height: 400,
            width: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: _onSelectionChanged,
              showActionButtons: true,
              onSubmit: (Object? value) {
                if (value is PickerDateRange) {
                  setState(() {
                    _selectedPickUpDate = value.startDate;
                    _selectedReturnDate = value.endDate;
                  });
                }
                Navigator.pop(context);
              },
              onCancel: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  // Handle the date range selection change
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      setState(() {
        _selectedPickUpDate = args.value.startDate;
        _selectedReturnDate = args.value.endDate;
      });
    }
  }

  // Handle rent action
  Future<void> _handleRent(DocumentSnapshot productData) async {
    if (_selectedPickUpDate == null || _selectedReturnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a rental date range."),
          backgroundColor: Crown.errorColor,
        ),
      );
      return;
    }

    // Create rental data
    Map<String, dynamic> rentalData = {
      "userId": _auth.currentUser?.uid ?? "Unknown",
      "userEmail": _auth.currentUser?.email ?? "Unknown",
      "productId": widget.productId,
      "productImage": productData['images'][0],
      "productName": productData["name"] ?? "Unknown",
      "productPrice": productData["rentalPrice"] ?? 0,
      "pickupDate": _selectedPickUpDate?.toIso8601String(),
      "returnDate": _selectedReturnDate?.toIso8601String(),
      "paymentMethod": selectedPaymentMethod, // ✅ Include payment method
      "status": "Pending",
      "rentalDate": DateTime.now().toIso8601String(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Save rental data to Firestore
    await _firestore.collection("rentedClothes").add(rentalData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Rental request submitted successfully."),
        backgroundColor: Crown.successColor,
      ),
    );

    Navigator.pop(context); // Navigate back after successful submission
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Crown.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Product details
                    Text(
                      productData['name'] ?? 'No name',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Crown.textColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${productData['rentalPrice']?.toString() ?? 'N/A'} / day',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Crown.primraryColor.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Dates
                    Text(
                      "From: ${_selectedPickUpDate.toString().split(' ')[0]}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Crown.primraryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "To: ${_selectedReturnDate.toString().split(' ')[0]}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Crown.primraryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Date picker button
                    ElevatedButton(
                      onPressed: () => _pickDateRange(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Crown.buttonColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Pick Rental Dates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Address selection
                    const Text(
                      'Pick Up Location:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      productData['pickupLocation'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Payment Type:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // Payment Method Selection
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Gcash (Not available)"),
                            leading: Radio<String>(
                              value: "Gcash",
                              groupValue: selectedPaymentMethod,
                              onChanged: null, // Disabled
                            ),
                          ),
                          ListTile(
                            title: const Text("Paymaya (Not available)"),
                            leading: Radio<String>(
                              value: "Paymaya",
                              groupValue: selectedPaymentMethod,
                              onChanged: null, // Disabled
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
                  ],
                ),

                // Rent button
                Center(
                  child: ElevatedButton(
                    onPressed: () => _handleRent(snapshot.data!),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'Rent Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime? _selectedPickUpDate;
  DateTime? _selectedReturnDate;

  // Fetch product details from Firestore
  Future<DocumentSnapshot> _fetchProductDetails() {
    return _firestore.collection("rentalClothes").doc(widget.productId).get();
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
  void _handleRent() {
    if (_selectedPickUpDate == null || _selectedReturnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a rental date range."),
          backgroundColor: Crown.errorColor,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Renting product from ${DateFormat('yMMMd').format(_selectedPickUpDate!)} to ${DateFormat('yMMMd').format(_selectedReturnDate!)}",
        ),
        backgroundColor: Crown.successColor,
      ),
    );
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
                                  return Icon(
                                    Icons.error,
                                    color: Crown.errorColor,
                                    size: 150,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.image, size: 250, color: Crown.secondaryColor),
                const SizedBox(height: 20),
                Text(
                  productData['name'] ?? 'No name',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Crown.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Brand: ${productData['brand'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Crown.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${productData['price']?.toString() ?? 'N/A'} / day',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Crown.primraryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  productData['details'] ?? 'No details available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Crown.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Rental Date Range:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Crown.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickDateRange(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Crown.buttonColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      child: const Text(
                        'Pick Date Range',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        _selectedPickUpDate != null &&
                                _selectedReturnDate != null
                            ? 'From: ${DateFormat('yMMMd').format(_selectedPickUpDate!)}\nTo: ${DateFormat('yMMMd').format(_selectedReturnDate!)}'
                            : 'No date range selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: Crown.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleRent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Crown.buttonColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Rent Now',
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

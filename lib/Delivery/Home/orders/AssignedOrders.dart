import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jemeel/config/config.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _locationUpdateTimer;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates(); // Start updating the driver's location
  }

  @override
  void dispose() {
    _locationUpdateTimer
        ?.cancel(); // Stop updating location when the widget is disposed
    super.dispose();
  }

  // Start updating the driver's location every 5 seconds
  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _updateDriverLocation(),
    );
  }

  // Update the driver's location in the `drivers` field in the database
  Future<void> _updateDriverLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _firestore.collection('orders').doc(widget.orderId).update({
        'drivers.latitude': position.latitude,
        'drivers.longitude': position.longitude,
        'drivers.lastLocationUpdate': FieldValue.serverTimestamp(),
      });

      print(
          "Driver location updated: (${position.latitude}, ${position.longitude})");
    } catch (e) {
      print("Failed to update driver location: $e");
    }
  }

  // Update the order status in the Firestore database
  Future<void> _updateOrderStatus(String status) async {
    try {
      await _firestore.collection('orders').doc(widget.orderId).update({
        'status': status,
      });
      print("Order status updated to: $status");
    } catch (e) {
      print("Failed to update order status: $e");
    }
  }

  // Fetch order details by orderId
  Stream<DocumentSnapshot> _fetchOrderDetails(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  // Open Google Maps to view the customer's location
  void _openCustomerLocation(double? latitude, double? longitude) async {
    if (latitude != null &&
        longitude != null &&
        latitude != 0.0 &&
        longitude != 0.0) {
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw "Could not open Google Maps.";
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer location not available.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Crown.primraryColor,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fetchOrderDetails(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading order details"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found."));
          }

          var order = snapshot.data!.data() as Map<String, dynamic>;
          var drivers = order['drivers'] ?? {};
          double? driverLat = drivers['latitude'];
          double? driverLong = drivers['longitude'];
          String? currentStatus = order['status'];

          var address = order['address'] ?? {};
          double? customerLat = address['latitude'];
          double? customerLong = address['longitude'];

          // Initialize the selected status with the current status from Firestore
          _selectedStatus ??= currentStatus;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      order['productImage'] ??
                          "https://via.placeholder.com/150",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Details
                  Text(
                    order['productName'] ?? "Unknown Product",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Price: ₱${order['productPrice'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    "Current Status:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentStatus ?? "N/A",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Status Dropdown
                  const Text(
                    "Update Status:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: "Pending",
                        child: Text("Pending"),
                      ),
                      DropdownMenuItem(
                        value: "Out for Delivery",
                        child: Text("Out for Delivery"),
                      ),
                      DropdownMenuItem(
                        value: "On the Way",
                        child: Text("On the Way"),
                      ),
                      DropdownMenuItem(
                        value: "Delivered",
                        child: Text("Delivered"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedStatus != null) {
                        _updateOrderStatus(_selectedStatus!);
                      }
                    },
                    child: const Text("Save Status"),
                  ),
                  const SizedBox(height: 20),

                  // Driver Location
                  const Text(
                    "Driver Location (Customer can track this):",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (driverLat != null && driverLong != null)
                    Text(
                      "Latitude: $driverLat, Longitude: $driverLong",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 20),

                  // Customer Location
                  const Text(
                    "Customer Location (For Driver Navigation):",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (customerLat != null && customerLong != null)
                    Text(
                      "Latitude: $customerLat, Longitude: $customerLong",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _openCustomerLocation(customerLat, customerLong),
                    icon: const Icon(Icons.location_on),
                    label: const Text("View Customer on Map"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Method
                  const Text(
                    "Payment Method:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order['paymentMethod'] ?? "N/A",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

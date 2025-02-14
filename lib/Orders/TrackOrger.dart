import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class DriverTrackingPage extends StatefulWidget {
  final String orderId;

  const DriverTrackingPage({super.key, required this.orderId});

  @override
  State<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends State<DriverTrackingPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _driverLocation;
  LatLng? _customerLocation;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _fetchCustomerLocation();
    _listenToDriverLocation();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Denied"),
          content: const Text(
              "Location permission is required to display the map. Please enable it in your device settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _fetchCustomerLocation() async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (orderDoc.exists) {
        final data = orderDoc.data();
        if (data != null && data['address'] != null) {
          final customerData = data['address'];
          if (customerData['latitude'] != null &&
              customerData['longitude'] != null) {
            setState(() {
              _customerLocation = LatLng(
                customerData['latitude'] as double,
                customerData['longitude'] as double,
              );
            });
            _addCustomerMarker();
            _updatePolyline();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching customer location: $e");
    }
  }

  void _listenToDriverLocation() {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        if (data != null && data['drivers'] != null) {
          final driverData = data['drivers'];
          if (driverData['latitude'] != null &&
              driverData['longitude'] != null) {
            setState(() {
              _driverLocation = LatLng(
                driverData['latitude'] as double,
                driverData['longitude'] as double,
              );
            });
            _addDriverMarker();
            _updatePolyline();
            _moveCameraToDriver();
          }
        }
      }
    });
  }

  void _addDriverMarker() {
    if (_driverLocation != null) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == "driver");
        _markers.add(
          Marker(
            markerId: const MarkerId("driver"),
            position: _driverLocation!,
            infoWindow: const InfoWindow(title: "Driver's Location"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
    }
  }

  void _addCustomerMarker() {
    if (_customerLocation != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId("customer"),
            position: _customerLocation!,
            infoWindow: const InfoWindow(title: "Customer's Location"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      });
    }
  }

  Future<void> _updatePolyline() async {
    if (_driverLocation != null && _customerLocation != null) {
      final directions =
          await _getDirections(_driverLocation!, _customerLocation!);
      if (directions != null) {
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: directions,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      }
    }
  }

  Future<List<LatLng>?> _getDirections(
      LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyBpLzaDvyWfvVvxD9xO3fM1i5FfCbjJ9nE';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> points = data['routes'][0]['legs'][0]['steps'];

      List<LatLng> polylinePoints = [];
      for (var point in points) {
        polylinePoints.add(LatLng(
          point['start_location']['lat'],
          point['start_location']['lng'],
        ));
        polylinePoints.add(LatLng(
          point['end_location']['lat'],
          point['end_location']['lng'],
        ));
      }

      return polylinePoints;
    } else {
      return null;
    }
  }

  void _moveCameraToDriver() {
    if (_mapController != null && _driverLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_driverLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Driver Tracking",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.4219983, -122.084), // Default location
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _mapController = controller;
            _controller.complete(controller);
          }
        },
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

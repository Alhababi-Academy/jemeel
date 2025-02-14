import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Delivery/Home/orders/OrdersListPage.dart';

import 'package:jemeel/config/config.dart';
import 'package:jemeel/widgets/StartPage.dart';

class DriverHomePage extends StatelessWidget {
  String? title;
  DriverHomePage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    String fullName = Crown.sharedPreferences!.getString(Crown.name).toString();

    return Scaffold(
      backgroundColor: Colors.white, // White background for a cleaner look
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          fullName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Crown.primraryColor, // Consistent app bar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDriverCard(
                title: "Assigned Orders",
                icon: Icons.assignment,
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (_) => const OrdersListPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildDriverCard(
                title: "Previous Orders",
                icon: Icons.history,
                onTap: () {
                  // Route route = MaterialPageRoute(
                  //     builder: (_) => const PreviousOrdersPage());
                  // Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildDriverCard(
                title: "Logout",
                icon: Icons.logout,
                onTap: () async {
                  await FirebaseAuth.instance.signOut().then((value) {
                    Route route =
                        MaterialPageRoute(builder: (_) => const StartPage());
                    Navigator.push(context, route);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method to build the driver cards
  Widget buildDriverCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5, // Subtle shadow for better aesthetics
        color: Crown.primraryColor, // Card background color
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white), // Icon color
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white, // White text for contrast
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

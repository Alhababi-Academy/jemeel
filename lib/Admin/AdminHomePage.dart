import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/AdminChats.dart';
import 'package:jemeel/Admin/Home/AllUsers.dart';
import 'package:jemeel/Admin/Home/Clothes/RentalClothes/AllRentalClothesPage.dart';
import 'package:jemeel/Admin/Home/Clothes/UploadClothes/AllClothes.dart';
import 'package:jemeel/Admin/Home/Drivers/allDrivers.dart';
import 'package:jemeel/Admin/Home/orders.dart';
import 'package:jemeel/config/config.dart';
import 'package:jemeel/widgets/StartPage.dart';

class AdminHomePage extends StatelessWidget {
  String? title;
  AdminHomePage({super.key, this.title});

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
              buildAdminCard(
                title: "Upload Clothes For Sell",
                icon: Icons.cloud_upload,
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (_) => const AllClothesPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildAdminCard(
                title: "Upload Clothes For Rent",
                icon: Icons.cloud_upload,
                onTap: () {
                  Route route = MaterialPageRoute(
                      builder: (_) => const AllRentalClothesPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildAdminCard(
                title: "Orders",
                icon: Icons.shopping_cart,
                onTap: () {
                  Route route = MaterialPageRoute(
                      builder: (_) => const AdminOrdersPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildAdminCard(
                title: "All Users",
                icon: Icons.people,
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (_) => const AllUsersPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildAdminCard(
                title: "All Drivers",
                icon: Icons.delivery_dining,
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (_) => const AllDriversPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildAdminCard(
                title: "Chat",
                icon: Icons.chat,
                onTap: () {
                  Route route =
                      MaterialPageRoute(builder: (_) => const AdminChatsPage());
                  Navigator.push(context, route);
                },
              ),
              const SizedBox(height: 10),
              buildAdminCard(
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

  // Reusable method to build the admin cards
  Widget buildAdminCard({
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

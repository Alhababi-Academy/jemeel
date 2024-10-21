import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/Home/AllUsers.dart';
import 'package:jemeel/Admin/Home/UploadClothes.dart';
import 'package:jemeel/config/config.dart';
import 'package:jemeel/widgets/StartPage.dart';

class AdminHomePage extends StatelessWidget {
  String? title;
  AdminHomePage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    String fullName =
        Jemeel.sharedPreferences!.getString(Jemeel.name).toString();

    return Scaffold(
      backgroundColor: Colors.white, // White background for a cleaner look
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          fullName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Jemeel.primraryColor, // Consistent app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildAdminCard(
              title: "Upload Clothes",
              icon: Icons.cloud_upload,
              onTap: () {
                Route route = MaterialPageRoute(
                    builder: (_) => const UploadClothesPage());
                Navigator.push(context, route);
              },
            ),
            const SizedBox(height: 20),
            buildAdminCard(
              title: "Orders",
              icon: Icons.shopping_cart,
              onTap: () {
                // Navigate to orders page
              },
            ),
            const SizedBox(height: 20),
            buildAdminCard(
              title: "All Users",
              icon: Icons.people,
              onTap: () {
                Route route =
                    MaterialPageRoute(builder: (_) => const AllUsersPage());
                Navigator.push(context, route);
              },
            ),
            const SizedBox(height: 20),
            buildAdminCard(
              title: "Feedback & Complaints",
              icon: Icons.feedback,
              onTap: () {
                // Navigate to feedback and complaints page
              },
            ),
            const SizedBox(height: 20),
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
        color: Jemeel.primraryColor, // Card background color
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

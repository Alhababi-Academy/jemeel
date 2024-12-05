import 'package:flutter/material.dart';
import 'package:jemeel/Authentication/UserLogin.dart';
import 'package:jemeel/config/config.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Clean white background for a shop-like feel
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to CROWN!',
                  style: TextStyle(
                    fontSize: 32,
                    color: Crown.primraryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Tagline
                Text(
                  'Shop Pre-Loved Clothes\nFind Unique Pieces!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Crown.secondaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    'images/logo2.png',
                    fit: BoxFit.cover,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 40),

                // Shop Now Button
                ElevatedButton(
                  onPressed: () {
                    Route route =
                        MaterialPageRoute(builder: (_) => const UserLogin());
                    Navigator.push(context, route);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Crown.primraryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation for Account Login
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                Text(
                  "Have an account? ",
                  style: TextStyle(
                    color: Crown.secondaryColor,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Route route =
                        MaterialPageRoute(builder: (_) => const UserLogin());
                    Navigator.push(context, route);
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Crown.primraryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

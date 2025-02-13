import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jemeel/Home/About.dart';
import 'package:jemeel/Home/Addresses/addAddress.dart';
import 'package:jemeel/Home/chats/AllChats.dart';
import 'package:jemeel/config/config.dart';
import 'package:jemeel/widgets/StartPage.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Route route = MaterialPageRoute(builder: (_) => const StartPage());
      Navigator.push(context, route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error signing out. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Crown.primraryColor,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Home
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('About'),
            onTap: () {
              Route route =
                  MaterialPageRoute(builder: (_) => const AboutPage());
              Navigator.push(context, route);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_history),
            title: const Text('Address'),
            onTap: () {
              Route route =
                  MaterialPageRoute(builder: (_) => const ManageAddressPage());
              Navigator.push(context, route);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('All Chats'),
            onTap: () {
              Route route = MaterialPageRoute(builder: (_) => const AllChats());
              Navigator.push(context, route);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              _signOut(context);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Jemeel.primraryColor,
        title: const Text(
          'All Users',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("type", isNotEqualTo: "admin")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  leading: const Icon(Icons.person, size: 40),
                  title: Text(
                    user['fullName'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(user['email'] ?? 'No Email'),
                  trailing: IconButton(
                    icon: Icon(Icons.info, color: Jemeel.primraryColor),
                    onPressed: () {
                      _viewMoreDetails(context, user);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Method to show more details about the user in a dialog
  void _viewMoreDetails(BuildContext context, DocumentSnapshot user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user['fullName'] ?? 'User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email: ${user['email'] ?? 'Not available'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Phone Number: ${user['phonenumber'] ?? 'Not available'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Address: ${user['address'] ?? 'Not available'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "User Type: ${user['type'] ?? 'Not available'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Registered Time: ${(user['RegistredTime'] as Timestamp).toDate()}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Close",
                style: TextStyle(color: Jemeel.primraryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

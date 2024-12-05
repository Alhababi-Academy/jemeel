import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Crown.primraryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Crown',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Crown.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Crown is an innovative platform designed to make buying and selling clothes easier. With features like image uploads, size selection, and real-time updates, our app provides a seamless experience for users looking to explore and share unique clothing styles.',
              style: TextStyle(fontSize: 16, color: Crown.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Crown.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: support@crownapp.com',
              style: TextStyle(fontSize: 16, color: Crown.textSecondaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: +123 456 7890',
              style: TextStyle(fontSize: 16, color: Crown.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'App Version',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Crown.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Crown.textSecondaryColor),
            ),
            const Spacer(),
            Center(
              child: Text(
                '© 2024 Crown, Inc. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Crown.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

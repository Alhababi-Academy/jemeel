import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Crown {
  // Define the new color palette
  static Color primraryColor =
      const Color(0xffFF6F61); // Soft Coral (Main buttons and accents)
  static Color secondaryColor =
      const Color(0xff4A90E2); // Cool Blue (Secondary elements)
  static Color backgroundColor =
      const Color(0xffF5F5F5); // Light Gray (Background)
  static Color textColor = const Color(0xff333333); // Dark Gray (Primary text)
  static Color textSecondaryColor =
      const Color(0xff999999); // Light Gray (Secondary text)
  static Color errorColor =
      const Color(0xffFF3B30); // Bright Red (Error messages)
  static Color successColor =
      const Color(0xff4CAF50); // Green (Success indicators)
  static Color buttonColor = primraryColor; // Use the primary color for buttons
  static Color inputBorderColor =
      const Color(0xffC8D2D3); // Light border color for inputs

  // Shared Preferences for storing local data
  static SharedPreferences? sharedPreferences;
  static FirebaseAuth? firebaseAuth;
  static FirebaseFirestore? firebaseFirestore;
  static FirebaseStorage? firebaseStorage;

  static String name = "";

  // Add your Firebase API key here
  static String apiKey = "AIzaSyBpLzaDvyWfvVvxD9xO3fM1i5FfCbjJ9nE";
}

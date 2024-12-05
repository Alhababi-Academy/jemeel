import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/AdminHomePage.dart';
import 'package:jemeel/Authentication/UserRegisterPage.dart';
import 'package:jemeel/Authentication/resetPassword.dart';
import 'package:jemeel/DialogBox/errorDialog.dart';
import 'package:jemeel/DialogBox/loadingDialog.dart';
import 'package:jemeel/Home/BottomNavPage.dart';
import 'package:jemeel/config/config.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Crown.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Crown.primraryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("images/logo2.png", height: 300), // App logo
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: TextStyle(
                        color: Crown.textColor,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller: _emailTextEditingController,
                        cursorColor: Colors.black, // Set cursor color to black
                        style: const TextStyle(
                          color: Colors.black, // Set input text color to black
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(
                                0.4), // Hint text color with 40% opacity
                          ),
                          hintText: "example@gmail.com",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Crown
                                  .primraryColor, // Border color when focused
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Crown.textColor.withOpacity(
                                  0.5), // Border color when not focused
                              width: 1,
                            ),
                          ),
                          prefixIcon: Icon(Icons.email,
                              color: Crown.primraryColor), // Email icon color
                        ),
                      ),
                    ),
                    Text(
                      "Password",
                      style: TextStyle(
                        color: Crown.textColor,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller: _passwordTextEditingController,
                        obscureText: true, // Hide the text for password
                        cursorColor: Colors.black, // Set cursor color to black
                        style: const TextStyle(
                          color: Colors.black, // Set input text color to black
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(
                                0.4), // Hint text color with 40% opacity
                          ),
                          hintText: "**********",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Crown
                                  .primraryColor, // Border color when focused
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Crown.textColor.withOpacity(
                                  0.5), // Border color when not focused
                              width: 1,
                            ),
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color: Crown.primraryColor), // Lock icon color
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    loginFunction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Crown.primraryColor,
                    minimumSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Route route =
                        MaterialPageRoute(builder: (_) => resetPassword());
                    Navigator.push(context, route);
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Crown.primraryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Route route = MaterialPageRoute(
                        builder: (_) => const UserRegisterPage());
                    Navigator.push(context, route);
                  },
                  child: Text(
                    "No Account? Create One",
                    style: TextStyle(color: Crown.primraryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginFunction() async {
    if (_emailTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text.isNotEmpty) {
      ValidatingData();
    } else {
      displayDialog("Please Fill up the information");
    }
  }

  displayDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return ErrorAlertDialog(
          message: msg,
        );
      },
    );
  }

  ValidatingData() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingAlertDialog(
            message: "Validating data, wait...",
          );
        });
    _login();
  }

  var currentUser;

  void _login() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user!.uid;
      saveUserInfo(currentUser);
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Please check your credentials.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  saveUserInfo(String userAuth) async {
    var results = await FirebaseFirestore.instance
        .collection("users")
        .doc(userAuth)
        .get();
    if (results.exists) {
      String userType = results['type'];
      String fullName = results['fullName'];
      Crown.sharedPreferences?.setString(Crown.name, fullName);
      if (userType == "admin") {
        Route route = MaterialPageRoute(builder: (context) => AdminHomePage());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      } else if (userType == "user") {
        Route route =
            MaterialPageRoute(builder: (context) => const BottomNavPage());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      }
    }
  }
}

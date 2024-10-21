import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/config/config.dart';


class AdminHomePage extends StatelessWidget {
  String? title;
  AdminHomePage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    String fullName =
        Jemeel.sharedPreferences!.getString(Jemeel.name).toString();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          fullName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Jemeel.primraryColor,
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                    
                    },
                    icon: const Icon(Icons.pin_drop,
                        color: Colors.white), // Set icon color to white
                    label: const Text(
                      'Upload Container',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Jemeel.buttonColor, // Set button background color
                      minimumSize:
                          const Size(300, 50), // Adjust size as per design
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Route route = MaterialPageRoute(
                      //     builder: (_) => ViewRewardGiversPage());
                      // Navigator.push(context, route);
                    },
                    icon: const Icon(Icons.card_giftcard,
                        color: Colors.white), // Set icon color to white
                    label: const Text(
                      'Reward Provider',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Jemeel.buttonColor, // Set button background color
                      minimumSize:
                          const Size(300, 50), // Adjust size as per design
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut().then((value) {
                        // Route route = MaterialPageRoute(
                        //     builder: (_) => LoginOrRegister());
                        // Navigator.pushAndRemoveUntil(
                        //     context, route, (route) => false);
                      });
                    },
                    icon: const Icon(Icons.logout,
                        color: Colors.white), // Set icon color to white
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Jemeel.buttonColor, // Set button background color
                      minimumSize:
                          const Size(300, 50), // Adjust size as per design
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

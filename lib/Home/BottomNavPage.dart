import 'package:flutter/material.dart';
import 'package:jemeel/Authentication/EditProfile.dart';
import 'package:jemeel/Home/RentClothes/RentPage.dart';
import 'package:jemeel/Home/SellingClothes/Sellpage.dart';
import 'package:jemeel/Orders/OrdersPage.dart';
import 'package:jemeel/Orders/RentPageOrders.dart';
import 'package:jemeel/config/config.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0;

  // Placeholder widgets for each tab
  final List<Widget> _pages = [
    const ClothesForSellPage(),
    const RentPage(),
    const OrdersPage(),
    const RentalOrdersPage(),
    const EditProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Crown.primraryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bento),
            label: 'Rent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Rent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

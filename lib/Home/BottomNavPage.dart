import 'package:flutter/material.dart';
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
    const Center(child: Text('Clothes for Sell Page Placeholder')),
    const Center(child: Text('Clothes for Rent Page Placeholder')),
    const Center(child: Text('Orders Page Placeholder')),
    const Center(child: Text('Profile Page Placeholder')),
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
        selectedItemColor: Jemeel.primraryColor,
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

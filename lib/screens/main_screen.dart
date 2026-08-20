import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'cart_screen.dart';
import 'rewards_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart'; // 👈 Profile Screen එක ඉම්පෝර්ට් කර ඇත (නම වෙනස් නම් මෙතැන වෙනස් කරන්න)

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 👈 _screens ලැයිස්තුවට ProfileScreen එක එකතු කර ඇත[cite: 2]
  final List<Widget> _screens = [
    ShopScreen(),
    CartScreen(), 
    RewardsScreen(),
    ChatScreen(),
    ProfileScreen(), // 👈 නව Profile ටැබ් එක
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // 👈 BottomNavigationBar එකට Profile අයිකන් සහ ලේබල් එක එකතු කර ඇත[cite: 2]
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // 👈 නව Profile අයිකනය
        ],
      ),
    );
  }
}
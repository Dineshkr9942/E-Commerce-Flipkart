import 'package:flutter/material.dart';
import 'Cart Page.dart';
import 'Category Page.dart';
import 'Home Page.dart';
import 'Orders History Page.dart';
import 'Profile Page.dart';

class flipkart extends StatefulWidget {
  const flipkart({super.key});

  @override
  State<flipkart> createState() => _flipkartState();
}

class _flipkartState extends State<flipkart> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    homePage(),      // 0
    categoryPage(),  // 1
    cartPage(),      // 2
    ordersPage(),    // 3
    profilePage(),   // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home",),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories",),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart",),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders",),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile",),
        ],
      ),
    );
  }
}

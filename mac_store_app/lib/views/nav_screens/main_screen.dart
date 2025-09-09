import 'package:flutter/material.dart';
import 'package:mac_store_app/views/nav_screens/account_screen.dart';
import 'package:mac_store_app/views/nav_screens/cart_screen.dart';
import 'package:mac_store_app/views/nav_screens/favorite_screen.dart';
import 'package:mac_store_app/views/nav_screens/home_screen.dart';
import 'package:mac_store_app/views/nav_screens/stories_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
} 

class _MainScreenState extends State<MainScreen> {
  int pageIndex = 0;
  final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    StoriesScreen(),
    CartScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/home.png", width: 25),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/love.png", width: 25),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/mart.png", width: 25),
            label: "Stories",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/cart.png", width: 25),
            label: "Cart ",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/user.png", width: 25),
            label: "Account",
          ),
        ],
      ),
      body: pages[pageIndex],
    );
  }
}

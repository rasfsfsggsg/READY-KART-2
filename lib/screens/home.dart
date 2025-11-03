import 'package:flutter/material.dart';
import 'package:ready_cart/screens/navigation/side_drawer.dart';
import '../pages/home_tab.dart';
import '../pages/search_tab.dart';
import '../pages/cart_tab.dart';
import '../pages/profile_tab.dart';
import '../pages/my_orders_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = const [
    HomeTab(),
    SearchTab(),
    CartTab(),
    MyOrdersTab(),
    ProfileScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      drawer: SideDrawer(scaffoldKey: _scaffoldKey),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0F1C), Color(0xFF14233A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.cyanAccent),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Ready Kart",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _navButton("Home", 0),
                _navButton("Search", 1),
                _navButton("Cart", 2),
                _navButton("Orders", 3),
                _navButton("Profile", 4),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),

      backgroundColor: const Color(0xFF0A0F1C),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _navButton(String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => _onNavTapped(index),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.cyanAccent : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

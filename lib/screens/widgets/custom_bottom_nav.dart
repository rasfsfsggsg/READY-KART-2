import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F1C), Color(0xFF14233A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white60,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: [
          _navItem(Icons.home, "Home", 0),
          _navItem(Icons.search, "Search", 1),
          _navItem(Icons.shopping_cart, "Cart", 2),
          _navItem(Icons.receipt_long, "My Orders", 3), // ✅ new item
          _navItem(Icons.person, "Profile", 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(icon, size: 26),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.cyanAccent, width: 2)),
        ),
        child: Icon(icon, size: 26, color: Colors.cyanAccent),
      ),
      label: label,
    );
  }
}

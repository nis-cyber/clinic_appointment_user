import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:healthapp/pages/home_page.dart';
// import 'package:healthapp/pages/appointment_page.dart';
// import 'package:healthapp/pages/profile_page.dart';
// import 'package:healthapp/pages/search_page.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final int selectedIndex;

  BottomNavBar({super.key, required this.onTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Appointments",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: "Discover",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: "Profile",
        ),
      ],
    );
  }
}

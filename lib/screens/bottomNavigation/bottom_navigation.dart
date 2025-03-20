import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/screens/feasibility/feasibility_screen.dart';
import 'package:loop/screens/following/following_screen.dart';
import 'package:loop/screens/home/home_screen.dart';
import 'package:loop/screens/summary/summary_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  static final List<Widget> _pages = [
    HomeScreen(),
    SummaryScreen(),
    FollowingScreen(),
    FeasibilityScreen(),
  ];

  static final List<String> _titles = [
    "Home",
    "Summary",
    "Following",
    "Feasibility",
  ];

  static final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.analytics_rounded,
    Icons.people_alt_rounded,
    Icons.assessment_rounded,
  ];

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      Fluttertoast.showToast(msg: "Press back again to exit");
      return false;
    }
    return true;
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Palette.themeColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 9),
          items: List.generate(_titles.length, (index) {
            return BottomNavigationBarItem(
              icon: Icon(_icons[index]),
              label: _titles[index],
            );
          }),
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

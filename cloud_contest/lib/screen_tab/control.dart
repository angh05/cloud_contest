import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'drug_info_tab.dart';
import 'setting_tab.dart';
import '/const/colors.dart';

class Control extends StatefulWidget {
  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<Control> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeTab(),
    DrugInfoTab(),
    SettingTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: mainColor,
        unselectedItemColor: secondColor,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '내 근처',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: '약 정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}

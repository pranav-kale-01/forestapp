import 'package:flutter/material.dart';
import 'package:forestapp/screens/User/ProfileScreen.dart';
import 'package:forestapp/widgets/exit_popup.dart';

import 'AddForestData.dart';
import 'ForestDataScreen.dart';
import 'HomeScreen.dart';

class HomeUser extends StatefulWidget {
  final String userEmail;

  const HomeUser({
    Key? key,
    required this.userEmail
  }) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      HomeScreen(
        changeIndex: _changeIndex,
      ),
      AddForestData(),
      ForestDataScreen(
        changeScreen: _changeIndex,
        userEmail: widget.userEmail,
      ),
      const ProfileScreen(),
    ];
  }

  void _changeIndex( int index ) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Add Forest',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco),
              label: 'Forest Data',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.black,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'Settings Screen',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:forestapp/screens/User/ProfileScreen.dart';
import 'package:forestapp/widgets/exit_popup.dart';

import 'AddForestData.dart';
import 'ForestDataScreen.dart';
import 'HomeScreen.dart';

class HomeUser extends StatefulWidget {
  final String userEmail;

  const HomeUser({Key? key, required this.userEmail}) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;
  late String _selectedConflict;
  late final List<Widget> _widgetOptions;
  bool _showNavBar = false;

  @override
  void initState() {
    super.initState();

    _selectedConflict = '';

    _widgetOptions = <Widget>[
      HomeScreen(
          changeIndex: _changeIndex,
          setConflict: (String conflict) {
            _selectedConflict = conflict;
          },
          showNavBar: (bool value) {
            setState(() {
              _showNavBar = value;
            });
          }),
      AddForestData(),
      ForestDataScreen(
        defaultFilterConflict: _selectedConflict,
        changeScreen: _changeIndex,
        userEmail: widget.userEmail,
      ),
      const ProfileScreen(),
    ];
  }

  void _changeIndex(int index) {
    if (_selectedConflict.isNotEmpty) {
      _widgetOptions[2] = ForestDataScreen(
        defaultFilterConflict: _selectedConflict,
        changeScreen: _changeIndex,
        userEmail: widget.userEmail,
      );
    } else {
      _widgetOptions[2] = ForestDataScreen(
        defaultFilterConflict: '',
        changeScreen: _changeIndex,
        userEmail: widget.userEmail,
      );
    }
    _selectedConflict = '';

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      if (_selectedConflict.isNotEmpty) {
        _widgetOptions[2] = ForestDataScreen(
          defaultFilterConflict: _selectedConflict,
          changeScreen: _changeIndex,
          userEmail: widget.userEmail,
        );
      } else {
        _widgetOptions[2] = ForestDataScreen(
          defaultFilterConflict: '',
          changeScreen: _changeIndex,
          userEmail: widget.userEmail,
        );
      }
      _selectedConflict = '';
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_selectedIndex == 0) {
          return showExitPopup(context);
        }
        _changeIndex(0);
        return false as Future<bool>;
      },
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: _showNavBar ? BottomNavigationBar(
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
        ) : SizedBox( height: 0,),
      ),
    );
  }
}
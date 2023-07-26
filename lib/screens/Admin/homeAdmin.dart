import 'package:flutter/material.dart';
import 'package:forestapp/screens/Admin/ForestDataScreen.dart';
import 'package:forestapp/screens/Admin/UserScreen.dart';

import '../../widgets/exit_popup.dart';
import 'HomeScreen.dart';
import 'MapScreen.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key}) : super(key: key);

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0;
  late Map<String,dynamic> _selectedConflict;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _selectedConflict = {};

    _widgetOptions = <Widget>[
      HomeScreen(
        changeIndex: _changeIndex,
        setConflict: (Map<String,dynamic> conflict) {
          _selectedConflict = conflict;
        }
      ),
      UserScreen(
        changeIndex: _changeIndex,
      ),
      ForestDataScreen(
        changeScreen: _changeIndex,
        defaultFilterConflict: _selectedConflict,
      ),
      MapScreen(
        latitude: 37.4220,
        longitude: -122.0841,
      ),
    ];
  }

  void _changeIndex( int index ) {
    if( _selectedConflict.isNotEmpty ) {
      print( _selectedConflict );
      _widgetOptions[2] = ForestDataScreen(
        defaultFilterConflict: _selectedConflict,
        changeScreen: _changeIndex,
      );
    }
    else {
      _widgetOptions[2] = ForestDataScreen(
        defaultFilterConflict: {},
        changeScreen: _changeIndex,
      );
    }
    _selectedConflict = {};

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    if( index == 2 ) {
      if( _selectedConflict.isNotEmpty ) {
        print('iof');
        _widgetOptions[2] = ForestDataScreen(
          defaultFilterConflict: _selectedConflict,
          changeScreen: _changeIndex,

        );
      }
      else {
        print('else');
        _widgetOptions[2] = ForestDataScreen(
          defaultFilterConflict: {},
          changeScreen: _changeIndex,

        );
      }
      _selectedConflict = {};
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if( _selectedIndex == 0 ) {
          return showExitPopup(context);
        }
        _changeIndex(0);
        return false as Future<bool>;
      },
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
              icon: Icon(Icons.person_sharp),
              label: 'Guard',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco),
              label: 'Forest Data',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Maps',
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


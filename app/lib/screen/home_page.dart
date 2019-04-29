import 'package:flutter/material.dart';
import 'profile.dart';
import 'home_list.dart';
import 'package:login/models/auth_response.dart';
import 'package:icons_helper/icons_helper.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";
  final AuthResponse authNav;
  HomePage(this.authNav);
  @override
  _HomePageState createState() => new _HomePageState(authNav);
}

class _HomePageState extends State<HomePage> {
  List<Widget> _children;
  List<BottomNavigationBarItem> _barNav;

  final AuthResponse authNav;
  _HomePageState(this.authNav){
    _children = [];
    _barNav = [];
    authNav.nav.forEach((nav){
      switch(nav.screenType) {
        case 'list': {
          _children.add(new HomeListPage(nav.apiURL, true, Colors.cyan[500])); //needs updating to use api url instead of session
          _barNav.add(new BottomNavigationBarItem(
            icon: Icon(getIconGuessFavorMaterial(name: nav.icon), color: Colors.lightBlue), //fix to use dynamic icons
            title: Text(nav.title, style: TextStyle(color:Colors.lightBlue)),
          ));
        }
        break;

        case 'profile': {
          _children.add(ProfilePage(nav.apiURL)); //needs updating to use api url instead of session
          _barNav.add(new BottomNavigationBarItem(
            icon: Icon(getIconGuessFavorMaterial(name: nav.icon), color: Colors.lightBlue), //fix to use dynamic icons
            title: Text(nav.title, style: TextStyle(color:Colors.lightBlue)),
          ));
        }
        break;
      }
    });
  }
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final bottomNavigationBar = new BottomNavigationBar(
      onTap: onTabTapped, // new
      currentIndex: _currentIndex, // new
      items: _barNav,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: _children[_currentIndex],
        bottomNavigationBar: bottomNavigationBar,
    );
  }
}

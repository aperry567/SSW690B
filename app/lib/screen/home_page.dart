import 'package:flutter/material.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile.dart';
import 'inbox.dart';
import 'home_list.dart';
import 'payment.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";
  final String sessionID;
  HomePage(this.sessionID);
  @override
  _HomePageState createState() => new _HomePageState(sessionID);
}

class _HomePageState extends State<HomePage> {
  final String sessionID;
  _HomePageState(this.sessionID);
  int _currentIndex = 0;





  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

    });
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      HomeListPage(sessionID),
      PaymentPage(sessionID),
      ProfilePage(sessionID),
    ];
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
      items: [
        new BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),

        new BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          title: Text('Payment'),
        ),


        new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile')
        )
      ],

    );


    return Scaffold(
      backgroundColor: Colors.white,
      body: _children[_currentIndex],
        bottomNavigationBar: bottomNavigationBar,
    );
  }
}

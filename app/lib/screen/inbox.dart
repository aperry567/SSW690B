import 'package:flutter/material.dart';
import 'package:login/screen/chatscreen.dart';


class InboxPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: new ChatScreen()
    );
  }
}
import 'package:flutter/material.dart';
import 'package:login/screen/chatscreen.dart';
import 'package:login/config.dart' as config;

class InboxPage extends StatelessWidget {
  final sessionID;
  InboxPage(this.sessionID);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: new ChatScreen(config.baseURL + "/api/logout?sessionID=" + sessionID,'sendURL')//TODO
    );
  }
}
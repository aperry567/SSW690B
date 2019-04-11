import 'package:flutter/material.dart';
import 'package:login/screen/login_page.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/config.dart' as config;

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    SharedPreferences.getInstance().then((SharedPreferences prefs){
      config.baseURL = prefs.getString("baseURL") ?? config.baseURL;
      runApp(new MyApp());
    });
  });
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    '/login': (context) => LoginPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodeversitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}

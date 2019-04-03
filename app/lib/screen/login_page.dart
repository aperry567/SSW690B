import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:login/screen/sign_up_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forget_password.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "/login";
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var email_value;
  var password_value;
  bool error_switch = false;

  login(email, password) async {
    JsonEncoder encoder = new JsonEncoder();
    Map json = {"email": email, "password": password};
    var url = "http://35.207.6.9:8080/api/login";
    var res = http.post(url, body: encoder.convert(json))
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 401) {
        setState(() { //setState动态更新
          error_switch = true;
        });
      }
      else if(response.statusCode == 200){

        Map<String, dynamic> result = jsonDecode(response.body);
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) =>
            new HomePage(result['sessionID']))
        );
      }
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

     final email = TextField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (String value){
        email_value = value;
        setState(() {
          error_switch = false;
        });

      },
    );

    final password = TextField(
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),

      onChanged: (String value){
        password_value = value;
        setState(() {
          error_switch = false;
        });
      },
    );

    final responseCode = new Offstage(
      offstage: !error_switch,
      child:Text(
        '       Invalid Credentials',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      )
      ,);


    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          error_switch = false;
          var response = login(email_value, password_value);
          //TODO

        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.push(
            context, new MaterialPageRoute(
            builder: (context) =>
            new ForgetPassWordPage())
        );
      },
    );

    final signUpLabel = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

      Text("Don't have an account?"),
      FlatButton(
        child: Text(
          'Sign Up',
          style: TextStyle(color: Colors.blue, fontSize: 16,fontWeight: FontWeight.bold),
        ),
            onPressed: () {
          Navigator.push(
            context, new MaterialPageRoute(
            builder: (context) =>
            new SignUpPage())
          );
        },
      ),
    ],);



    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 8.0),
            responseCode,
            SizedBox(height: 20.0),
            loginButton,
            forgotLabel,
            signUpLabel
          ],
        ),
      ),
    );
  }
}

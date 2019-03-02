import 'package:flutter/material.dart';
import 'package:login/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  static String tag = 'sign-up-page';
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _switchSelected = false; //维护单选开关状态

  bool error_switch = false;
  bool error_comfirm_password = false;
  bool error_email = true;

  bool isCharactors = false;
  bool isUppercase = false;
  bool isLowercase = false;
  bool isNumbers = false;

  String email_value;
  String password_value;
  String conmfirm_password_value;
  String role_value;
  String name_value = "TEST";
  String address_value = "TEST";
  String city_value = "TEST";
  String state_value = "nj";
  String postalCode_valu = "TEST";
  String phone_value = "TEST";
  var doctorLicences_value =  [
    {
      "state": "ak",
      "license": "TEST"
    }
  ];

  signup(email, password, role, name, address, city, state, postalCode, phone, doctorLicences) async {
    JsonEncoder encoder = new JsonEncoder();
    Map json = {
      "email": email_value,
      "password": password_value,
      "role": _switchSelected? "doctor" : "patient",
      "name": name_value,
      "address": address_value,
      "city": city_value,
      "state": state_value,
      "postalCode": postalCode_valu,
      "phone": phone_value,
      "doctorLicences": doctorLicences_value
    };
    var url = "http://35.207.6.9:8080/api/signup";
    http.post(url, body: encoder.convert(json))
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400)
        setState(() {
          error_switch = true;
        });
      else if(response.statusCode == 200){
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) =>
            new HomePage())
        );
      }
    });

  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {

    TextStyle style_valid = TextStyle(color: Colors.green, fontSize: 11);
    TextStyle style_invalid = TextStyle(color: Colors.red, fontSize: 11);

    final logo = Hero(
      tag: 'hero',
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
      onChanged: (text)  {
        email_value = text;
        setState(() {
          error_email = validateEmail(email_value);
        });

      },
    );

    final responseCode = new Offstage(
      offstage: !error_switch,
      child:Text(
        '       This email has been registered',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      )
      ,);

    final email_error_format = new Offstage(
      offstage: error_email,
      child:Text(
        '       Please enter a valid email',
        style: style_invalid,

      )
      ,);






    final password_status = new Row(children: <Widget>[
      Text('       6 to 16 charactors  ', style: !isCharactors? style_invalid:style_valid),
      Text('1 UPPER CASE  ', style: !isUppercase? style_invalid:style_valid),
      Text('1 lower case  ', style: !isLowercase? style_invalid:style_valid),
      Text('1 number', style: !isNumbers? style_invalid:style_valid),
    ],);


    final password = TextField(
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text) {
        setState(() { //setState动态更新
          password_value = text;
          error_comfirm_password = (conmfirm_password_value == password_value);
          isCharactors = (text.length <= 16) && (text.length >= 6);
          isUppercase = text.contains(new RegExp(r'[A-Z]'));
          isLowercase = text.contains(new RegExp(r'[a-z]'));
          isNumbers = text.contains(new RegExp(r'[0-9]'));
        });
      }
    );



    final confirmPassword = TextField(
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        setState(() {
          conmfirm_password_value = text;
          error_comfirm_password = (conmfirm_password_value == password_value);
        });
      },
    );



    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          var response = signup(email_value, password_value,role_value, name_value, address_value, city_value, state_value, postalCode_valu, phone_value, doctorLicences_value);
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Sign Up', style: TextStyle(color: Colors.white)),
      ),
    );

    final ifDoctorSwitch = new Row(children: <Widget>[
      Text('I am a doctor'),

      Switch(//传入value和onChanged,传入value按钮初始化状态,onChanged状态改变回调
      value: _switchSelected,
      activeColor: Colors.red,
      onChanged: (value){
        setState(() {//setState动态更新
          _switchSelected = value;
        });
      },
    )
    ],);


    final doctorOptions = new Offstage(
      offstage: !_switchSelected,
      child:
        new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Lisence ID',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                )
            )
          ],)

      ,);


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
            responseCode,
            email_error_format,
            SizedBox(height: 12.0),
            password,
            SizedBox(height: 5.0),
            password_status,
            SizedBox(height: 12.0),
            confirmPassword,
            SizedBox(height: 5.0),
            Text("       Password doesn't match! ", style: error_comfirm_password? style_valid : style_invalid),
            SizedBox(height: 20.0),
            ifDoctorSwitch,
            doctorOptions,
            signUpButton,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';


class ForgetPassWordPage extends StatefulWidget {
  static String tag = 'forget-password-page';

  @override
  _ForgetPassWordPageState createState() => new _ForgetPassWordPageState();
}

class _ForgetPassWordPageState extends State<ForgetPassWordPage> {


  bool errorSwitch = false;
  bool errorComfirmPassword = false;
  bool errorEmail = true;

  bool isCharactors = false;
  bool isUppercase = false;
  bool isLowercase = false;
  bool isNumbers = false;


  String _email_value;
  String _password_value;
  String _conmfirm_password_value;


  SecretQuestion _secret_question_value;
  String _secret_anwser_value;



  Future<void> resetPassword() async {
    JsonEncoder encoder = new JsonEncoder();



    Map json = {
      "email": _email_value,
      "secretQuestion": _secret_question_value.name,
      "secretAnswer": _secret_anwser_value,
      "password": _password_value,
    };

    var url = "http://35.207.6.9:8080/api/passwordRest";
    var res = await http.post(url, body: encoder.convert(json))
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400)
        setState(() {
          errorSwitch = true;
        });
      else if(response.statusCode == 200){
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) =>
            new HomePage(response.body))
        );
      }
    });
    print(res);
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
        _email_value = text;
        setState(() {
          errorEmail = validateEmail(_email_value);
        });

      },
    );

    final responseCode = new Offstage(
      offstage: !errorSwitch,
      child:Text(
        '       This email has been registered',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      )
      ,);

    final email_error_format = new Offstage(
      offstage: errorEmail,
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
          hintText: 'New Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        onChanged: (text) {
          setState(() { //setState动态更新
            _password_value = text;
            errorComfirmPassword = (_conmfirm_password_value == _password_value);
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
          _conmfirm_password_value = text;
          errorComfirmPassword = (_conmfirm_password_value == _password_value);
        });
      },
    );

    final confirm_error_ = new Offstage(
      offstage: errorComfirmPassword,
      child:Text(
        "      Password doesn't match",
        style: style_invalid,

      )
      ,);

    final secretQuestion = new Row(children: <Widget>[
      SizedBox(width: 8.0,),
      new DropdownButton<SecretQuestion>(
        hint: new Text("Select your secret question ", style: new TextStyle(fontSize: 14),),
        value: _secret_question_value,
        onChanged: (SecretQuestion newValue) {
          setState(() {
            _secret_question_value = newValue;
          });
        },
        items: EnumList.secret_question.map((SecretQuestion value) {
          return new DropdownMenuItem<SecretQuestion>(
            value: value,
            child: new Text(
              value.name,
              style: new TextStyle(color: Colors.black, fontSize: 14),
            ),
          );
        }).toList(),
      ),
    ],);

    final secretAnwser = TextField(
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Anwser',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        _secret_anwser_value = text;
      },
    );



    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          var response = resetPassword();
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Reset', style: TextStyle(color: Colors.white)),
      ),
    );



    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 60.0),
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
            confirm_error_,
            new Divider(indent: 0, color: Colors.black,),
            SizedBox(height: 8.0),

            new Divider(indent: 0, color: Colors.black,),
            secretQuestion,
            SizedBox(height: 8.0),
            secretAnwser,
            SizedBox(height: 5.0),
            new Divider(indent: 0, color: Colors.black,),

            signUpButton,

          ],
        ),
      ),
    );
  }
}

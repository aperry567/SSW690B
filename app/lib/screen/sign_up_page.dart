import 'package:flutter/material.dart';
import 'package:login/models/auth_response.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login/config.dart' as config;

class SignUpPage extends StatefulWidget {
  static String tag = 'sign-up-page';
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  _SignUpPageState(){
    getSpecialities();
  }

  bool _switchSelected = false; //维护单选开关状态

  bool errorSwitch = false;
  bool errorComfirmPassword = false;
  bool errorEmail = true;

  bool isCharactors = false;
  bool isUppercase = false;
  bool isLowercase = false;
  bool isNumbers = false;


  File _image;
  String _email_value;
  String _password_value;
  String _conmfirm_password_value;
  String _role_value;
  String _name_value = "default";
  String _gender;
  String _address_value = "default";
  String _city_value = "default";
  USState _state_value;
  String _postal_code_value = "default";
  String _phone_value = "default";
  SecretQuestion _secret_question_value;
  String _secret_anwser_value;
  String _pharmacy_location_value;

  String _doctor_ID_value;
  USState _doctor_state_value;

  DateTime _selectedDate = DateTime.now();

  var _doctorLicences_value;

  String _specialty_hint = "Specialty";
  List<Speciality> specialitiesList = [];
  Speciality _doctor_specialty_value;

  showDialogMenu(){
    return showDialog(context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: new Text('Take a photo'),
                    onTap: takePhoto,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Select from gallery'),
                    onTap: openGallery,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> getSpecialities() async {
    var url = config.baseURL + '/api/getDoctorSpecialities';
    await http.get(url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400)
        setState(() {

        });
      else if(response.statusCode == 200){
        List<dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            print(result);
            for(var i=0; i<result.length; i++){
              specialitiesList.add(Speciality(result[i]['id'], result[i]['name']));
            }
            print(specialitiesList);
          });
        }
      }
    });
  }

  Future takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  Future openGallery() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> signup() async {
    JsonEncoder encoder = new JsonEncoder();

    const Base64Codec base64 = Base64Codec();
    List<int> imageBytes = _image.readAsBytesSync();
    String base64Image = base64.encode(imageBytes);


    if(_switchSelected){
      _doctorLicences_value =  [
        {
          "state": _doctor_state_value.name,
          "license": _doctor_ID_value,
        }
      ];
    }


    Map json = {
      "email": _email_value,
      "password": _password_value,
      "role": _switchSelected? "doctor" : "patient",
      "name": _name_value,
      "address": _address_value,
      "city": _city_value,
      "state": _state_value.name,
      "postalCode": _postal_code_value,
      "phone": _phone_value,
      //      "photo" : base64Image,
      "photo" : base64Image,
      "secretQuestion": _secret_question_value.name,
      "secretAnswer": _secret_anwser_value,
      "pharmacyLocation" : _pharmacy_location_value,
      "doctorLicences": _doctorLicences_value,
      "doctorSpecialities": [1],
      "dob": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "gender": _gender,
    };
    var url = config.baseURL + "/api/signup";
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
            builder: (context) {
              final json = jsonDecode(response.body);
              AuthResponse authResponse = new AuthResponse.fromJson(json);
              return new HomePage(authResponse);
            }
        ));
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
          hintText: 'Password',
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




    final name = TextField(
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        _name_value = text;
      },
    );

    final genderSelection = new Row(children: <Widget>[
      SizedBox(width: 8.0,),
      new DropdownButton<String>(
        hint: new Text("Select your gender ", style: new TextStyle(fontSize: 14),),
        value: _gender,
        onChanged: (String newValue) {
          setState(() {
            _gender = newValue;
          });
        },
        items: <String>['Male', 'Female', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        })
            .toList(),
      ),
    ],);

    final state = new Row(children: <Widget>[
      SizedBox(width: 18.0,),
      new DropdownButton<USState>(
        hint: new Text("Select your state"),
        value: _state_value,
        onChanged: (USState newValue) {
          setState(() {
            _state_value = newValue;
          });
        },
        items: EnumList.us_states_list.map((USState user) {
          return new DropdownMenuItem<USState>(
            value: user,
            child: new Text(
              user.name,
              style: new TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    ],);

    final city = TextField(
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'City',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        _city_value = text;
      },
    );

    final address = TextField(
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Address',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        _address_value = text;
      },
    );

    final postalCode = TextField(
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Postal Code',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        _postal_code_value = text;
      },
    );

    final phone = TextField(
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Phone Number',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text)  {
        _phone_value = text;
      },
    );

    final pharmacyLocation = Offstage(
      offstage: _switchSelected,
      child: TextField(
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Your pharmacy's location",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        onChanged: (text)  {
          _pharmacy_location_value = text;
        },
      ),
    );

    final dobSelection = Column(
      children: <Widget>[
        Text("${_selectedDate.toLocal()}"),
        SizedBox(height: 20.0,),
        RaisedButton(
          onPressed: () => _selectDate(context),
          child: Text('Select date'),
        ),
      ],
    );

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

            ),
            onChanged: (text)  {
              setState(() {
                _doctor_ID_value = text;
              });
            },
          ),
          SizedBox(height: 3,),
          new Row(children: <Widget>[
            SizedBox(width: 18.0,),
            new DropdownButton<USState>(
              hint: new Text("Select the state of your lisence"),
              value: _doctor_state_value,
              onChanged: (USState newValue) {
                setState(() {
                  _doctor_state_value = newValue;
                });
              },
              items: EnumList.us_states_list.map((USState state) {
                return new DropdownMenuItem<USState>(
                  value: state,
                  child: new Text(
                    state.name,
                    style: new TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ],),
          Row(children: <Widget>[
            SizedBox(width: 18.0,),
            new DropdownButton<Speciality>(
              hint: Text(_specialty_hint),
              value: _doctor_specialty_value,
              onChanged: (Speciality newValue) {
                setState(() {
                  _doctor_specialty_value = newValue;
                });
              },
              items: specialitiesList.map((Speciality specialty) {
                return new DropdownMenuItem<Speciality>(
                  value: specialty,
                  child: new Text(
                    specialty.name,
                    style: new TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ],),
        ],)

      ,);

    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          var response = signup();
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Sign Up', style: TextStyle(color: Colors.white)),
      ),
    );

    final photoButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          showDialogMenu();
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Upload Picture', style: TextStyle(color: Colors.white)),
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
            name,
            SizedBox(height: 8.0),
            dobSelection,
            SizedBox(height: 8.0),
            genderSelection,
            SizedBox(height: 8.0),
            photoButton,
            SizedBox(height: 8.0),
            state,
            SizedBox(height: 8.0),
            city,
            SizedBox(height: 8.0),
            address,
            SizedBox(height: 8.0),
            postalCode,
            SizedBox(height: 8.0),
            phone,
            new Divider(indent: 0, color: Colors.black,),
            secretQuestion,
            SizedBox(height: 8.0),
            secretAnwser,
            SizedBox(height: 5.0),
            pharmacyLocation,
            SizedBox(height: 5.0),
            new Divider(indent: 0, color: Colors.black,),
            ifDoctorSwitch,
            doctorOptions,
            signUpButton,
          ],
        ),
      ),
    );
  }
}

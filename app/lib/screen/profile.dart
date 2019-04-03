import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login/screen/login_page.dart';



class ProfilePage extends StatefulWidget {
  final String sessionID;
  ProfilePage(this.sessionID);
  static String tag = 'profile-page';
  @override
  _ProfilePageState createState() => new _ProfilePageState(sessionID);
}



class _ProfilePageState extends State<ProfilePage> {

  final String sessionID;
  _ProfilePageState(this.sessionID){

    getProfile();
    print(sessionID);
  }
  TextEditingController _controller_name;
  TextEditingController _controller_address;
  TextEditingController _controller_city;
  TextEditingController _controller_state;
  TextEditingController _controller_postalcode;
  TextEditingController _controller_pharmacylocation;
  TextEditingController _controller_phone;


  Image _image = Image.asset('assets/profile.jpg');
  List<int> _imageBytes;
  String _base64Imag;


  String _name_value = "default";
  String _address_value = "default";
  String _city_value = "default";
  String _state_value = 'nowhere';
  String _postal_code_value = "default";
  String _phone_value = "default";
  String _secret_question_value = "default";
  String _secret_anwser_value = "default";
  String _pharmacy_location_value = "default";

  String _doctor_ID_value = "default";
  String _doctor_state_value = "nowhere";
  var _doctorLicences_value;

  bool _is_loading = true;



  Future<void> getProfile() async {
    var url = "http://35.207.6.9:8080/api/getProfile?sessionID=" + sessionID;


    await http.get(url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400)
        setState(() {
          _is_loading = false;
        });
      else if(response.statusCode == 200){
        Map<String, dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            _name_value = result['name'];
            _address_value = result['address'];
            _city_value = result['city'];
            _state_value = result['state'];
            _postal_code_value = result['postalCode'];
            _phone_value = result['phone'];
            _base64Imag = result['photo'];
            _secret_question_value = result['secretQuestion'];
            _secret_anwser_value = result['secretAnswer'];
            //_doctorLicences_value = result['doctorLicences'];

            //_doctor_ID_value = _doctorLicences_value['state'];
            //_doctor_state_value = _doctorLicences_value['license'];
            _is_loading = false;
          });
        }
      }
    });

    if(_base64Imag != null){
      const Base64Codec base64 = Base64Codec();
      _imageBytes = base64.decode(_base64Imag);
      setState(() {
        _image = Image.memory(_imageBytes);
      });
    }

  }

  logout() async {
    JsonEncoder encoder = new JsonEncoder();
    var url = "http://35.207.6.9:8080/api/logout?sessionID=" + sessionID;
    await http.get(url)
        .then((response) {
      if(response.statusCode == 400)
        setState(() {
          _is_loading = false;
        });
      else if(response.statusCode == 200){
        if (this.mounted){
          setState(() {
          });
        }
      }
    });
  }

  Widget build(BuildContext context) {

    _controller_name = new TextEditingController(text: _name_value);
    _controller_address = new TextEditingController(text: _address_value);
    _controller_city = new TextEditingController(text: _city_value);
    _controller_state = new TextEditingController(text: _state_value);
    _controller_postalcode = new TextEditingController(text: _postal_code_value);
    _controller_pharmacylocation = new TextEditingController(text: _pharmacy_location_value);
    _controller_phone = new TextEditingController(text: _phone_value);

    List<Widget> widgetList = [];



    final photo = Container(
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: _image,
      ),
    );

    final name_row = new Row(
      children: <Widget>[
        Text('Name: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_name,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final address_row = new Row(
      children: <Widget>[
        Text('Address: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_address,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final city_row = new Row(
      children: <Widget>[
        Text('City: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_city,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final state_row = new Row(
      children: <Widget>[
        Text('State: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_state,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final postal_row = new Row(
      children: <Widget>[
        Text('Postal Code: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_postalcode,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final pharmacy_row = new Row(
      children: <Widget>[
        Text('Pharmacy Location: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_pharmacylocation,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final phone_row = new Row(
      children: <Widget>[
        Text('Phone: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_phone,
            autofocus: false,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ],
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          var response = logout();
          Navigator.popUntil(context, ModalRoute.withName('/'));
          //TODO
        },
        padding: EdgeInsets.all(12),
        color: Colors.red,
        child: Text('Logout', style: TextStyle(color: Colors.white, backgroundColor: Colors.red)),
      ),
    );

    Stack(
      children: widgetList,
    );




    Scaffold screen = new Scaffold(
      backgroundColor: Colors.white,
        body: Center(
        child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
            photo,
            SizedBox(height: 5,),
            name_row,
            SizedBox(height: 5,),
            address_row,
            SizedBox(height: 5,),
            city_row,
            SizedBox(height: 5,),
            state_row,
            SizedBox(height: 5,),
            postal_row,
            SizedBox(height: 5,),
            pharmacy_row,
            SizedBox(height: 5,),
            phone_row,
            SizedBox(height: 5,),
            loginButton,
          ]
        )
        ),
    );

    Stack stack = new Stack(
      children: widgetList,
    );

    widgetList.add(screen);
    if (_is_loading) {
      widgetList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

    return Stack(
      children: widgetList,
    );

  }
}

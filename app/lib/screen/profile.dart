import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login/config.dart' as config;
import 'package:login/component/enum_list.dart';

class ProfilePage extends StatefulWidget {
  final String profileURL;
  ProfilePage(this.profileURL);
  static String tag = 'profile-page';
  @override
  _ProfilePageState createState() => new _ProfilePageState(profileURL);
}

class _ProfilePageState extends State<ProfilePage> {

  final String profileURL;
  _ProfilePageState(this.profileURL){
    getSpecialities();
    getProfile();
    print(profileURL);
  }
  TextEditingController _controller_name;
  TextEditingController _controller_address;
  TextEditingController _controller_city;
  TextEditingController _controller_state;
  TextEditingController _controller_postalcode;
  TextEditingController _controller_pharmacylocation;
  TextEditingController _controller_phone;
  TextEditingController _controller_license;

  Image _image = Image.asset('assets/profile.jpg');
  List<int> _imageBytes;
  String _base64Imag;

  String role = "patient";
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
  List<dynamic> _doctorLicensesList = [];
  USState _doctor_state_value;
  String _doctor_state_hint = "Select the state of your lisence";
  var _doctorLicenses_value;
  String _specialty_hint = "Specialty";

  bool _is_loading = true;
  bool _canUpdate = false;
  List<Speciality> specialitiesList = [];
  Speciality _doctor_specialty_value;

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
          });
        }
      }
    });
  }

  Future<void> getProfile() async {
    var url = config.baseURL + profileURL;
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
            role = result['role'];
            _name_value = result['name'];
            _address_value = result['address'];
            _city_value = result['city'];
            _state_value = result['state'];
            _postal_code_value = result['postalCode'];
            _phone_value = result['phone'];
            _base64Imag = result['photo'];
            _secret_question_value = result['secretQuestion'];
            _secret_anwser_value = result['secretAnswer'];
            //_doctorLicenses_value = result['doctorLicences'];

            if(role == 'doctor'){
              for(var i=0; i< specialitiesList.length; i++){
                if(specialitiesList[i].id == result['doctorSpecialities'][0])
                  _specialty_hint = specialitiesList[i].name;
                _doctor_specialty_value = specialitiesList[i];
              }
              _doctorLicensesList = result['doctorLicences'];
              _doctor_ID_value = _doctorLicensesList[0]['license'];
              _doctor_state_hint = _doctorLicensesList[0]['state'].toUpperCase();
            }

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

  Future<void> update() async {
    String sessionID = profileURL.split("=")[1];
    JsonEncoder encoder = new JsonEncoder();

    Map json = {
      "name": _name_value,
      "address": _address_value,
      "city": _city_value,
      "state": _state_value,
      "postalCode": _postal_code_value,
      "phone": _phone_value,
      //      "photo" : base64Image,
      "photo" : _base64Imag,
      "secretQuestion": _secret_question_value,
      "secretAnswer": _secret_anwser_value,
      "pharmacyLocation" : _pharmacy_location_value,
      "doctorLicences": _doctorLicensesList,
      "dob": "2000-12-30",
      "gender": "Female",
      "doctorSpecialities" : [_doctor_specialty_value.id],
    };
    var url = config.baseURL + "/api/updateProfile?sessionID="+sessionID;
    var res = await http.post(url, body: encoder.convert(json))
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400)
        setState(() {

        });
      else if(response.statusCode == 200){

      }
    });
    print(res);
  }

  logout() async {
    JsonEncoder encoder = new JsonEncoder();
    var url = config.baseURL + "/api/logout?sessionID="; // + sessionID; //TODO: fix so that logout is provided with the authResponse api call
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
    _controller_license = new TextEditingController(text: _doctor_ID_value);

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
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (text) {
              setState(() {
                _name_value = text;
                _canUpdate = true;
              });
            },
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
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (text) {
              setState(() {
                _address_value = text;
                _canUpdate = true;
              });
            },
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
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (text) {
              setState(() {
                _city_value = text;
                _canUpdate = true;
              });
            },
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
            enabled: true,
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
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (text) {
              setState(() {
                _postal_code_value = text;
                _canUpdate = true;
              });
            },
          ),
        ),
      ],
    );

    final pharmacy_row = Offstage(
      offstage: role != 'patient',
      child: Row(
        children: <Widget>[
          Text('Pharmacy Location: '),
          new Flexible(
            child: new TextField(
              // The TextField is first built, the controller has some initial text,
              // which the TextField shows. As the user edits, the text property of
              // the controller is updated.
              controller: _controller_pharmacylocation,
              autofocus: false,
              enabled: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
              onChanged: (text) {
                setState(() {
                  _pharmacy_location_value = text;
                  _canUpdate = true;
                });
              },
            ),
          ),
        ],
      ),
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
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (text) {
              setState(() {
                _phone_value = text;
                _canUpdate = true;
              });
            },
          ),
        ),
      ],
    );

    final licenseState = Row(children: <Widget>[
      SizedBox(width: 18.0,),
      new DropdownButton<USState>(
        hint: new Text(_doctor_state_hint),
        value: _doctor_state_value,
        onChanged: (USState newValue) {
          setState(() {
            _doctor_state_value = newValue;
            _canUpdate = true;
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
    ],);

    final doctorID = new Row(
      children: <Widget>[
        Text('license: '),
        new Flexible(
          child: new TextField(
            // The TextField is first built, the controller has some initial text,
            // which the TextField shows. As the user edits, the text property of
            // the controller is updated.
            controller: _controller_license,
            autofocus: false,
            enabled: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (text) {
              setState(() {
                _doctor_ID_value = text;
                _canUpdate = true;
              });
            },
          ),
        ),
      ],
    );

    final doctorSpecialty = Row(children: <Widget>[
      SizedBox(width: 18.0,),
      new DropdownButton<Speciality>(
        hint: Text(_specialty_hint),
        value: _doctor_specialty_value,
        onChanged: (Speciality newValue) {
          setState(() {
            _doctor_specialty_value = newValue;
            _canUpdate = true;
          });
        },
        items: specialitiesList.map((Speciality state) {
          return new DropdownMenuItem<Speciality>(
            value: state,
            child: new Text(
              state.name,
              style: new TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    ],);

    final doctorLicense = Offstage(
      offstage: role == 'patient',
      child: Column(
        children: <Widget>[
          Divider(color: Colors.black,),
          Text('Doctor License:'),
          licenseState,
          SizedBox(height: 5,),
          doctorID,
          SizedBox(height: 5,),
          doctorSpecialty,
        ],
      ),
    );



    final updateButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: _canUpdate? () {
          update();
        } : null,
        padding: EdgeInsets.all(12),
        color:  _canUpdate? Colors.blue :  Colors.grey,
        child: Text('Update', style: TextStyle(color: Colors.white, backgroundColor: _canUpdate? Colors.blue :  Colors.grey)),
      ),
    );

    final logoutButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
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
            doctorLicense,
            SizedBox(height: 5,),
            updateButton,
            logoutButton,
          ]
        )
        ),
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

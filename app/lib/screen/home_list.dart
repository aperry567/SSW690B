import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';



class HomeListPage extends StatefulWidget {
  final String sessionID;
  HomeListPage(this.sessionID);
  static String tag = 'profile-page';
  @override
  _HomeListPageState createState() => new _HomeListPageState(sessionID);
}



class _HomeListPageState extends State<HomeListPage> {

  final String sessionID;
  _HomeListPageState(this.sessionID){

    getProfile();
    print(sessionID);
  }




  bool _is_loading = true;



  Future<void> getProfile() async {
    var url = "http://35.207.6.9:8080/api//getPatientHomeItems?sessionID=" + sessionID;


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

            //_doctorLicences_value = result['doctorLicences'];

            //_doctor_ID_value = _doctorLicences_value['state'];
            //_doctor_state_value = _doctorLicences_value['license'];
            _is_loading = false;
          });
        }

      }
    });


    }

  final Card card = new Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 18.0 / 11.0,
          child: Image.asset('assets/alucard.jpg'),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Title'),
              SizedBox(height: 8.0),
              Text('Secondary Text'),
            ],
          ),
        ),
      ],
    ),
  );


  Widget build(BuildContext context) {



    List<Widget> widgetList = [];

    Stack(
      children: widgetList,
    );




    Scaffold screen = new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          child: ListView(
              
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                card,
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

    return stack;

  }
}

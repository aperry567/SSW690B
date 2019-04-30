import 'dart:async';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:login/config.dart' as config;
import 'home_list.dart';
import 'doctor_list.dart';

class Question{
  String question;
  String moreQuestionsURL;

}

class Questionaire extends StatefulWidget {
  final url;
  Questionaire(this.url);
  @override
  _QuestionaireState createState() => new _QuestionaireState(url);
}

class _QuestionaireState extends State<Questionaire>{
  final url;
  _QuestionaireState(this.url);

  AnimationController _animateController;

  List<Widget> questionList = [];

  void initState() {
    // TODO: implement initState
    super.initState();
    getQuestions(url);
  }

  Future<Null> getQuestions(url) async {
    print(url);
    await http.get(url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400) {
        setState(() {

        });
      }
      else if(response.statusCode == 200){
        List<dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            for(var i=0; i<result.length; i++) {
              print(result[i]['question']);
              questionList.add(
                  GestureDetector(
                    //child: Text(result['question'], style: TextStyle(color: Colors.black, fontSize: 20),),
                      child: Card(
                        elevation: 8.0,
                        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              title: Text(
                                result[i]['question'],
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              trailing:
                              Icon(Icons.keyboard_arrow_right, color: Colors.blueGrey, size: 30.0)),
                        ),
                      ),
                    onTap: (){
                        if(result[i]['moreQuestionsURL'] != ''){
                          print("moreQuestions");
                          Navigator.push(context, new MaterialPageRoute(
                              builder: (context) =>
                                  Questionaire(config.baseURL + result[i]['moreQuestionsURL']))
                          );
                        }
                        else if(result[i]['findDoctorURL'] != ''){
                          print("findDoctor");
                          Navigator.push(context, new MaterialPageRoute(
                              builder: (context) =>
                                  DoctorListPage(config.baseURL + result[i]['findDoctorURL']))
                          );
                        }

                    },
                  )
              );
            }
          });
        }

      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 100,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: questionList,
          )

        ],
      ),
    );

  }
}






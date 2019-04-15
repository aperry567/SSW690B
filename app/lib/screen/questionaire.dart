import 'dart:async';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';


class Questionaire extends StatefulWidget {
  final url;
  final bool isFirstPage;
  Questionaire(this.url, this.isFirstPage);
  @override
  _QuestionaireState createState() => new _QuestionaireState(url, isFirstPage);
}

class _QuestionaireState extends State<Questionaire>{
  final url;
  final bool isFirstPage;
  _QuestionaireState(this.url, this.isFirstPage);

  String _question = "Error: no question?";
  AnimationController _animateController;

  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<Null> getMessage(dateTime) async {
    await http.get(url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400) {
        setState(() {

        });
      }
      else if(response.statusCode == 200){
        Map<String, dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            _question = result[0]['question'];
          });
        }

      }
    });
  }

  @override
  Widget build(BuildContext context){
    if(isFirstPage){
      return QuestionnaireStartPage();
    }
    else{
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: FlutterLogo(
                    colors: Colors.cyan,
                    size: 100.0,
                  )
              ),
              SizedBox( height: 50,),
              Text(
                _question,
                style: TextStyle(
                    color: Colors.cyan[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'two buttons',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )
            ],
          ),
        );
    }

  }
}

class QuestionnaireStartPage extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    final questionRow = Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: FlutterLogo(
                colors: Colors.cyan,
                size: 100.0,
              )
          ),
          SizedBox( height: 50,),
          Text(
            "What's the problem?",
            style: TextStyle(
                color: Colors.cyan[500],
                fontWeight: FontWeight.bold,
                fontSize: 30.0),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Please anwser this 2 minutes survey, to help us find you a specialist.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withAlpha(200))]),
            height: 50.0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (context) =>
                        Questionaire('/api/getQuestionnaire?sessionID=0c6b22be-5dc1-11e9-8a1a-42010a8e0002', false))
                );
              },
              child: Center(
                  child: Text( 'Continue',
                    style: TextStyle(fontSize: 20.0, color: Colors.cyan),
                  )),
            ),
          )),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        body: questionRow
    );
  }

}






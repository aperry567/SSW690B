import 'package:flutter/material.dart';
import 'package:login/screen/item.dart';
import 'package:intl/intl.dart';
import 'package:login/screen/questionaire.dart';

class MyClipper extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    return new Rect.fromLTWH(0, 0, 100, 100);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }

}

class ListCard extends StatelessWidget  {

  final String _card_type;
  final String _time;
  final String _name;
  final String _title;
  final String _description;
  final Image _image;
  final String _color;
  final String _detailUrl;
  final String _screenType;
  ListCard(this._card_type, this._time, this._name, this._title, this._description, this._image, this._color, this._detailUrl, this._screenType);

  static const TextStyle _text_style_description = TextStyle(backgroundColor: Colors.white, color: Colors.black26);

  Widget build(BuildContext context) {
    TextStyle _text_style_status;
    Color bgColor = Colors.white;
    String timeStr = "";
    if (this._time != "") {
      DateTime time = DateTime.parse(this._time);
      timeStr = DateFormat.yMd().add_jm().format(time);
    }
    
    if (this._color != "") {
      bgColor = Color(int.parse(this._color));
    }
    TextStyle _text_style_type = TextStyle(color: Colors.white,fontWeight: FontWeight.bold);

    return new GestureDetector(
      onTap: (){
        print(_screenType);
        if(_screenType == 'list' ||  _screenType == 'detail'){
          Navigator.push(context, new MaterialPageRoute(
              builder: (context) =>
              // _screenType
              new ItemPage(_detailUrl))
          );
        }
        else if(_screenType == 'questionnaire'){
          Navigator.push(context, new MaterialPageRoute(
              builder: (context) =>
                  Questionaire('/api/getQuestionnaire?sessionID=0c6b22be-5dc1-11e9-8a1a-42010a8e0002', true))
          );
        }



      },
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _image,
                  // SizedBox(height: 8.0),
                  ],

              ),
            ),
            SizedBox(width: 10,),
            Container(
              width: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(timeStr, 
                    style: TextStyle(color: Colors.grey)
                  ),
                  SizedBox(height: 5.0),
                  Text(_name != null ? _name : '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 1.0),
                  Text(_title != null ? _title : ''),
                  // SizedBox(height: 8.0),
                  // Text(_description != null ? _description : '', style: _text_style_description,),
                ],
              ),
            ),

            Container(
              width: 35,
              color: bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(_card_type,style: _text_style_type),
                    ],
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );

        /*

        * */


  }
}
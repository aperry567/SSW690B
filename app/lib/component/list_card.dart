import 'package:flutter/material.dart';
import 'package:login/screen/item.dart';

class ListCard extends StatelessWidget  {

  final String _card_type;
  final String _time;
  final String _name;
  final String _title;
  final String _description;
  final Image _image;
  final String _color;
  final String _detailUrl;
  ListCard(this._card_type, this._time, this._name, this._title, this._description, this._image, this._color, this._detailUrl);

  static const TextStyle _text_style_description = TextStyle(backgroundColor: Colors.white, color: Colors.black26);

  Widget build(BuildContext context) {
    TextStyle _text_style_status;
    Color bgColor = Color(int.parse(this._color));
    TextStyle _text_style_type = TextStyle(color: Colors.white,fontWeight: FontWeight.bold);


    return new GestureDetector(
      onTap: (){
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) =>
            new ItemPage(_detailUrl))
        );
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

                  SizedBox(height: 8.0),
                  ],

              ),
            ),
            SizedBox(width: 10,),
            Container(
              width: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_time != null ? _time : ''),
                  SizedBox(height: 5.0),
                  Text(_name != null ? _name : ''),
                  SizedBox(height: 1.0),
                  Text(_title != null ? _title : ''),
                  SizedBox(height: 8.0),
                  Text(_description != null ? _description : '', style: _text_style_description,),
                ],
              ),
            ),

            Container(
              width: 35,
              color: bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
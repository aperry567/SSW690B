import 'package:flutter/material.dart';

class ListCard extends StatelessWidget  {

  final String card_type;
  final String passed;
  final String time;
  final String name;
  final String title;
  final String description;
  final Image image;
  final String color;
  ListCard(this.card_type, this.passed, this.time, this.name, this.title, this.description, this.image, this.color);

  static const TextStyle _text_style_description = TextStyle(backgroundColor: Colors.white, color: Colors.black26);

  Widget build(BuildContext context) {
    TextStyle _text_style_status;
    TextStyle _text_style_type = TextStyle(backgroundColor: Color(int.parse(color)), color: Colors.white,fontWeight: FontWeight.bold);


    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                image,
                //Text('      ${passed} ',style: _text_style_status,),
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
                Text(time),
                SizedBox(height: 5.0),
                Text(name),
                SizedBox(height: 1.0),
                Text(title),
                SizedBox(height: 8.0),
                Text(description, style: _text_style_description,),
              ],
            ),
          ),

          Container(
            width: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('${card_type}',style: _text_style_type),
                  ],
                ),
              ],
            ),
          ),


        ],
      ),
    );


  }
}
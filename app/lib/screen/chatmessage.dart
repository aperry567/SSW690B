import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  String name;
  Image image;
  String text;


// constructor to get text from textfield
  ChatMessage({
    this.name,
    this.image,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                child:image,
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(name, style: Theme.of(context).textTheme.subhead),
                new Container(
                  width: 310,
                  child: new Text(text),
                )
              ],
            )
          ],
        )
    );
  }
}
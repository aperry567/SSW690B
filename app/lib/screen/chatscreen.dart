import 'package:flutter/material.dart';
import 'package:login/screen/chatmessage.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final chatURL;
  ChatScreen(this.chatURL);
  @override
  State createState() => new ChatScreenState(chatURL);
}

class ChatScreenState extends State<ChatScreen> {
  final chatURL;
  final TextEditingController _chatController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  ChatScreenState(this.chatURL);

  Future<Null> getProfile() async {

    await http.get(chatURL)
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
            //_doctorLicences_value = result['doctorLicences'];

          });
        }

      }
    });
  }

  void _handleSubmit(String text) {
    _chatController.clear();
    ChatMessage message = new ChatMessage(
        text: text
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addSomeMessage() {
    _handleSubmit('Loses the human nature, lose a lot; lost brutal, lose everything.');
    _handleSubmit('Your lack of fear is based on your ignorance.');
    _handleSubmit('To civilization by the years, but not for the years to civilization.');
    _handleSubmit('Come, love, give her a star, go.');
    _handleSubmit('Ignorance and weakness is not a barrier to existence, but arrogance.');
    _handleSubmit('We are the gutter bugs, but still need someone to look up at the starry sky.');
    _handleSubmit('Of course not afraid, she knows that the sun will rise tomorrow.');
    _handleSubmit('Universe is a dark forest, each civilization are the hunter with a gun, like a ghost like sneak in the woods, gently poke the back side branches, trying not to step to issue a little voice, even breathing carefully: he must be careful, because the forest everywhere with him sneak hunter. If he finds any life, can do only one thing: to shoot and kill. In the forest, the others are hell, is the eternal threat, any exposed the existence of their own life will soon be destroyed, this is the prospect of the civilizations in the universe.');
    _handleSubmit("If you want to see the real world, you should watch the sky with its view, see the clould by its point and feel the wind by its idea.");
  }

  Widget _chatEnvironment (){
    return IconTheme(
      data: IconThemeData(color: Colors.white),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal:8.0),
        child: Row(
          children: <Widget>[
            new Flexible(
              child: TextField(
                decoration: new InputDecoration.collapsed(hintText: "Start typing ..."),
                controller: _chatController,
                onSubmitted: _handleSubmit,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),

                onPressed: ()=> _handleSubmit(_chatController.text),

              ),
            )
          ],
        ),

      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    _addSomeMessage();
    return Column(
      children: <Widget>[
        Flexible(
          child: LiquidPullToRefresh(
            color:Color(0xff0277bd),
            showChildOpacityTransition: false,
            backgroundColor:Colors.white,
            onRefresh: getProfile,	// refresh callback
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,

            ),		// scroll view
          ),
        ),
        Divider(
          height: 2.0,
        ),
        new Container(decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
          child: _chatEnvironment(),)
      ],
    );
  }
}
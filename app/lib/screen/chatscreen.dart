import 'package:flutter/material.dart';
import 'package:login/screen/chatmessage.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';



class Person{
  String name;
  String role;
  Image image;
  bool isCurrentUser;
  Person({
    this.name,
    this.image,
    this.isCurrentUser,
  });


}

class ChatScreen extends StatefulWidget {
  final chatURL;
  final sendURL;
  ChatScreen(this.chatURL, this.sendURL);
  @override
  State createState() => new ChatScreenState(chatURL, sendURL);
}

class ChatScreenState extends State<ChatScreen> {
  final chatURL;
  final sendURL;
  final TextEditingController _chatController = new TextEditingController();
  List<ChatMessage> _messages = <ChatMessage>[];

  Image _defaultPhoto = Image.asset('assets/profile.jpg', width: 200, height: 200,);
  var massages = [];
  var persons = Map();
  Timer timer;

  ChatScreenState(this.chatURL, this.sendURL){
    getMessage(null);
  }

  @override
  void initState() {
    super.initState();
    DateFormat dateFormat = new DateFormat('yyyy-MM-dd hh:mm:ss');
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getMessage(dateFormat.format(DateTime.now())));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<Null> sendMessage(text) async {
    Map json = {
      "value": text,
    };
    JsonEncoder encoder = new JsonEncoder();

    var res = await http.post(sendURL, body: encoder.convert(json))
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400)
        setState(() {

        });
      else if(response.statusCode == 200){
        getMessage(null);
      }
    });
  }

  Future<Null> getMessage(dateTime) async {
    var url;
    if(dateTime != null){
      url = chatURL + '&timeLastRead=' +dateTime;
    }
    else{
      url = chatURL;
    }
    print(url);
    await http.get(url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400) {
        setState(() {
          print('Denied');
        });
      }
      else if(response.statusCode == 200){
        if(dateTime == null){
          _messages = <ChatMessage>[];
        }
        Map<String, dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            massages = result['chats'];
            var photos = result['photos'];
            if(massages.length != 0){
              var image;
              for(var photo in photos){
                var base64Imag = photo['photo'];
                if(base64Imag != ''){
                  const Base64Codec base64 = Base64Codec();
                  var imageBytes = base64.decode(base64Imag);
                  image = Image.memory(imageBytes, width: 200, height: 200,);
                }
                var id = photo['id'];
                Person person = Person(
                  name: photo['name'],
                  image: image != null ? image : _defaultPhoto,
                );
                persons[id] = person;
              }
              for(var i = 0; i < massages.length; i++){
                var id = massages[i]['userID'];
                var name = persons[id].name;
                var img = persons[id].image;
                var msg = massages[i]['msg'];
                print('name: ' + name + ' msg: ' + msg);
                addMessage(name, img, msg);
              }
              //_doctorLicences_value = result['doctorLicences'];
              //_handleSubmit
            }
          });
        }

      }
    });

  }

  void addMessage(String name, Image image, String text){
    ChatMessage message = new ChatMessage(
        name: name,
        image: image,
        text: text,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSubmit(String text) {
    _chatController.clear();
    sendMessage(text);
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
                icon: Icon(Icons.send, color: Colors.blue,),
                onPressed: ()=> _handleSubmit(_chatController.text),
              ),
            ),
          ],
        ),

      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: LiquidPullToRefresh(
            color:Color(0xff0277bd),
            showChildOpacityTransition: false,
            backgroundColor:Colors.white,
            onRefresh: () => getMessage(null),	// refresh callback
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
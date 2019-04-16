import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unicorndial/unicorndial.dart';
import 'package:login/config.dart' as config;

class ItemDetailPage extends StatefulWidget {
  var result;
  ItemDetailPage(this.result);
  static String tag = 'detail-related-items';
  @override
  _ItemDetailPageState createState() => new _ItemDetailPageState(result);
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  var result;

  TextStyle _text_style_type;
  static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
  static const TextStyle _text_style_description = TextStyle(backgroundColor: Colors.white, color: Colors.black26);
  bool is_editing = false;
  //var _relatedItemsURL = '';
  //var _chatURL = '';

  var _deleteURL = '';
  var _updateURL = '';

  var _title = '';
  var _titleEditable = false;
  var _subtitle = '';
  var _subtitleEditable = false;
  var _label = '';
  var _labelEditable = false;
  var _labelColor = Colors.black;
  var _datetime =  '';
  var _datetimeEditable = false;
  Image _image = Image.asset('assets/alucard.jpg', width: 200, height: 200,);
  var _details = '';
  var _detailsEditable = false;
  static const disableColor = Colors.grey;

  _ItemDetailPageState(this.result){

    //print(url);
  }

  update() async {
    JsonEncoder encoder = new JsonEncoder();
    Map json = {"title": _title, "subtitle": _subtitle, "details": _details, "datetime": _datetime};
    var url = config.baseURL + _updateURL;
    var res = http.post(url, body: encoder.convert(json))
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 401) {
        setState(() { //setState动态更新
          print("Update failed");
          is_editing = false;
          //TODO
        });
      }
      else if(response.statusCode == 200){
        Map<String, dynamic> result = jsonDecode(response.body);
        Navigator.pop(context);
      }
    });
  }

  delete() async {
    JsonEncoder encoder = new JsonEncoder();
    Map json = {"title": _title, "subtitle": _subtitle, "details": _details, "datetime": _datetime};
    var url = config.baseURL + _deleteURL;

    await http.get(url)
        .then((response) {
      if(response.statusCode == 400)
        setState(() {
          print('Delete Failed');
          //TODO
        });
      else if(response.statusCode == 200){
        Navigator.pop(context);
        if (this.mounted){
          setState(() {
          });
        }
      }
    });
  }

  parse(){
    if(result != null)
    setState(() {
      _deleteURL = result['deleteURL'];
      _updateURL = result['updateURL'];
      _title = result['title'];
      _titleEditable = result['titleEditable'];
      _subtitle = result['subtitle'];
      _subtitleEditable = result['subtitleEditable'];
      _label = result['label'];
      _labelEditable = result['labelEditable'];
      _labelColor = Color(int.parse(result['labelColor']));
      _datetime = result['datetime'];
      _datetimeEditable = result['datetimeEditable'];
      _details = result['details'];
      _detailsEditable = result['detailsEditable'];
      var _base64Imag = result['photo'];
      if(_base64Imag != ''){
        const Base64Codec base64 = Base64Codec();
        var _imageBytes = base64.decode(_base64Imag);
        _image = Image.memory(_imageBytes, width: 200, height: 200,);
      }
    });
  }

  Widget build(BuildContext context) {
    parse();

    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
          heroTag: null,
          backgroundColor:  _updateURL == '' ? disableColor :Colors.blue,
          foregroundColor: Colors.white,
          mini: true,
          child: Icon(Icons.mode_edit),
          onPressed: () {
            setState(() {
              if(_updateURL != ''){
                is_editing = true;
              }
            });
          },
        )));


    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            heroTag: null,
            backgroundColor: _deleteURL == '' ? disableColor : Colors.redAccent,
            foregroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.delete_forever),
            onPressed: () {
              if(_deleteURL != '') {
                delete();
              }

            },
        )));

    final title_row = new Row(
        children: <Widget>[
          Text('Title'),
          new Container(
            child: new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _titleEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _title,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value) {
                  setState(() {

                  });
                },
              ),
            ), //flexible
          ), //container
        ]
    );

    final subtitle_row = new Row(
        children: <Widget>[
          Text('Subtitle'),
          new Container(
            child: new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _subtitleEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _subtitle,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value) {
                  setState(() {

                  });
                },
              ),
            ), //flexible
          ), //container
        ]
    );

    final datetime_row = new Row(
        children: <Widget>[
          Text('Date Time'),
          new Container(
            child: new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _datetimeEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _datetime,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),

                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value) {
                  setState(() {

                  });
                },
              ),
            ), //flexible
          ), //container
        ]
    );

    final detail_row = new Row(
        children: <Widget>[
          Text('Detail'),
          new Container(
            child: new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _detailsEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _details,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value) {
                  setState(() {

                  });
                },
              ),
            ), //flexible
          ), //container
        ]
    );

    final editButtons = new Offstage(
      offstage: !is_editing,
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: () {

              },
              padding: EdgeInsets.all(12),
              color: Colors.lightBlueAccent,
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(width: 20,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: () {
                is_editing = false;
              },
              padding: EdgeInsets.all(12),
              color: Colors.redAccent,
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      );





    return Scaffold(
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: _labelColor,
          parentHeroTag: null,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons),
      body: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('${_label}',style: _text_style_type),
                ],
              ),
              _image,
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 30,),
                  Container(
                    width: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        title_row,
                        SizedBox(height: 10),
                        subtitle_row,
                        SizedBox(height: 10),
                        datetime_row,
                        SizedBox(height: 10),
                        detail_row,
                        SizedBox(height: 50),
                        editButtons,
                      ],
                    ),
                  ),
                ],
              ),
            ],)
      ),
    );
  }
}

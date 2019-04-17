import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login/screen/chatscreen.dart';
import 'package:login/screen/detail_related_items.dart';
import 'item_detail.dart';
import 'package:login/config.dart' as config;

class ItemPage extends StatefulWidget {
  final String detailUrl;
  ItemPage(this.detailUrl);
  static String tag = 'profile-page';
  @override
  _ItemPageState createState() => new _ItemPageState(detailUrl);
}



class _ItemPageState extends State<ItemPage> {
  static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);

  TabController _tabController;
  final String detailUrl;

  _ItemPageState(this.detailUrl){
    if(this.detailUrl != null){
      getDetail();

    }
  }
  bool _is_loading = true;
  List<Widget> tabHead = [];
  List<Widget> tabBody = [];
  static const TextStyle _text_style_description = TextStyle(backgroundColor: Colors.white, color: Colors.black26);
  bool is_editing = false;
  var _relatedItemsURL = '';
  var _chatURL = '';
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
  Map<String, dynamic> result;

  Future<Null> getDetail() async {
    await http.get(detailUrl)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400) {
        setState(() {
          _is_loading = false;
        });
      }
      else if(response.statusCode == 200){
        if (this.mounted){
          setState(() {
            result = jsonDecode(response.body);
            _labelColor = Color(int.parse(result['labelColor']));
            _relatedItemsURL = result['relatedItemsURL'];
            _chatURL = result['chatURL'];
            _is_loading = false;
          });
        }
      }
    });

  }

  List<Widget> widgetList = [];

  Widget build(BuildContext context) {
    tabHead = [];
    tabBody = [];

    final title_row = new Row(
        children: <Widget>[
          Text('Title'),
          new Container(
            child:new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _titleEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _title,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value){
                  setState(() {

                  });
                },
              ),
            ),//flexible
          ),//container
        ]
    );

    final subtitle_row  = new Row(
        children: <Widget>[
          Text('Subtitle'),
          new Container(
            child:new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _subtitleEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _subtitle,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value){
                  setState(() {

                  });
                },
              ),
            ),//flexible
          ),//container
        ]
    );

    final datetime_row = new Row(
        children: <Widget>[
          Text('Date Time'),
          new Container(
            child:new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _datetimeEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _datetime,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),

                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value){
                  setState(() {

                  });
                },
              ),
            ),//flexible
          ),//container
        ]
    );

    final detail_row = new Row(
        children: <Widget>[
          Text('Detail'),
          new Container(
            child:new Flexible(
              child: TextField(

                autofocus: false,
                enabled: _detailsEditable && is_editing,
                decoration: InputDecoration(
                  hintText: _details,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                onChanged: (String value){
                  setState(() {

                  });
                },
              ),
            ),//flexible
          ),//container
        ]
    );


    tabHead.add(Text('Detail'));
    tabBody.add(ItemDetailPage(result));

    if(_relatedItemsURL !=  ''){
      //print("aaaaaaaaaaa: " + _relatedItemsURL);
      tabHead.add(Text('Related Items'));
      tabBody.add(
        //cards page
        DetailRelatedItemsPage(_relatedItemsURL, _labelColor),
      );
    }
    if(_chatURL !=  ''){
      tabHead.add(Text('Chat'));
      tabBody.add(
        //cards page
        ChatScreen(_chatURL),
      );
    }


    final tabbar = DefaultTabController(
      length: tabBody.length,
      child: new Scaffold(
        appBar: new PreferredSize(
            preferredSize: Size.fromHeight(35),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 30,
                  color: _labelColor,
                ),
                Container(
                  child: Container(
                    height: 25,
                    color: _labelColor,
                    child: new TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      labelStyle: _textStyleWhite,
                      tabs: tabHead,
                    ),
                  ),
                )
              ],
            )
        ),
        body: TabBarView(
          children: tabBody,
        ),
      ),
    );

    Stack stack = new Stack(
      children: widgetList,
    );

    widgetList.add(tabbar);

    if (_is_loading) {
      widgetList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }
    return stack;

  }

}

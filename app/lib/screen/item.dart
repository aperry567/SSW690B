import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login/component/list_card.dart';
import 'package:login/screen/chatscreen.dart';
import 'package:login/screen/detail_related_items.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';

class ItemPage extends StatefulWidget {
  final String detailUrl;
  ItemPage(this.detailUrl);
  static String tag = 'profile-page';
  @override
  _ItemPageState createState() => new _ItemPageState(detailUrl);
}



class _ItemPageState extends State<ItemPage> {
  static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
  TextStyle _text_style_type;
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
  static const apiAddress = "http://35.207.6.9:8080";

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
        Map<String, dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            if(result['relatedItemsURL'] != null){
              _relatedItemsURL = apiAddress + result['relatedItemsURL'];
            }
            if(result['chatURL'] != null){
              _chatURL = apiAddress + result['chatURL'];
            }
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
            _text_style_type = TextStyle(backgroundColor: _labelColor, color: Colors.white,fontWeight: FontWeight.bold);
            var _base64Imag = result['photo'];
            if(_base64Imag != ''){
              const Base64Codec base64 = Base64Codec();
              var _imageBytes = base64.decode(_base64Imag);
              _image = Image.memory(_imageBytes, width: 200, height: 200,);
            }

            _is_loading = false;
          });
        }
      }
    });

  }

  Editing(){
    setState(() {
      is_editing = ! is_editing;
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
    var _fabMiniMenuItemList = [
      new FabMiniMenuItem.noText(new Icon(Icons.edit), (_titleEditable || _subtitleEditable || _labelEditable || _detailsEditable) ? Colors.cyan : Colors.grey, 6.0,
          "Button menu", Editing, false),
      new FabMiniMenuItem.noText(new Icon(Icons.delete_forever), (_titleEditable || _subtitleEditable || _labelEditable || _detailsEditable) ? Colors.cyan : Colors.grey, 6.0,
          "Button menu", getDetail, false),
    ];
    final detailTab = Tab(

      child: Card(
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
                        FabDialer(_fabMiniMenuItemList, _labelColor, new Icon(Icons.add),AnimationStyle.fadeIn),
                      ],
                    ),
                  ),




                ],
              ),
            ],)
      ),


    );

    tabHead.add(Text('Detail'));
    tabBody.add(detailTab);

    if(_relatedItemsURL !=  ''){
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

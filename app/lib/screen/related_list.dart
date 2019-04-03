import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login/component/list_card.dart';



class HomeListPage extends StatefulWidget {
  final String sessionID;
  HomeListPage(this.sessionID);
  static String tag = 'profile-page';
  @override
  _HomeListPageState createState() => new _HomeListPageState(sessionID);
}



class _HomeListPageState extends State<HomeListPage> {
  static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
  final String sessionID;
  static const apiAddress = "http://35.207.6.9:8080";
  _HomeListPageState(this.sessionID){

    getProfile();
    print(sessionID);
  }
  bool _is_loading = true;

  List<Widget> card_list = [];
  List<Widget> visit_card_list = [];
  List<Widget> exam_card_list = [];
  List<Widget> rx_card_list = [];
  String list_filter = '';

  Future<Null> getProfile() async {
    card_list = [];
    visit_card_list = [];
    exam_card_list = [];
    rx_card_list = [];
    var url = apiAddress + "/api//getPatientHomeItems?sessionID=" + sessionID + "&listFilter=" + '';
    await http.get(url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if(response.statusCode == 400) {
        setState(() {
          _is_loading = false;
        });
      }
      else if(response.statusCode == 200){
        Image _image = Image.asset('assets/logo.png', width: 100,);
        Map<String, dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            //_doctorLicences_value = result['doctorLicences'];
            var list_itesms = result['items'];
            //card_list.add(SizedBox(height: 10,));
            for(var i = 0; i < list_itesms.length; i++){
              var item = list_itesms[i];
              var _base64Imag = item['photo'];
              if(_base64Imag != null){
                const Base64Codec base64 = Base64Codec();
                var _imageBytes = base64.decode(_base64Imag);
                _image = Image.memory(_imageBytes, width: 100, height: 100,);
              }
              card_list.add(SizedBox(height: 10,));
              card_list.add(ListCard(item['label'],  item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], apiAddress + item['detailLink']));
              switch(item['label']){
                case 'Visit':
                  visit_card_list.add(SizedBox(height: 10,));
                  visit_card_list.add(ListCard(item['label'], item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], apiAddress + item['detailLink']));
                  break;
                case 'Exam':
                  exam_card_list.add(SizedBox(height: 10,));
                  exam_card_list.add(ListCard(item['label'],  item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], apiAddress + item['detailLink']));
                  break;
                case 'Rx':
                  rx_card_list.add(SizedBox(height: 10,));
                  rx_card_list.add(ListCard(item['label'],  item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], apiAddress + item['detailLink']));
                  break;
              }
            }
            _is_loading = false;
          });
        }


      }
    });

  }


  List<Widget> widgetList = [];
  Widget build(BuildContext context) {
    Stack(
      children: widgetList,
    );

    final list_view = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: card_list,
    );

    final list_view_visit = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: visit_card_list,
    );

    final list_view_exam = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: exam_card_list,
    );

    final list_view_rx = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: rx_card_list,
    );


    final liquid0 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:Colors.cyan[500],
      onRefresh: () => getProfile(),	// refresh callback
      child: list_view,		// scroll view
    );

    final liquid1 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:Colors.cyan[500],
      onRefresh: () => getProfile(),	// refresh callback
      child: list_view_visit,		// scroll view
    );

    final liquid2 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:Colors.cyan[500],
      onRefresh: () => getProfile(),	// refresh callback
      child: list_view_exam,		// scroll view
    );

    final liquid3 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:Colors.cyan[500],
      onRefresh: () => getProfile(),	// refresh callback
      child: list_view_rx,		// scroll view
    );




    final tabbar = DefaultTabController(
      length: 4,
      child: new Scaffold(
        appBar: new PreferredSize(
            preferredSize: Size.fromHeight(35),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 30,
                  color: Colors.cyan[500],
                ),
                Container(
                  child: Container(
                    height: 25,
                    color: Colors.cyan[500],
                    child: new TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      labelStyle: _textStyleWhite,
                      tabs: [
                        Tab(text: 'All'),
                        Tab(text: 'Visit'),
                        Tab(text: 'Exam'),
                        Tab(text: 'Prescription'),
                      ],
                    ),
                  ),
                )
              ],
            )
        ),
        body: TabBarView(
          children: [
            liquid0,
            liquid1,
            liquid2,
            liquid3,
          ],
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

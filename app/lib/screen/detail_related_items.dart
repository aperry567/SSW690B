import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login/component/list_card.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:login/config.dart' as config;


class DetailRelatedItemsPage extends StatefulWidget {
  final String url;
  final _labelColor;
  DetailRelatedItemsPage(this.url, this._labelColor);
  static String tag = 'detail-related-items';
  @override
  _DetailRelatedItemsPageState createState() => new _DetailRelatedItemsPageState(url,_labelColor);
}



class _DetailRelatedItemsPageState extends State<DetailRelatedItemsPage> {
  static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
  final String url;
  final _labelColor;
  _DetailRelatedItemsPageState(this.url, this._labelColor){
    getDetail();
    //print(url);
  }
  bool _is_loading = true;

  List<Widget> card_list = [];
  List<Widget> visit_card_list = [];
  List<Widget> exam_card_list = [];
  List<Widget> rx_card_list = [];
  String list_filter = '';
  var _updateURL = '';

  Future<Null> getDetail() async {
    card_list = [];
    visit_card_list = [];
    exam_card_list = [];
    rx_card_list = [];

    await http.get(url)
        .then((response) {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
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
            _updateURL = result['updateURL'];
            var list_itesms = result['items'];
            //card_list.add(SizedBox(height: 10,));
            for(var i = 0; i < list_itesms.length; i++){
              var item = list_itesms[i];
              var _base64Imag = item['photo'];
              if(_base64Imag != null){
                const Base64Codec base64 = Base64Codec();
                var _imageBytes = base64.decode(_base64Imag);
                _image = Image.memory(_imageBytes, width: 100);
              }
              card_list.add(SizedBox(height: 10,));
              card_list.add(ListCard(item['label'], item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], config.baseURL + item['detailLink'], item['screenType']));
              switch(item['label']){
                case 'Visit':
                  visit_card_list.add(SizedBox(height: 10,));
                  visit_card_list.add(ListCard(item['label'], item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], config.baseURL + item['detailLink'], item['screenType']));
                  break;
                case 'Exam':
                  exam_card_list.add(SizedBox(height: 10,));
                  exam_card_list.add(ListCard(item['label'], item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], config.baseURL + item['detailLink'], item['screenType']));
                  break;
                case 'Rx':
                  rx_card_list.add(SizedBox(height: 10,));
                  rx_card_list.add(ListCard(item['label'], item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], config.baseURL + item['detailLink'], item['screenType']));
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
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Prescription",
        currentButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          mini: true,
          child: Icon(Icons.description),
          onPressed: () {

          },
        )));


    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Exam",
        currentButton: FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.airline_seat_flat_angled))));

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
      color:_labelColor,
      onRefresh: () => getDetail(),	// refresh callback
      child: list_view,		// scroll view
    );

    final liquid1 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:_labelColor,
      onRefresh: () => getDetail(),	// refresh callback
      child: list_view_visit,		// scroll view
    );

    final liquid2 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:_labelColor,
      onRefresh: () => getDetail(),	// refresh callback
      child: list_view_exam,		// scroll view
    );

    final liquid3 = LiquidPullToRefresh(
      showChildOpacityTransition: false,
      color:_labelColor,
      onRefresh: () => getDetail(),	// refresh callback
      child: list_view_rx,		// scroll view
    );





    final tabbar = DefaultTabController(
      length: 4,
      child: new Scaffold(
        floatingActionButton: UnicornDialer(
            //onMainButtonPressed: ,
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
            parentButtonBackground: _updateURL == '' ? Colors.grey : _labelColor,
            parentHeroTag: null,
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.add),
            childButtons: childButtons),
        appBar: new PreferredSize(
            preferredSize: Size.fromHeight(35),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Container(
                    height: 25,
                    color: _labelColor,
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

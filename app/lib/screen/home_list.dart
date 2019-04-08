import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login/component/list_card.dart';
import 'package:login/models/list_response.dart';

class _HomePageListContainer extends StatefulWidget {
  final String url;
  
  _HomePageListContainer(
    this.url
  ) : super(key: ValueKey([url]));
  static String tag = 'profile-page';

  @override
  _HomePageListContainerState createState() => new _HomePageListContainerState(url);
}

class _HomePageListContainerState extends State<_HomePageListContainer> {
  final String url;
  bool isLoading = true;
  ListResponse list; 

  Image defaultImg = Image.asset('assets/alucard.jpg', width: 100,height: 100,fit: BoxFit.fill,);

  static const apiAddress = "http://35.207.6.9:8080";

  _HomePageListContainerState(this.url){
    loadFeed();
    print("_homepage List - " + this.url);
  }

  Future<Null> loadFeed() async {
    await http.get(this.url)
        .then((response) {
      print("_homepage List - Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");
      if(response.statusCode == 400) {
        setState(() {
          isLoading = false;
        });
      }
      else if(response.statusCode == 200){
        Map<String, dynamic> result = jsonDecode(response.body);
        if (this.mounted){
          setState(() {
            isLoading = false;
            list = ListResponse.fromJson(result);
          });
        }
      }
    });
  }

  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    List<Widget> cardList = [];
    if (list != null) {
      print("building this thing");
      var listItems = list.items;
      cardList.add(SizedBox(height: 10,));
      for(var i = 0; i < listItems.length; i++){
        var item = listItems[i];
        var _base64Imag = item.photo;
        Image _image = defaultImg;
        if(_base64Imag != ""){
          const Base64Codec base64 = Base64Codec();
          var _imageBytes = base64.decode(_base64Imag);
          _image = Image.memory(_imageBytes, width: 100, height: 100,fit: BoxFit.fill,);
        }
        cardList.add(SizedBox(height: 10,));
        cardList.add(ListCard(item.label,  item.dateTime, item.title, item.subtitle, item.details, _image,item.labelColor, apiAddress + item.detailLink));
      }
    }
    var listView = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: cardList,

    );
    widgetList.add(LiquidPullToRefresh(
      showChildOpacityTransition: false,
      backgroundColor: Colors.red,
      color:Colors.cyan[500],
      height: 500,
      onRefresh: () => loadFeed(),	// refresh callback
      child: listView,		// scroll view
    ));
    widgetList.add(listView);
    Stack stack = new Stack(
      children: widgetList,
    );
    if (isLoading) {
      widgetList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

    return stack;
  }
}

class HomeListPage extends StatefulWidget {
  final String url;
  
  HomeListPage(
    this.url
  ) : super(key: ValueKey([url])) {
    print('==================');
  }
  static String tag = 'profile-page';

  @override
  _HomeListPageState createState() => new _HomeListPageState(url);
}

class _HomeListPageState extends State<HomeListPage> {
    static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
    final String apiURL;
    static const apiAddress = "http://35.207.6.9:8080";
    _HomeListPageState(this.apiURL){
      getProfile();
      print(apiURL);
    }
    bool _is_loading = true;

    DefaultTabController tabbar;
    ListResponse list;
    String url = "";

    Future<Null> getProfile() async {
      url = apiAddress + apiURL;
      await http.get(url)
            .then((response) {
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          if(response.statusCode == 400) {
            setState(() {
              _is_loading = false;
            });
          } else if(response.statusCode == 200){
            Map<String, dynamic> result = jsonDecode(response.body);
            if (this.mounted){
              setState(() {
                list = ListResponse.fromJson(result);
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

      List<Tab> tabs = [];
      List<Widget> tabViews = [];
      if (list != null){
        tabs.add(Tab(text: 'All'));
        // tabs.add(Tab(text: 'Visit'));
        // tabs.add(Tab(text: 'Exam'));
        // tabs.add(Tab(text: 'Prescription'));

        tabViews.add(_HomePageListContainer(url + "&" + list.filters[0].value));
        // tabViews.add(_HomePageListContainer(url + "&" + list.filters[1].value));
        // tabViews.add(_HomePageListContainer(url + "&" + list.filters[2].value));
        // tabViews.add(_HomePageListContainer(url + "&" + list.filters[3].value));
      }
      tabbar = DefaultTabController(
        length: tabViews.length,
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
                      tabs: tabs,
                    ),
                  ),
                )
              ],
            )
          ),
          body: TabBarView(
            children: tabViews,
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

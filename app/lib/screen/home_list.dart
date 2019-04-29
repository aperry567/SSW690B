import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login/component/list_card.dart';
import 'package:login/models/list_response.dart';
import 'package:login/config.dart' as config;
import 'package:unicorndial/unicorndial.dart';

class _HomePageListContainer extends StatefulWidget {
  final String url;
  
  _HomePageListContainer(
    this.url
  ) : super(key: ValueKey([url]));


  @override
  _HomePageListContainerState createState() => new _HomePageListContainerState(url);
}

class _HomePageListContainerState extends State<_HomePageListContainer> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final String url;
  bool isLoading = true;
  ListResponse list; 

  Image defaultImg = Image.asset('assets/alucard.jpg', width: 100,height: 100,fit: BoxFit.fill,);

  _HomePageListContainerState(this.url){
    loadFeed();
    //print("_homepage List - " + this.url);
  }

  Future<Null> loadFeed() async {
    await http.get(this.url)
        .then((response) {
      //print("_homepage List - Response status: ${response.statusCode}");
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
      var listItems = list.items;

      cardList.add(SizedBox(height: 10,));
      for(var i = 0; i < listItems.length; i++){
        var item = listItems[i];
        var _base64Imag = item.photo;
        Image _image = defaultImg;
        if(_base64Imag != ""){
          const Base64Codec base64 = Base64Codec();
          var _imageBytes = base64.decode(_base64Imag);
          _image = Image.memory(_imageBytes, width: 100, height: 100, fit: BoxFit.none, alignment: Alignment.topCenter,);
        }
        cardList.add(SizedBox(height: 10,));
        cardList.add(ListCard(item.label,  item.dateTime, item.title, item.subtitle, item.details, _image,item.labelColor, config.baseURL + item.detailLink, item.screenType));
      }
    }
    var listView = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: cardList,

    );
    widgetList.add(LiquidPullToRefresh(
      showChildOpacityTransition: false,
      backgroundColor: Colors.white,
      color:Colors.cyan[500],
      onRefresh: () => loadFeed(),	// refresh callback
      child: listView,		// scroll view
      )
    );
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
  final bool isTopScreen;
  final labelColor;
  
  HomeListPage(
    this.url,
    this.isTopScreen,
    this.labelColor
  ) : super(key: ValueKey([url]));
  static String tag = 'profile-page';

  @override
  _HomeListPageState createState() => new _HomeListPageState(url, isTopScreen, labelColor);
}

class _HomeListPageState extends State<HomeListPage> {
    static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
    final String apiURL;
    final bool isTopScreen;
    double spacerHeight = 10;
    double tabHeight = 30;
    final labelColor;
    final _formKey = GlobalKey<FormState>();

    _HomeListPageState(this.apiURL, this.isTopScreen, this.labelColor){
      getHomeItem();
      print(apiURL);
      if (this.isTopScreen) {
        spacerHeight = 30;
        tabHeight = 40;
      }
    }
    bool _is_loading = true;

    DefaultTabController tabbar;
    ListResponse list;
    String url = "";

    Future<Null> getHomeItem() async {
      url = config.baseURL + apiURL;
      await http.get(url)
          .then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        if(response.statusCode == 400) {
          setState(() {
            _is_loading = false;
          });
        } else if(response.statusCode == 200){
          // print(response.body);
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

    String addItemResponseError = "";
    Future<Null> addItem(addURL) async {
      var url = config.baseURL + addURL;
      print(url);
      print(addItemData['title']);
      JsonEncoder encoder = new JsonEncoder();
      await http.post(url, body: encoder.convert(addItemData))
          .then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        if(response.statusCode == 400) {
          addItemResponseError = response.body;
          _formKey.currentState.validate();
          print("Item Detail Save Error: " + response.body);
        } else if (response.statusCode == 200) {
          getHomeItem();
          Navigator.pop(_formKey.currentContext);
        }
      });
    }

    Map<String, String> addItemData = new Map<String, String>();
    List<Widget> widgetList = [];
    Widget build(BuildContext context) {
      Stack(
        children: widgetList,
      );

      List<Tab> tabs = [];
      List<Widget> tabViews = [];
      List<ListFilter> addItems = [];
      
      List<UnicornButton> childButtons = [];
      if (list != null){
        for(var filter in list.filters){
          tabs.add(Tab(text: filter.title));
          tabViews.add(_HomePageListContainer(url + "&" + filter.value));
          if (filter.addURL != "" && filter.addDetails != null) {
            addItems.add(filter);
            childButtons.add(UnicornButton(
              hasLabel: true,
              labelText: filter.title,
              currentButton: FloatingActionButton(
                heroTag: null,
                backgroundColor: labelColor,
                foregroundColor: Colors.white,
                mini: true,
                child: Icon(Icons.description),
                onPressed: () {
                  addItemData = new Map<String,String>();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      print("builder called");
                      List<Widget> formItems = [];
                      
                      formItems.add(Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                          child: FormField(
                            builder: (FormFieldState<String> field) {
                              String err = addItemResponseError;
                              if (err != "") {
                                err = "Error: " + err;
                              }
                              return Text(err, style: TextStyle(color: Colors.red));
                            }
                          ),
                      ));

                      for (var formDetail in filter.addDetails) {
                        formItems.add(Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                          child: Text(formDetail.label),
                        ));
                        formItems.add(Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                          child: TextFormField(
                            autocorrect: true,
                            autofocus: false,
                            validator: (value) {
                              if (value == "") {
                                return "Cannot be blank";
                              }
                              return null;
                            },
                            onSaved: (value) => addItemData[formDetail.fieldName] = value,
                          ),
                        ));
                      }
                      formItems.add(Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              print("Adding Item: " + filter.title);
                              _formKey.currentState.save();
                              addItem(filter.addURL);
                            }
                          },
                          padding: EdgeInsets.all(12),
                          color: Colors.lightBlueAccent,
                          child: Text('Add', style: TextStyle(color: Colors.white)),
                        )
                      ));
                      return AlertDialog(
                        content: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: formItems
                          ),
                        ),
                      );
                    }
                  );
                },
              )
            ));
          }
        }
      }
      UnicornDialer buttons;
      if (childButtons.length > 0) {
        buttons = UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: labelColor,
          parentHeroTag: null,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons,
        );
      }
      tabbar = DefaultTabController(
        length: tabViews.length,
        child: new Scaffold(
          floatingActionButton: buttons,
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(60),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: spacerHeight,
                  color: labelColor,
                ),
                Container(
                  child: Container(
                    height: tabHeight,
                    color: labelColor,
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

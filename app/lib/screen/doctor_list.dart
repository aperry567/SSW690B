import 'package:flutter/material.dart';
import 'package:login/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:login/component/enum_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login/component/list_card.dart';
import 'package:login/config.dart' as config;


class DoctorListPage extends StatefulWidget {
  String url;
  DoctorListPage(this.url);

  @override
  _DoctorListPageState createState() => new _DoctorListPageState();
}



class _DoctorListPageState extends State<DoctorListPage> {
  static const TextStyle _textStyleWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
  static const apiAddress = "http://35.207.6.9:8080";
  _DoctorListPageState(){

  }
  initState(){
    getDoctor();
  }

  List<Widget> card_list = [];


  Future<Null> getDoctor() async {
    card_list = [];

    await http.get(widget.url)
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if(response.statusCode == 400) {

      }
      else if(response.statusCode == 200){
        Image _image = Image.asset('assets/alucard.jpg', width: 100,height: 100,fit: BoxFit.fill,);
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
                _image = Image.memory(_imageBytes, width: 100, height: 100,fit: BoxFit.fill,);
              }
              card_list.add(SizedBox(height: 10,));
              card_list.add(ListCard(item['label'],  item['dateTime'], item['title'], item['subtitle'], item['details'], _image,item['labelColor'], config.baseURL + item['detailLink'], item['screenType'], false));
              print('add cards');
              //print(item['label']);
            }
          });
        }


      }
    });
  }

  Widget build(BuildContext context) {
    print('build');
    final list_view = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: card_list,
    );


    final liquid0 = LiquidPullToRefresh(

      showChildOpacityTransition: false,
      color:Colors.cyan[500],
      onRefresh: () => getDoctor(),	// refresh callback
      child: list_view,		// scroll view
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor List'),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: card_list,
      ),
    );

  }

}

import 'package:flutter/material.dart';
import 'package:login/screen/chatscreen.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:login/payment/mainPay.dart';

class PaymentPage extends StatelessWidget {
  final sessionID;
  PaymentPage(this.sessionID);
  // This widget is the root of your application.
  @override


  Widget build(BuildContext context) {
    return new Scaffold(

        body: HomeScreen(),
    );
  }
}
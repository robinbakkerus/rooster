import 'package:flutter/material.dart';

class WidgetHelper {
  WidgetHelper._();
  static final WidgetHelper instance = WidgetHelper._();

  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  Widget horSpace(double h) {
    return Container(
      width: h,
    );
  }

  Widget verSpace(double w) {
    return Container(
      height: w,
    );
  }

  void showSnackbar(String msg,
      {Color color = Colors.lightBlue, int seconds = 3}) {
    SnackBar snackBar = SnackBar(
        backgroundColor: color,
        content: Text(msg),
        duration: Duration(seconds: seconds));

    scaffoldKey.currentState?.showSnackBar(snackBar);
  }
}

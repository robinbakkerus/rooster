import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';

class WH {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static const Color color1 = Color(0xffF4E9CA);
  static const Color color2 = Color(0xffA6CD7A);
  static const Color color3 = Color(0xffF6AB94);

  static final double w1 = 0.1 * AppData.instance.screenWidth;
  static final double w2 = 0.2 * AppData.instance.screenWidth;
  static final double w12 = 0.12 * AppData.instance.screenWidth;
  static final double w15 = 0.15 * AppData.instance.screenWidth;
  static final double w25 = 0.25 * AppData.instance.screenWidth;

  static const String removeExtraSpreadsheetRow = 'REMOVE EXTRA ROW';

  static Widget horSpace(double h) {
    return Container(
      width: h,
    );
  }

  static Widget verSpace(double w) {
    return Container(
      height: w,
    );
  }

  static void showSnackbar(String msg,
      {Color color = Colors.lightBlue, int seconds = 3}) {
    SnackBar snackBar = SnackBar(
        backgroundColor: color,
        content: Text(msg),
        duration: Duration(seconds: seconds));

    scaffoldKey.currentState?.showSnackBar(snackBar);
  }
}

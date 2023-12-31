import 'package:flutter/material.dart';

class WidgetHelper {
  final Color color1 = const Color(0xffF4E9CA);
  final Color color2 = const Color(0xffA6CD7A);
  final Color color3 = const Color(0xffF6AB94);

  SnackBar buildSnackbar({required String text, Color? color}) {
    Color useColor = color ?? Colors.lightBlue;

    return SnackBar(
      backgroundColor: useColor,
      content: Text(text),
      duration: const Duration(seconds: 2),
    );
  }

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

  void showSnackbar(BuildContext context, String msg, {Color? inputColor}) {
    Color color = inputColor ?? Colors.lightBlue;

    ScaffoldMessenger.of(context)
        .showSnackBar(WidgetHelper().buildSnackbar(text: msg, color: color));
  }
}

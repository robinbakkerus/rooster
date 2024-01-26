import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';

class AppConstants {
  final Color lightYellow = const Color(0xffF4E9CA);
  final Color lightGeen = const Color(0xffE3ECE3);
  final Color lightRed = const Color(0xffF6AB94);
  final Color lightblue = const Color(0xffBFD9EE);
  final Color lightOrange = const Color(0xffF3EFE3);
  final Color lightBrown = const Color(0xffEDEAE9);

  final double w1 = 0.1 * AppData.instance.screenWidth;
  final double w2 = 0.2 * AppData.instance.screenWidth;
  final double w12 = 0.12 * AppData.instance.screenWidth;
  final double w15 = 0.15 * AppData.instance.screenWidth;
  final double w25 = 0.25 * AppData.instance.screenWidth;

  final String removeExtraSpreadsheetRow = 'REMOVE EXTRA ROW';

  final String localNL = 'nl_NL';
  final String localUK = 'en_US';

  final String zamoGroup = 'zamo';
  final String summerGroep = 'zomer_training';
}

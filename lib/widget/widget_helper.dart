import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/util/app_constants.dart';

class WidgetHelper {
  WidgetHelper._();
  static final WidgetHelper instance = WidgetHelper._();

  final AppConstants c = AppConstants();

  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  ///--------------------------------------
  Widget horSpace(double h) {
    return SizedBox(
      width: h,
    );
  }

  Widget verSpace(double w) {
    return SizedBox(
      height: w,
    );
  }

  ///-------------------------------
  void showSnackbar(String msg,
      {Color color = Colors.lightBlue, int seconds = 3}) {
    if (msg != AppData.instance.lastSnackbarMsg) {
      SnackBar snackBar = SnackBar(
          backgroundColor: color,
          content: Text(msg),
          duration: Duration(seconds: seconds));

      scaffoldKey.currentState?.showSnackBar(snackBar);
      AppData.instance.lastSnackbarMsg = msg;
    }
  }

  ///--------------------------------------
  List<DataColumn> buildYesNoIfNeededHeader() {
    List<DataColumn> result = [];

    var headerLabels = ['Dag', 'Ja', 'Nee', 'Als nodig'];
    var colors = [Colors.black, Colors.green, Colors.red, Colors.brown];

    for (int i = 0; i < headerLabels.length; i++) {
      result.add(DataColumn(
          label: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
        child: Text(headerLabels[i],
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: colors[i])),
      )));
    }
    return result;
  }

  ///-----------------------------
  MaterialStateColor getDaySchemaRowColor(int dateIndex) {
    MaterialStateColor col =
        MaterialStateColor.resolveWith((states) => Colors.white);

    DateTime date = AppData.instance.getActiveDates()[dateIndex];

    if (date.weekday == DateTime.tuesday) {
      col = MaterialStateColor.resolveWith((states) => c.lightGeen);
    } else if (date.weekday == DateTime.thursday) {
      col = MaterialStateColor.resolveWith((states) => c.lightOrange);
    } else if (date.weekday == DateTime.saturday) {
      col = MaterialStateColor.resolveWith((states) => c.lightBrown);
    }

    return col;
  }
}

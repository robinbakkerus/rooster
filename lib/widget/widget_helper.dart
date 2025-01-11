import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_constants.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:rooster/widget/radiobutton_widget.dart';
// import 'package:soundpool/soundpool.dart';

class WidgetHelper {
  WidgetHelper._();
  static final WidgetHelper instance = WidgetHelper._();

  final AppConstants c = AppConstants();

  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  // final Soundpool _soundPool = Soundpool.fromOptions();
  // late ByteData _soundAsset;
  // final int _soundId = 0;

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
    SnackBar snackBar = SnackBar(
        backgroundColor: color,
        content: Text(msg),
        duration: Duration(seconds: seconds));

    scaffoldKey.currentState?.showSnackBar(snackBar);
    AppData.instance.lastSnackbarMsg = msg;
  }

  ///--------------------------------------
  List<DataColumn> buildYesNoIfNeededHeader(String label) {
    List<DataColumn> result = [];

    var headerLabels = [label, 'Ja', 'Nee', 'Als nodig'];
    var colors = [Colors.black, Colors.black, Colors.red, Colors.brown];

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
  WidgetStateColor getDaySchemaRowColor(int dateIndex) {
    WidgetStateColor col =
        WidgetStateColor.resolveWith((states) => Colors.white);

    DateTime date = AppData.instance.getActiveDates()[dateIndex];

    if (date.weekday == DateTime.tuesday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuDinsDag);
    } else if (date.weekday == DateTime.thursday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuDonderDag);
    } else if (date.weekday == DateTime.saturday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuZaterDag);
    }

    return col;
  }

  //--------------------------------
  void showConfirmDialog(BuildContext context,
      {required String title,
      required String content,
      Function? yesFunction,
      Function? noFunction}) async {
    Widget noButton = _buildYesNoButton(context, 'Nee', Colors.red, false);
    Widget yesButton = _buildYesNoButton(context, 'Ja', Colors.green, true);

    AlertDialog alert = _buildAlertDialog(
        title: title,
        content: content,
        yesButton: yesButton,
        noButton: noButton);
    bool dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    if (dialogResult == true && yesFunction != null) {
      yesFunction();
    } else if (dialogResult == false && noFunction != null) {
      noFunction();
    }
  }

//------------------------------------------
  void pushPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

//------------------------------------------
  void popPage(BuildContext context) {
    Navigator.pop(
      context,
    );
  }

//-----------------------------------------------
  Widget popPageButton(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () => popPage(context),
        icon: const Icon(Icons.home),
        label: const Text('Terug'));
  }

//------------------------------------------
  AppBar adminPageAppBar(BuildContext context, String title) {
    Color color = AppData.instance.runMode == RunMode.prod
        ? Colors.lightBlue[200]!
        : Colors.yellow;
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: color,
      leading: IconButton.filled(
          onPressed: () => popPage(context),
          icon: const Icon(Icons.arrow_back)),
    );
  }

//----------------------------------
  AlertDialog _buildAlertDialog(
      {required String title,
      required String content,
      required Widget yesButton,
      required Widget noButton}) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
          ],
        ),
      ),
      actions: [
        yesButton,
        noButton,
      ],
    );
  }

  //--------------------------------
  Widget _buildYesNoButton(
      BuildContext context, String text, Color color, bool result) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context, result);
      },
      child: Text(
        text,
        style: TextStyle(color: color),
      ),
    );
  }

  ///----------------------------------------------------------------
  void playWhooshSound() async {
    // if (_soundId == 0) {
    //   _soundAsset = await rootBundle.load("sounds/whoosh.mp3");
    //   _soundId = await _soundPool.load(_soundAsset);
    // }

    // await _soundPool.play(_soundId);
  }

  //-------------- prefdays & prefgroups ------------------------------
  Widget buildGridForPrefDays(
      {required Trainer trainer, bool viewOnly = false}) {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 24,
            horizontalMargin: 10,
            headingRowColor:
                WidgetStateColor.resolveWith((states) => c.lightblue),
            columnSpacing: colSpace,
            dataRowMinHeight: 20,
            dataRowMaxHeight: 30,
            columns: buildYesNoIfNeededHeader('Dag'),
            rows:
                _buildDataRowsForPrefDays(trainer: trainer, viewOnly: viewOnly),
          ),
        ),
      ),
    );
  }

  ///------------------------------------------------
  Widget buildGridForPrefGroups(
      {required Trainer trainer, bool viewOnly = false}) {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 24,
            horizontalMargin: 10,
            headingRowColor:
                WidgetStateColor.resolveWith((states) => c.lightblue),
            columnSpacing: colSpace,
            dataRowMinHeight: 20,
            dataRowMaxHeight: 30,
            columns: buildYesNoIfNeededHeader('Groep'),
            rows: _buildDataRowsForPrefGroups(
                trainer: trainer, viewOnly: viewOnly),
          ),
        ),
      ),
    );
  }

  //-------------------------
  List<DataRow> _buildDataRowsForPrefDays(
      {required Trainer trainer, bool viewOnly = false}) {
    List<DataRow> result = [];

    var days = SpreadsheetGenerator.instance.getTrainingDays(locale: c.localNL);

    for (String dag in days) {
      result.add(DataRow(
          cells: _buildDataCellsForPrefs(
              trainer: trainer, paramName: dag, viewOnly: viewOnly)));
    }

    return result;
  }

  //-------------------------
  List<DataRow> _buildDataRowsForPrefGroups(
      {required Trainer trainer, bool viewOnly = false}) {
    List<DataRow> result = [];

    var groupNames =
        AppData.instance.trainingGroups.map((e) => e.name).toList();

    for (String groupName in groupNames) {
      result.add(DataRow(
          cells: _buildDataCellsForPrefs(
              trainer: trainer, paramName: groupName, viewOnly: viewOnly)));
    }

    return result;
  }

  //-------------------------
  List<DataCell> _buildDataCellsForPrefs(
      {required Trainer trainer,
      required String paramName,
      bool viewOnly = false}) {
    List<DataCell> result = [];

    result.add(DataCell(Text(paramName)));
    result.add(_buildRadioButtonDataCell(
        trainer, paramName, 1, Colors.green, viewOnly));
    result.add(
        _buildRadioButtonDataCell(trainer, paramName, 0, Colors.red, viewOnly));
    result.add(_buildRadioButtonDataCell(
        trainer, paramName, 2, Colors.brown, viewOnly));

    return result;
  }

  //-------------------------
  DataCell _buildRadioButtonDataCell(Trainer trainer, String paramName,
      int rbValue, Color color, bool viewOnly) {
    int value = trainer.getPrefValue(paramName: paramName);
    return DataCell(RadioButtonWidget.forPreference(
      key: UniqueKey(),
      rbValue: rbValue,
      color: color,
      paramName: paramName,
      value: value,
      isEditable: !viewOnly,
    ));
  }
}

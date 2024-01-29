import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:rooster/widget/spreadsheet_extra_day_field.dart';
import 'package:rooster/widget/spreadsheet_trainer_field.dart';
import 'package:rooster/widget/spreadsheet_training_field.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  State<SpreadsheetPage> createState() => _SpreadsheetPageState();
}

//-------------------
class _SpreadsheetPageState extends State<SpreadsheetPage> with AppMixin {
  SpreadSheet _spreadSheet = SpreadSheet(
      year: AppData.instance.getActiveYear(),
      month: AppData.instance.getActiveMonth());

  Widget _dataGrid = Container();
  int _headerLength = 0;

  _SpreadsheetPageState();

  @override
  void initState() {
    AppEvents.onSpreadsheetReadyEvent(_onReady);
    AppEvents.onTrainingUpdatedEvent(_onTrainingUpdated);
    AppEvents.onExtraDayUpdatedEvent(_onExtraDayUpdated);
    AppEvents.onSpreadsheetTrainerUpdatedEvent(_onSpreadTrainerUpdated);

    _spreadSheet = AppData.instance.getSpreadsheet();
    _dataGrid = _buildGrid();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  //---------------------------------
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        child: _dataGrid,
        // wh.verSpace(10),
        // _buildButtons(),
        // ],
      ),
    );
  }

  //--------------------------------
  Widget? _buildFab() {
    if (AppData.instance.spreadSheetStatus == SpreadsheetStatus.dirty) {
      return FloatingActionButton(
        onPressed: _saveSpreadsheetMutations,
        hoverColor: Colors.greenAccent,
        child: const Text('Save'),
      );
    } else {
      return null;
    }
  }

  //-----------------------
  bool _isEditable() {
    return (AppData.instance.spreadSheetStatus == SpreadsheetStatus.opened ||
        AppData.instance.spreadSheetStatus == SpreadsheetStatus.dirty ||
        (AppData.instance.spreadSheetStatus == SpreadsheetStatus.initial &&
            AppData.instance.getTrainer().isSupervisor()));
  }

  //--------------------------------
  bool _isSupervisor() {
    return AppData.instance.getTrainer().isSupervisor();
  }

  //--------------------------------------------------------
  Widget _buildGrid() {
    return ListView.builder(
      itemCount: AppData.instance.activeTrainingGroups.length + 1,
      itemBuilder: (context, index) => _buildListViewItem(context, index),
    );
  }

  //--------------------------------
  Widget _buildListViewItem(BuildContext context, int index) {
    if (index < AppData.instance.activeTrainingGroups.length) {
      return _buildDataTable(context, index);
    } else {
      return _buildButtons();
    }
  }

//--------------------------------
  Widget _buildDataTable(BuildContext context, int index) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    DateTime date = AppData.instance.activeTrainingGroups[index].startDate;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: MaterialStateColor.resolveWith((states) => c.lightblue),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: _buildHeader(date),
      rows: _buildDataRows(index),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader(DateTime date) {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('Dag', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label:
            Text('Training', style: TextStyle(fontStyle: FontStyle.italic))));

    for (String groupName
        in SpreadsheetGenerator.instance.getGroupNames(date)) {
      result.add(DataColumn(
          label: Text(groupName,
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }

    _headerLength = result.length;
    return result;
  }

  List<DataRow> _buildDataRows(int index) {
    List<DataRow> result = [];

    _spreadSheet.rows.sort((a, b) => a.date.compareTo(b.date));
    DateTime startDate = AppData.instance.activeTrainingGroups[index].startDate;
    DateTime endDate = AppData.instance.activeTrainingGroups[index].endDate!;

    for (SheetRow fsRow in _spreadSheet.rows) {
      if (fsRow.date.isAfter(endDate) || fsRow.date.isBefore(startDate)) {
        continue;
      }

      MaterialStateColor col =
          MaterialStateColor.resolveWith((states) => Colors.white);
      if (fsRow.isExtraRow) {
        col = MaterialStateColor.resolveWith((states) => Colors.white);
      } else if (fsRow.date.weekday == DateTime.tuesday) {
        col = MaterialStateColor.resolveWith((states) => c.lightGeen);
      } else if (fsRow.date.weekday == DateTime.thursday) {
        col = MaterialStateColor.resolveWith((states) => c.lightOrange);
      } else if (fsRow.date.weekday == DateTime.saturday) {
        col = MaterialStateColor.resolveWith((states) => c.lightBrown);
      }

      List<DataCell> cells = _buildDataCells(fsRow);
      if (cells.length != _headerLength) {
        lp('todo error in _buildDataRows');
      }
      DataRow dataRow = DataRow(cells: cells, color: col);
      result.add(dataRow);
    }

    return result;
  }

  List<DataCell> _buildDataCells(SheetRow row) {
    List<DataCell> result = [];

    result.add(_buildDayCell(row));
    result.add(_buildTrainingCell(row));

    List<String> groupNames =
        SpreadsheetGenerator.instance.getGroupNames(row.date);

    if (!row.isExtraRow) {
      for (int i = 0; i < groupNames.length; i++) {
        result.add(_buildTrainerCell(row, groupNames[i]));
      }
    } else {
      for (int i = 0; i < groupNames.length; i++) {
        result.add(const DataCell(Text('')));
      }
    }

    return result;
  }

  DataCell _buildTrainerCell(SheetRow sheetRow, String groupName) {
    return DataCell(SpreadsheetTrainerColumn(
        key: UniqueKey(),
        sheetRow: sheetRow,
        groupName: groupName,
        isEditable: _isEditable()));
  }

  DataCell _buildDayCell(SheetRow sheetRow) {
    return DataCell(SpreadsheetDayColumn(key: UniqueKey(), sheetRow: sheetRow));
  }

  DataCell _buildTrainingCell(SheetRow sheetRow) {
    double w = AppHelper.instance.isWindows() || AppHelper.instance.isTablet()
        ? 200
        : 80;
    return DataCell(Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.1, color: Colors.grey)),
        width: w,
        child: SpreadsheetTrainingColumn(
          key: UniqueKey(),
          sheetRow: sheetRow,
          isEditable: _isEditable(),
        )));
  }

  Widget _buildButtons() {
    return Column(
      children: [
        wh.verSpace(10),
        Row(
          children: [
            wh.horSpace(10),
            InkWell(
                onTap: _onShowSpreadsheetInfo,
                child: const Icon(
                  Icons.info_outline,
                  size: 32,
                  color: Colors.lightBlue,
                )),
            wh.horSpace(20),
            _buildActionButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (AppData.instance.spreadSheetStatus == SpreadsheetStatus.initial) {
      return _buildActionButtonsNewSpreadsheet();
    } else {
      return _buildActionButtonPublishedSpreadsheet();
    }
  }

  Widget _buildActionButtonsNewSpreadsheet() {
    if (_isSupervisor()) {
      return OutlinedButton(
          onPressed: _onConfirmFinalizeSpreadsheet,
          child: const Text('Maak schema definitief'));
    } else {
      return Container();
    }
  }

  Widget _buildActionButtonPublishedSpreadsheet() {
    if (AppData.instance.spreadSheetStatus == SpreadsheetStatus.active) {
      return OutlinedButton(
          onPressed: _buildDialogOpenSpreadsheet,
          child: const Text('Maak schema open voor wijziging(en)'));
    } else {
      return Container();
    }
  }

  ///--------------------------------------------------------
  void _onShowSpreadsheetInfo() {
    _buildDialogSpreadsheetInfo(context);
  }

  void _onConfirmFinalizeSpreadsheet() {
    _buildDialogConfirm(context, _areProgramFieldSet());
  }

  void _saveSpreadsheetMutations() async {
    await AppController.instance.updateSpreadsheet(_spreadSheet);
    AppData.instance.spreadSheetStatus =
        AppData.instance.getOriginalpreadsheet().isFinal
            ? SpreadsheetStatus.active
            : SpreadsheetStatus.initial;
    wh.showSnackbar('Wijzigingen zijn doorgevoerd', color: Colors.lightGreen);
    AppEvents.fireSpreadsheetReady();
  }

  void _makeSpreadsheetFinal(BuildContext context) async {
    AppController.instance.finalizeSpreadsheet(_spreadSheet);
    AppData.instance.spreadSheetStatus = SpreadsheetStatus.active;
    AppEvents.fireSpreadsheetReady();
    wh.showSnackbar('Training schema is nu definitief!');
  }

  void _buildDialogSpreadsheetInfo(BuildContext context) {
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("CLose"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Trainer inzet."),
      content: Text(_getTrainerDeployed()),
      actions: [
        closeButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //--------------------------------
  void _buildDialogOpenSpreadsheet() async {
    Widget noButton = _buildYesNoButton('Nee', Colors.red, false);
    Widget yesButton = _buildYesNoButton('Ja', Colors.green, true);

    AlertDialog alert =
        _buildAlertDialog(yesButton: yesButton, noButton: noButton);
    bool dialogResult = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    setState(() {
      if (dialogResult == true) {
        AppData.instance.spreadSheetStatus = SpreadsheetStatus.opened;
        AppEvents.fireSpreadsheetReady();
      }
      _dataGrid = _buildGrid();
    });
  }

  //--------------------------------
  Widget _buildYesNoButton(String text, Color color, bool result) {
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

  //----------------------------------
  AlertDialog _buildAlertDialog(
      {required Widget yesButton, required Widget noButton}) {
    return AlertDialog(
      title: const Text("Trainingschema"),
      content: const SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dit schema is gepubliceerd!'),
            Text('Weet je zeker dat je wijzigingen wilt aanbrengen?'),
          ],
        ),
      ),
      actions: [
        noButton,
        yesButton,
      ],
    );
  }

  //---------------------------------
  String _getTrainerDeployed() {
    Map<String, int> groupCounts = _countGroups(forZamo: false);
    Map<String, int> zamoCounts = _countGroups(forZamo: true);

    List<Map<String, int>> list = [];

    for (String key in groupCounts.keys) {
      list.add({key: groupCounts[key]!});
    }
    list.sort((a, b) => b.values.first.compareTo(a.values.first));

    String result = '';
    for (Map<String, int> map in list) {
      String key = map.keys.first;
      result += '\n $key \t ${map[key]}';
      if (zamoCounts.containsKey(key)) {
        result += ' (${zamoCounts[key]})';
      }
    }

    return result;
  }

  Map<String, int> _countGroups({required bool forZamo}) {
    Map<String, int> counts = {};

    int len = _spreadSheet.rows[0].rowCells.length;
    int start = forZamo ? len - 1 : 0;
    int end = forZamo ? len : len - 1;
    for (SheetRow row in _spreadSheet.rows) {
      for (int c = start; c < end; c++) {
        if (!row.isExtraRow) {
          RowCell cell = row.rowCells[c];
          String txt = cell.text.replaceAll(' ', '');
          if (txt.isNotEmpty && !txt.startsWith('(')) {
            if (counts.containsKey(txt)) {
              int n = counts[txt]!;
              counts[txt] = n + 1;
            } else {
              counts[txt] = 1;
            }
          }
        }
      }
    }
    return counts;
  }

  void _buildDialogConfirm(BuildContext context, bool allProgramFieldSet) {
    String msg = allProgramFieldSet
        ? "Weet je zeker dat je het schema van ${AppData.instance.getActiveMonthAsString()} definitief wilt maken"
        : "Eerst moeten alle trainingen gevuld zijn!";
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
    );
    Widget continueButton = TextButton(
      onPressed: allProgramFieldSet
          ? () {
              _makeSpreadsheetFinal(context);

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            }
          : null,
      child: const Text("Continue"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Schema definitief maken"),
      content: Text(msg),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool _areProgramFieldSet() {
    List<SheetRow> emptyPrograms = _spreadSheet.rows
        .where((e) =>
            e.date.weekday != DateTime.saturday && e.trainingText.isEmpty)
        .toList();
    return emptyPrograms.isEmpty;
  }

  void _onReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _spreadSheet = AppData.instance.getSpreadsheet();
        _dataGrid = _buildGrid();

        if (AppData.instance.spreadSheetStatus == SpreadsheetStatus.active) {
          wh.showSnackbar('Schema is al definitief!', color: Colors.orange);
        }
      });
    }
  }

  void _onTrainingUpdated(TrainingUpdatedEvent event) {
    if (mounted) {
      _spreadSheet.rows[event.rowIndex].trainingText = event.training;
      AppData.instance.updateSpreadsheet(_spreadSheet);
      AppEvents.fireSpreadsheetReady();
    }
  }

  void _onExtraDayUpdated(ExtraDayUpdatedEvent event) {
    if (event.text == c.removeExtraSpreadsheetRow) {
      _removeExtraRow(event);
    } else {
      _extraRowExists(event) ? _updateExtraRow(event) : _addExtraRow(event);
    }
    AppData.instance.updateSpreadsheet(_spreadSheet);
    AppEvents.fireSpreadsheetReady();
  }

  void _onSpreadTrainerUpdated(SpreadsheetTrainerUpdatedEvent event) {
    if (mounted) {
      _spreadSheet.rows[event.rowIndex].rowCells[event.colIndex].text =
          event.text;
      AppData.instance.updateSpreadsheet(_spreadSheet);
      AppEvents.fireSpreadsheetReady();
    }
  }

  void _addExtraRow(ExtraDayUpdatedEvent event) {
    int index = _spreadSheet.rows.length;
    DateTime date = DateTime(AppData.instance.getActiveYear(),
        AppData.instance.getActiveMonth(), event.dag);
    SheetRow extraRow = SheetRow(rowIndex: index, date: date, isExtraRow: true);
    extraRow.trainingText = event.text;
    _spreadSheet.rows.add(extraRow);
  }

  void _updateExtraRow(ExtraDayUpdatedEvent event) {
    DateTime actDate = AppData.instance.getActiveDate();
    DateTime date = DateTime(actDate.year, actDate.month, event.dag);
    SheetRow? sheetRow = AppData.instance
        .getSpreadsheet()
        .rows
        .firstWhereOrNull((e) => e.date == date && e.isExtraRow);
    if (sheetRow != null) {
      sheetRow.trainingText = event.text;
    }
  }

  void _removeExtraRow(ExtraDayUpdatedEvent event) {
    DateTime actDate = AppData.instance.getActiveDate();
    DateTime date = DateTime(actDate.year, actDate.month, event.dag);
    SheetRow? sheetRow = _spreadSheet.rows
        .firstWhereOrNull((e) => e.date == date && e.isExtraRow);
    _spreadSheet.rows.remove(sheetRow);
  }

  bool _extraRowExists(ExtraDayUpdatedEvent event) {
    DateTime actDate = AppData.instance.getActiveDate();
    DateTime date = DateTime(actDate.year, actDate.month, event.dag);
    return AppData.instance
            .getSpreadsheet()
            .rows
            .firstWhereOrNull((e) => e.date == date && e.isExtraRow) !=
        null;
  }
}

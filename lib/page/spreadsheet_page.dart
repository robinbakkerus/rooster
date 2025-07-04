import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:rooster/widget/animated_fab.dart';
import 'package:rooster/widget/spreadsheet_extra_day_field.dart';
import 'package:rooster/widget/spreadsheet_top_buttons.dart';
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
  bool _fabVisible = false;

  _SpreadsheetPageState();

  @override
  void initState() {
    AppEvents.onSpreadsheetReadyEvent(_onReady);
    AppEvents.onTrainingUpdatedEvent(_onTrainingUpdated);
    AppEvents.onExtraDayUpdatedEvent(_onExtraDayUpdated);
    AppEvents.onSpreadsheetTrainerUpdatedEvent(_onSpreadTrainerUpdated);

    _spreadSheet = AppData.instance.getSpreadsheet();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dataGrid = _buildGrid(context);
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  //---------------------------------
  Widget _buildBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: _dataGrid),
    );
  }

  //--------------------------------
  Widget? _buildFab() {
    if (AppData.instance.getSpreadsheet().status == SpreadsheetStatus.dirty) {
      if (!_fabVisible) {
        wh.playWhooshSound();
      }
      _fabVisible = true;
      return FloatingActionButton(
        onPressed: _saveSpreadsheetMutations,
        hoverColor: Colors.greenAccent,
        child: const AnimatedFab(),
      );
    } else {
      _fabVisible = false;
      return null;
    }
  }

  //-----------------------
  bool _isEditable() {
    return (AppData.instance.getSpreadsheet().status ==
            SpreadsheetStatus.opened ||
        AppData.instance.getSpreadsheet().status == SpreadsheetStatus.dirty ||
        (AppData.instance.getSpreadsheet().status ==
                SpreadsheetStatus.underConstruction &&
            AppData.instance.getTrainer().isSupervisor()));
  }

  //--------------------------------
  bool _isSupervisor() {
    return AppData.instance.getTrainer().isSupervisor();
  }

  Widget _buildGrid(BuildContext context) {
    List<Widget> rows = [];
    rows.add(const SpreadsheetTopButtons(index: 0));

    for (int i = 0; i < AppData.instance.activeTrainingGroups.length; i++) {
      rows.add(_buildDataTable(
          context, i, AppData.instance.activeTrainingGroups.length - 1));
    }
    rows.add(_buildButtons());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: rows,
    );
  }

//--------------------------------
  Widget _buildDataTable(BuildContext context, int index, int lastIndex) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    DateTime date = AppData.instance.activeTrainingGroups[index].startDate;
    List<DataColumn> header = _buildHeader(date);
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: WidgetStateColor.resolveWith((states) => c.lonuBlauw),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: header,
      rows: _buildDataRows(index, header.length),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader(DateTime date) {
    List<DataColumn> result = [];

    List<String> groupNames = SpreadsheetGenerator.instance.getGroupNames(date);
    String trainingText = groupNames.length > 2 ? 'Training' : 'Zomer training';

    result.add(const DataColumn(
        label: Text('Dag', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(DataColumn(
        label: Text(trainingText,
            style: const TextStyle(fontStyle: FontStyle.italic))));

    for (String groupName in groupNames) {
      result.add(DataColumn(
          label: Text(_formatHeader(groupName),
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }

    return result;
  }

  //------------------------------
  String _formatHeader(String header) {
    if (header.length < 3) {
      return header.toUpperCase();
    } else if (header.toLowerCase() == 'zamo') {
      return 'ZaMo';
    } else if (header.toLowerCase() == 'zomer') {
      return 'Gecombineerd';
    } else {
      return header;
    }
  }

  //------------------------------
  List<DataRow> _buildDataRows(int index, int headerLength) {
    List<DataRow> result = [];

    _spreadSheet.rows.sort((a, b) => a.date.compareTo(b.date));

    for (SheetRow fsRow in _spreadSheet.rows) {
      WidgetStateColor col = _getRowColor(fsRow);

      List<DataCell> cells = _buildDataCells(fsRow);
      DataRow dataRow = DataRow(cells: cells, color: col);
      if (cells.length == headerLength) {
        result.add(dataRow);
      }
    }

    return result;
  }

  //------------------------------
  WidgetStateColor _getRowColor(SheetRow fsRow) {
    WidgetStateColor col =
        WidgetStateColor.resolveWith((states) => Colors.white);
    if (fsRow.isExtraRow) {
      col = WidgetStateColor.resolveWith((states) => c.lonuExtraDag);
    } else if (fsRow.date.weekday == DateTime.saturday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuZaterDag);
    } else if (AppHelper.instance.isDateExcluded(fsRow.date)) {
      col = WidgetStateColor.resolveWith((states) => c.lonuExtraDag);
    } else if (fsRow.date.weekday == DateTime.tuesday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuDinsDag);
    } else if (fsRow.date.weekday == DateTime.thursday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuDonderDag);
    }
    return col;
  }

  //------------------------------
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

  //----------------------------
  DataCell _buildTrainerCell(SheetRow sheetRow, String groupName) {
    return DataCell(SpreadsheetTrainerColumn(
        key: UniqueKey(),
        sheetRow: sheetRow,
        groupName: groupName,
        isEditable: _isEditable()));
  }

  //----------------------------
  DataCell _buildDayCell(SheetRow sheetRow) {
    return DataCell(SpreadsheetDayColumn(key: UniqueKey(), sheetRow: sheetRow));
  }

  //----------------------------
  DataCell _buildTrainingCell(SheetRow sheetRow) {
    double w = AppHelper.instance.isWindows() || AppHelper.instance.isTablet()
        ? 200
        : 80;
    return DataCell(Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.1, color: c.lightBrown)),
        width: w,
        child: SpreadsheetTrainingColumn(
          key: UniqueKey(),
          sheetRow: sheetRow,
          isEditable: _isEditable(),
        )));
  }

  //----------------------------
  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wh.verSpace(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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

  //----------------------------
  Widget _buildActionButton(BuildContext context) {
    if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.underConstruction) {
      return _buildActionButtonsNewSpreadsheet();
    } else {
      return _buildActionButtonPublishedSpreadsheet();
    }
  }

  //----------------------------
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
    if (AppData.instance.getSpreadsheet().status == SpreadsheetStatus.active) {
      return OutlinedButton(
          onPressed: _buildOpenSchemaAlertDialog,
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
    AppData.instance.getSpreadsheet().status =
        AppData.instance.getOriginalpreadsheet().status;
    wh.showSnackbar('Wijzigingen zijn doorgevoerd', color: Colors.lightGreen);
    AppEvents.fireSpreadsheetReady();
  }

  void _makeSpreadsheetFinal(BuildContext context) async {
    AppController.instance.finalizeSpreadsheet(_spreadSheet);
    AppData.instance.getSpreadsheet().status = SpreadsheetStatus.active;
    AppEvents.fireSpreadsheetReady();
    wh.showSnackbar('Training schema is nu definitief!');
  }

  void _buildDialogSpreadsheetInfo(BuildContext context) {
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
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

  //----------------------------------
  void _buildOpenSchemaAlertDialog() {
    String content = '''
Dit schema is gepubliceerd!
Weet je zeker dat je wijzigingen wilt aanbrengen?
''';
    wh.showConfirmDialog(context,
        title: 'Trainingschema',
        content: content,
        yesFunction: () => _handleYes());
  }

  //-------------------------------
  void _handleYes() {
    setState(() {
      AppData.instance.getSpreadsheet().status = SpreadsheetStatus.opened;
      AppEvents.fireSpreadsheetReady();
    });
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
        continueButton,
        cancelButton,
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
        _buildBody();

        if (AppData.instance.getSpreadsheet().status ==
            SpreadsheetStatus.active) {
          wh.showSnackbar('Schema is al definitief!', color: Colors.orange);
        } else if (AppData.instance.getSpreadsheet().status ==
            SpreadsheetStatus.old) {
          wh.showSnackbar('Schema is verlopen!', color: Colors.orange);
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

import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/page_mixin.dart';
import 'package:rooster/widget/spreadsheet_extra_day_field.dart';
import 'package:rooster/widget/spreadsheet_training_field.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  State<RosterPage> createState() => _RosterPageState();
}

//-------------------
class _RosterPageState extends State<RosterPage> with PageMixin {
  SpreadSheet _spreadSheet = SpreadSheet(
      year: AppData.instance.getActiveYear(),
      month: AppData.instance.getActiveMonth());

  bool _isSupervisor = false;
  Widget _dataGrid = Container();

  _RosterPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
    AppEvents.onTrainingUpdatedEvent(_onTrainingUpdated);
    AppEvents.onExtraDayUpdatedEvent(_onExtraDayUpdated);
  }

  @override
  void initState() {
    _spreadSheet = AppData.instance.getSpreadsheet();
    _isSupervisor = AppData.instance.getTrainer().isSupervisor();
    _dataGrid = _buildGrid();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dataGrid,
            wh.verSpace(10),
            _isSupervisor ? _buildSupervisorButtons() : Container(),
          ],
        ),
      ),
    );
  }

//--------------------------------------------------------
  Widget _buildGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 15 : 6;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 30,
            horizontalMargin: 10,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => c.lightblue),
            columnSpacing: colSpace,
            dataRowMinHeight: 15,
            dataRowMaxHeight: 30,
            columns: _buildHeader(),
            rows: _buildDataRows(),
          ),
        ),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('Dag', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label:
            Text('Training', style: TextStyle(fontStyle: FontStyle.italic))));

    for (Groep groep in Groep.values) {
      result.add(DataColumn(
          label: Text(groep.name.toUpperCase(),
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }
    return result;
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    _spreadSheet.rows.sort((a, b) => a.date.compareTo(b.date));

    for (SheetRow fsRow in _spreadSheet.rows) {
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

      DataRow dataRow = DataRow(cells: _buildDataCells(fsRow), color: col);
      result.add(dataRow);
    }

    return result;
  }

  List<DataCell> _buildDataCells(SheetRow row) {
    List<DataCell> result = [];

    result.add(_buildDayCell(row));
    result.add(_buildTrainingCell(row));

    if (!row.isExtraRow) {
      for (int i = 0; i < Groep.values.length; i++) {
        result.add(_buildCell(row.rowCells[i].text));
      }
    } else {
      for (int i = 0; i < Groep.values.length; i++) {
        result.add(_buildCell(''));
      }
    }

    return result;
  }

  DataCell _buildCell(String text) {
    return DataCell(Text(text));
  }

  DataCell _buildDayCell(SheetRow sheetRow) {
    return DataCell(SpreadsheeDayColumn(key: UniqueKey(), sheetRow: sheetRow));
  }

  DataCell _buildTrainingCell(SheetRow sheetRow) {
    double w = AppHelper.instance.isWindows() ? 200 : 100;
    return DataCell(Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.1, color: Colors.grey)),
        width: w,
        child:
            SpreadsheetTrainingColumn(key: UniqueKey(), sheetRow: sheetRow)));
  }

  Widget _buildSupervisorButtons() {
    return Row(
      children: [
        OutlinedButton(
            onPressed: _onConfirmFinalizeRoster,
            child: const Text('Maak schema defintief'))
      ],
    );
  }

  void _onConfirmFinalizeRoster() {
    _buildDialogConfirm(context, _areProgramFieldSet());
  }

  void _doFinalizeRoster(BuildContext context) async {
    AppController.instance.finalizeRoster(_spreadSheet);
    wh.showSnackbar('Training schema is nu definitief!');
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
              _doFinalizeRoster(context);

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            }
          : null,
      child: const Text("Continue"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
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

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _spreadSheet = AppData.instance.getSpreadsheet();
        _dataGrid = _buildGrid();
      });
    }
  }

  void _onTrainingUpdated(TrainingUpdatedEvent event) {
    if (mounted) {
      _spreadSheet.rows[event.rowIndex].trainingText = event.training;
      _dataGrid = _buildGrid();
    }
  }

  void _onExtraDayUpdated(ExtraDayUpdatedEvent event) {
    if (mounted) {
      setState(() {
        if (event.text == c.removeExtraSpreadsheetRow) {
          _removeExtraRow(event);
        } else {
          _extraRowExists(event) ? _updateExtraRow(event) : _addExtraRow(event);
        }
        _dataGrid = _buildGrid();
      });
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
    if (sheetRow != null) {
      _spreadSheet.rows.remove(sheetRow);
    }
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

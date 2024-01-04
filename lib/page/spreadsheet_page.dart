import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/widget/spreadsheet_extra_day_field.dart';
import 'package:rooster/widget/spreadsheet_training_field.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  State<RosterPage> createState() => _RosterPageState();
}

//-------------------
class _RosterPageState extends State<RosterPage> {
  SpreadSheet _spreadSheet = SpreadSheet(
      year: AppData.instance.getActiveYear(),
      month: AppData.instance.getActiveMonth());
  bool _isSupervisor = false;
  List<Widget> _columnRowWidgets = [];

  _RosterPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
    AppEvents.onTrainingUpdatedEvent(_onTrainingUpdated);
    AppEvents.onExtraDayUpdatedEvent(_onExtraDayUpdated);
  }

  @override
  void initState() {
    _spreadSheet = AppData.instance.getSpreadsheet();
    _isSupervisor = AppData.instance.getTrainer().isSupervisor();
    _columnRowWidgets = _buildRows();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: _columnRowWidgets,
      ),
    );
  }

  List<Widget> _buildRows() {
    List<Widget> widgetList = [];

    widgetList.add(_buildHeaderRow());
    widgetList.add(WH.verSpace(2));

    List<SheetRow> sheetList = [];
    sheetList.addAll(_spreadSheet.rows);
    sheetList.addAll(_spreadSheet.extraRows);
    sheetList.sort((a, b) => a.date.compareTo(b.date));

    for (SheetRow sheetRow in sheetList) {
      Widget w = Row(
        children: _buildRosterRowFields(sheetRow),
      );
      widgetList.add(w);
      widgetList.add(WH.verSpace(1));
    }

    widgetList.add(WH.verSpace(20));
    if (_isSupervisor) {
      widgetList.add(_buildSupervisorButtons());
    }
    return widgetList;
  }

  List<Widget> _buildRosterRowFields(SheetRow sheetRow) {
    List<Widget> widgets = [];

    widgets.add(SpreadsheeDayColumn(
        key: UniqueKey(), sheetRow: sheetRow, width: WH.w1));

    widgets.add(SpreadsheetTrainingColumn(
        key: UniqueKey(), sheetRow: sheetRow, width: WH.w2));

    if (sheetRow.rowCells.length == Groep.values.length) {
      for (Groep groep in Groep.values) {
        widgets.add(_buildRosterFieldWidget(sheetRow, colIndex: groep.index));
        widgets.add(WH.horSpace(1));
      }
    }

    return widgets;
  }

  Widget _buildHeaderRow() {
    var widths = [WH.w1, WH.w2, WH.w12, WH.w12, WH.w12, WH.w12, WH.w12];
    List<Widget> widgets = [];
    for (int i = 0; i < _spreadSheet.header.length; i++) {
      widgets.add(Container(
        width: widths[i],
        decoration:
            BoxDecoration(border: Border.all(width: 0.1), color: WH.color2),
        child: Text(_spreadSheet.header[i]),
      ));
      widgets.add(WH.horSpace(1));
    }

    return Row(
      children: widgets,
    );
  }

  Widget _buildRosterFieldWidget(SheetRow sheetRow, {required int colIndex}) {
    RowCell rowCell = sheetRow.rowCells[colIndex];
    return Container(
      width: WH.w12,
      decoration:
          BoxDecoration(border: Border.all(width: 0.1), color: WH.color1),
      child: Text(
        rowCell.text,
        overflow: TextOverflow.ellipsis,
      ),
    );
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
    WH.showSnackbar('Training schema is nu definitief!');
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
        _columnRowWidgets = _buildRows();
      });
    }
  }

  void _onTrainingUpdated(TrainingUpdatedEvent event) {
    if (mounted) {
      _spreadSheet.rows[event.rowIndex].trainingText = event.training;
      _columnRowWidgets = _buildRows();
    }
  }

  void _onExtraDayUpdated(ExtraDayUpdatedEvent event) {
    if (mounted) {
      setState(() {
        if (event.text == WH.removeExtraSpreadsheetRow) {
          _removeExtraRow(event);
        } else {
          _extraRowExists(event) ? _updateExtraRow(event) : _addExtraRow(event);
        }
        _columnRowWidgets = _buildRows();
      });
    }
  }

  void _addExtraRow(ExtraDayUpdatedEvent event) {
    int index = _spreadSheet.extraRows.length;
    DateTime date = DateTime(AppData.instance.getActiveYear(),
        AppData.instance.getActiveMonth(), event.dag);
    SheetRow extraRow = SheetRow(rowIndex: index, date: date, isExtraRow: true);
    extraRow.trainingText = event.text;
    _spreadSheet.extraRows.add(extraRow);
  }

  void _updateExtraRow(ExtraDayUpdatedEvent event) {
    DateTime actDate = AppData.instance.getActiveDate();
    DateTime date = DateTime(actDate.year, actDate.month, event.dag);
    SheetRow? sheetRow = AppData.instance
        .getSpreadsheet()
        .extraRows
        .firstWhereOrNull((e) => e.date == date);
    if (sheetRow != null) {
      sheetRow.trainingText = event.text;
    }
  }

  void _removeExtraRow(ExtraDayUpdatedEvent event) {
    DateTime actDate = AppData.instance.getActiveDate();
    DateTime date = DateTime(actDate.year, actDate.month, event.dag);
    SheetRow? sheetRow =
        _spreadSheet.extraRows.firstWhereOrNull((e) => e.date == date);
    if (sheetRow != null) {
      _spreadSheet.extraRows.remove(sheetRow);
    }
  }

  bool _extraRowExists(ExtraDayUpdatedEvent event) {
    DateTime actDate = AppData.instance.getActiveDate();
    DateTime date = DateTime(actDate.year, actDate.month, event.dag);
    return AppData.instance
            .getSpreadsheet()
            .extraRows
            .firstWhereOrNull((e) => e.date == date) !=
        null;
  }
}

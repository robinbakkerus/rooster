import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/widget/spreadsheet_extra_day_field.dart';
import 'package:rooster/widget/spreadsheet_training_field.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'package:flutter/material.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  State<RosterPage> createState() => _RosterPageState();
}

//-------------------
class _RosterPageState extends State<RosterPage> {
  SpreadSheet _spreadSheet = SpreadSheet();
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
    widgetList.add(WidgetHelper.verSpace(2));

    List<SheetRow> sheetList = [];
    sheetList.addAll(_spreadSheet.rows);
    sheetList.addAll(_spreadSheet.extraRows);
    sheetList.sort((a, b) => a.date.compareTo(b.date));

    for (SheetRow sheetRow in sheetList) {
      Widget w = Row(
        children: _buildRosterRowFields(sheetRow),
      );
      widgetList.add(w);
      widgetList.add(WidgetHelper.verSpace(1));
    }

    widgetList.add(WidgetHelper.verSpace(20));
    if (_isSupervisor) {
      widgetList.add(_buildSupervisorButtons());
    }
    return widgetList;
  }

  List<Widget> _buildRosterRowFields(SheetRow sheetRow) {
    List<Widget> widgets = [];

    widgets.add(SpreadsheeDayColumn(
        key: UniqueKey(), sheetRow: sheetRow, width: WidgetHelper.w1));

    widgets.add(SpreadsheetTrainingColumn(
        key: UniqueKey(), sheetRow: sheetRow, width: WidgetHelper.w2));

    if (sheetRow.rowCells.length == Groep.values.length) {
      for (Groep groep in Groep.values) {
        widgets.add(_buildRosterFieldWidget(sheetRow, colIndex: groep.index));
        widgets.add(WidgetHelper.horSpace(1));
      }
    }

    return widgets;
  }

  Widget _buildHeaderRow() {
    var widths = [
      WidgetHelper.w1,
      WidgetHelper.w2,
      WidgetHelper.w12,
      WidgetHelper.w12,
      WidgetHelper.w12,
      WidgetHelper.w12,
      WidgetHelper.w12
    ];
    List<Widget> widgets = [];
    for (int i = 0; i < _spreadSheet.header.length; i++) {
      widgets.add(Container(
        width: widths[i],
        decoration: BoxDecoration(
            border: Border.all(width: 0.1), color: WidgetHelper.color2),
        child: Text(_spreadSheet.header[i]),
      ));
      widgets.add(WidgetHelper.horSpace(1));
    }

    return Row(
      children: widgets,
    );
  }

  Widget _buildRosterFieldWidget(SheetRow sheetRow, {required int colIndex}) {
    RowCell rowCell = sheetRow.rowCells[colIndex];
    return Container(
      width: WidgetHelper.w12,
      decoration: BoxDecoration(
          border: Border.all(width: 0.1), color: WidgetHelper.color1),
      child: Text(
        rowCell.spreadSheetText,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSupervisorButtons() {
    return Row(
      children: [
        // OutlinedButton(
        //     onPressed: () => _showHtmlAndCsv(context),
        //     child: const Text('Show schema & csv')),
        OutlinedButton(
            onPressed: _onConfirmFinalizeRoster,
            child: const Text('Maak schema defintief'))
      ],
    );
  }

  // void _showHtmlAndCsv(context) {
  //   String html = SchemaGenerator.instance.generateHtml(_csvRosterList);
  //   List<String> csvList = SchemaGenerator.instance.generateCsv(_csvRosterList);
  //   String csv = csvList.join('\n');

  //   _buildDialogShowCsvHtml(context, csv: csv, html: html);
  // }

  void _onConfirmFinalizeRoster() {
    _buildDialogConfirm(context, _areProgramFieldSet());
  }

  void _doFinalizeRoster(BuildContext context) async {
    AppController.instance.finalizeRoster(_spreadSheet);
    WidgetHelper.showSnackbar('Training schema is nu definitief!');
  }

  // Future<void> _buildDialogShowCsvHtml(BuildContext context,
  //     {required String csv, required String html}) {
  //   return showDialog<void>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Dialog(
  //           child: SizedBox(
  //             height: AppData.instance.screenHeight * 0.8,
  //             width: AppData.instance.screenWidth * 0.9,
  //             child: ShowRosterCsvHtmlView(csv: csv, html: html),
  //           ),
  //         );
  //       });
  // }

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
        .where((e) => e.date.weekday != DateTime.saturday && e.text.isEmpty)
        .toList();
    return emptyPrograms.isEmpty;
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _spreadSheet = AppData.instance.getSpreadsheet();
      });
    }
  }

  void _onTrainingUpdated(TrainingUpdatedEvent event) {
    if (mounted) {
      _spreadSheet.rows[event.rowIndex].text = event.training;
      _columnRowWidgets = _buildRows();
    }
  }

  void _onExtraDayUpdated(ExtraDayUpdatedEvent event) {
    if (mounted) {
      setState(() {
        int index = _spreadSheet.extraRows.length;
        DateTime date = DateTime(AppData.instance.getActiveYear(),
            AppData.instance.getActiveMonth(), event.dag);
        SheetRow extraRow =
            SheetRow(rowIndex: index, date: date, isExtraRow: true);
        extraRow.text = event.text;
        _spreadSheet.extraRows.add(extraRow);

        _columnRowWidgets = _buildRows();
      });
    }
  }
}

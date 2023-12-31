import 'package:firestore/controller/app_controler.dart';
import 'package:firestore/data/app_data.dart';
import 'package:firestore/event/app_events.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/util/data_helper.dart';
import 'package:firestore/widget/roster_program_field_widget.dart';
import 'package:firestore/widget/widget_helper.dart';
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

  _RosterPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
    AppEvents.onTrainingUpdatedEvent(_onTrainingUpdated);
  }

  @override
  void initState() {
    _spreadSheet = AppData.instance.getSpreadsheet();
    _isSupervisor = AppData.instance.getTrainer().isSupervisor();
    super.initState();
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
      _spreadSheet.rows[event.rowIndex].training = event.training;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> colWidgets = _getColumnChildren();
    colWidgets.add(WidgetHelper().verSpace(20));
    if (_isSupervisor) {
      colWidgets.add(_buildSupervisorButtons());
    }

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: colWidgets,
      ),
    );
  }

  List<Widget> _getColumnChildren() {
    List<Widget> list = [];

    list.add(_buildHeaderRow());
    list.add(WidgetHelper().verSpace(2));

    for (SheetRow sheetRow in _spreadSheet.rows) {
      Widget w = Row(
        children: _buildRosterRowFields(sheetRow),
      );
      list.add(w);
      list.add(
        WidgetHelper().verSpace(1),
      );
    }

    return list;
  }

  List<Widget> _buildRosterRowFields(SheetRow sheetRow) {
    List<Widget> widgets = [];

    widgets.add(Container(
        width: w1,
        color: col1,
        child: Text(DataHelper.instance.getSimpleDayString(sheetRow.date))));

    widgets.add(SpreadsheetTrainingColumn(
      sheetRow: sheetRow,
      width: w2,
    ));

    for (Groep groep in Groep.values) {
      widgets.add(_buildRosterFieldWidget(sheetRow, colIndex: groep.index));
      widgets.add(WidgetHelper().horSpace(1));
    }

    return widgets;
  }

  Widget _buildHeaderRow() {
    var widths = [w1, w2, w3, w3, w3, w3, w3];
    List<Widget> widgets = [];
    for (int i = 0; i < _spreadSheet.header.length; i++) {
      widgets.add(Container(
        width: widths[i],
        decoration: BoxDecoration(border: Border.all(width: 0.1), color: col2),
        child: Text(_spreadSheet.header[i]),
      ));
      widgets.add(WidgetHelper().horSpace(1));
    }

    return Row(
      children: widgets,
    );
  }

  Widget _buildRosterFieldWidget(SheetRow sheetRow, {required int colIndex}) {
    RowCell rowCell = sheetRow.rowCells[colIndex];
    return Container(
      width: w3,
      decoration: BoxDecoration(border: Border.all(width: 0.1), color: col1),
      child: Text(rowCell.spreadSheetText),
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
    WidgetHelper().showSnackbar(context, 'Training schema is nu definitief!');
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
        .where((e) => e.date.weekday != DateTime.saturday && e.training.isEmpty)
        .toList();
    return emptyPrograms.isEmpty;
  }
}

final double w1 = 0.1 * AppData.instance.screenWidth;
final double w2 = 0.2 * AppData.instance.screenWidth;
final double w3 = 0.12 * AppData.instance.screenWidth;
const Color col1 = Color(0xffF4E9CA);
const Color col2 = Colors.lightGreenAccent;

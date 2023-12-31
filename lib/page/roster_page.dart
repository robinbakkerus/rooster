import 'package:firestore/controller/app_controler.dart';
import 'package:firestore/data/app_data.dart';
import 'package:firestore/event/app_events.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/util/data_helper.dart';
import 'package:firestore/util/schema_generator.dart';
import 'package:firestore/widget/roster_program_field_widget.dart';
// import 'package:firestore/widget/show_roster_csv_html.dart';
import 'package:firestore/widget/widget_helper.dart';
import 'package:flutter/material.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  State<RosterPage> createState() => _RosterPageState();
}

//-------------------
class _RosterPageState extends State<RosterPage> {
  List<Available> _availableList = [];
  SpreadSheet _spreadSheet = SpreadSheet.init(AppData.instance.getActiveDate());
  bool _isSupervisor = false;

  _RosterPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
  }

  @override
  void initState() {
    _fillData();
    super.initState();
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _fillData();
      });
    }
  }

  void _fillData() {
    _availableList = SchemaGenerator.instance.generateAvailableTrainersCounts();
    _spreadSheet = SchemaGenerator.instance
        .generateSpreadsheet(_availableList, AppData.instance.getActiveDate());
    _isSupervisor = AppData.instance.getTrainer().isSupervisor();
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

    for (SheetRow sheetRow in _spreadSheet.rows) {
      Widget w = Row(
        children: [
          Container(
              width: w1,
              color: Colors.lightGreen,
              child:
                  Text(DataHelper.instance.getSimpleDayString(sheetRow.date))),
          _buildRosterRowFields(sheetRow),
        ],
      );
      list.add(w);
      list.add(
        WidgetHelper().verSpace(1),
      );
    }

    return list;
  }

  Widget _buildRosterRowFields(SheetRow sheetRow) {
    Color col = sheetRow.isTopRow() ? Colors.lightGreen : col1;
    return Row(
      children: [
        SpreadsheetProgramColumn(
          sheetRow: sheetRow,
          width: w2,
        ),
        WidgetHelper().horSpace(1),
        _buildRosterFieldWidget(sheetRow.pr, col),
        WidgetHelper().horSpace(1),
        _buildRosterFieldWidget(sheetRow.r1, col),
        WidgetHelper().horSpace(1),
        _buildRosterFieldWidget(sheetRow.r2, col),
        WidgetHelper().horSpace(1),
        _buildRosterFieldWidget(sheetRow.r3, col),
        WidgetHelper().horSpace(1),
        _buildRosterFieldWidget(sheetRow.zamo, col),
      ],
    );
  }

  Widget _buildRosterFieldWidget(Trainer trainer, Color color) {
    return Container(
      width: w3,
      decoration: BoxDecoration(border: Border.all(width: 0.1), color: color),
      child: Text(trainer.firstName()),
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
    var emptyPrograms = _spreadSheet.rows.where((e) => e.training.isEmpty);
    return emptyPrograms.isEmpty;
  }
}

final double w1 = 0.1 * AppData.instance.screenWidth;
final double w2 = 0.2 * AppData.instance.screenWidth;
final double w3 = 0.12 * AppData.instance.screenWidth;
const Color col1 = Color(0xffF4E9CA);

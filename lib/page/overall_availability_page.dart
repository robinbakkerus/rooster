import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class OverallAvailabilityPage extends StatefulWidget {
  const OverallAvailabilityPage({super.key});

  @override
  State<OverallAvailabilityPage> createState() =>
      _OverallAvailabilityPageState();
}

class _OverallAvailabilityPageState extends State<OverallAvailabilityPage>
    with AppMixin {
  _OverallAvailabilityPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
  }

  @override
  void initState() {
    super.initState();
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
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

    var headerLabels = ['dag'];
    for (Groep groep in Groep.values) {
      headerLabels.add(groep.name.toUpperCase());
    }

    for (String label in headerLabels) {
      result.add(DataColumn(
          label: Text(label,
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }
    return result;
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (int rowIndex = 0;
        rowIndex < AppData.instance.getSpreadsheet().rows.length;
        rowIndex++) {
      result.add(DataRow(cells: _buildDataCells(rowIndex)));
    }
    return result;
  }

  List<DataCell> _buildDataCells(int rowIndex) {
    List<DataCell> result = [];

    result.add(_buildDayDataCell(rowIndex));

    for (Groep groep in Groep.values) {
      result.add(_buildGroupDataCell(rowIndex, groep));
    }

    return result;
  }

  DataCell _buildDayDataCell(int rowIndex) {
    DateTime dateTime = AppData.instance.getActiveDates()[rowIndex];
    String text = AppHelper.instance.getSimpleDayString(dateTime);
    return DataCell(Text(text));
  }

  DataCell _buildGroupDataCell(int rowIndex, Groep groep) {
    AvailableCounts cnts =
        AppHelper.instance.getAvailableCounts(rowIndex, groep);

    String text =
        '${cnts.confirmed.length}, ${cnts.ifNeeded.length}, ${cnts.notEnteredYet.length}';
    Color color = _buildAvailFieldColor(cnts);

    return DataCell(InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 0.1, color: Colors.grey), color: color),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
          child: Text(text),
        ),
      ),
      onTap: () {
        _dialogBuilder(context, rowIndex, groep);
      },
    ));
  }

  Color _buildAvailFieldColor(AvailableCounts cnts) {
    if (cnts.confirmed.isNotEmpty) {
      return c.lightBrown;
    } else if (cnts.confirmed.isEmpty &&
        cnts.ifNeeded.isEmpty &&
        cnts.notEnteredYet.isEmpty) {
      return c.lightOrange;
    }
    return c.lightGeen;
  }

  Future<void> _dialogBuilder(BuildContext context, int rowIndex, Groep group) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: AppData.instance.screenHeight * 0.8,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _buildAvailDetail(rowIndex, group),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Sluit"))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailDetail(int rowIndex, Groep group) {
    AvailableCounts cnts =
        AppHelper.instance.getAvailableCounts(rowIndex, group);

    List<Widget> colWidgets = [];

    colWidgets.add(const Text(
      'Aanwezig',
      style: TextStyle(color: Colors.green),
    ));
    colWidgets.add(_horLine());

    for (Trainer trainer in cnts.confirmed) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }
    colWidgets.add(wh.verSpace(20));

    colWidgets.add(const Text(
      'Alleen als nodig',
      style: TextStyle(color: Colors.orange),
    ));
    colWidgets.add(_horLine());

    for (Trainer trainer in cnts.ifNeeded) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }
    colWidgets.add(wh.verSpace(20));

    colWidgets.add(const Text('Nog niet ingevuld',
        style: TextStyle(
          color: Colors.brown,
        )));
    colWidgets.add(_horLine());

    for (Trainer trainer in cnts.notEnteredYet) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }

    colWidgets.add(wh.verSpace(20));

    colWidgets.add(const Text('Niet aanwezig',
        style: TextStyle(
          color: Colors.red,
        )));
    colWidgets.add(_horLine());

    for (Trainer trainer
        in _getUnavailbeTrainers(rowIndex, group, cnts.notEnteredYet)) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colWidgets,
    );
  }

  _horLine() {
    return const Divider(
      color: Colors.grey,
    );
  }

  List<Trainer> _getUnavailbeTrainers(
      int rowIndex, Groep groep, List<Trainer> notEnteredYet) {
    List<Trainer> result = [];

    for (Trainer trainer in AppData.instance.getAllTrainers()) {
      if (!notEnteredYet.contains(trainer) &&
          trainer.getPrefValue(paramName: groep.name) > 0) {
        int avail = AppHelper.instance.getAvailability(trainer, rowIndex);
        if (avail == 0) {
          result.add(trainer);
        }
      }
    }

    return result;
  }
}

final double w15 = 0.15 * AppData.instance.screenWidth;
final double w2 = 0.2 * AppData.instance.screenWidth;
const Color colLightYellow = Color(0xffF4E9CA);
const Color colLightGreen = Color(0xffA6CD7A);
const Color colLightRed = Color(0xffF6AB94);

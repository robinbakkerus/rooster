import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';

class ShowAvailabilityWidget extends StatefulWidget {
  final Trainer trainer;
  const ShowAvailabilityWidget({super.key, required this.trainer});

  @override
  State<ShowAvailabilityWidget> createState() => _ShowAvailabilityWidgetState();
}

//---------------------------
class _ShowAvailabilityWidgetState extends State<ShowAvailabilityWidget>
    with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children: [
            Text(
              widget.trainer.firstName(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            wh.horSpace(10),
            _buildWhenEntered(),
          ]),
          wh.verSpace(5),
          _buildDayAvailableGrid(),
          wh.verSpace(5),
          _buildTrainerPrefGrid(groupNames, _buildGroupPrefs()),
          wh.verSpace(5),
          _buildTrainerPrefGrid(dayNames, _buildDayPrefs()),
          wh.verSpace(5),
          _buildMaxPref(),
        ],
      ),
    );
  }

  //-------------------------
  Widget _buildDayAvailableGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 20,
        horizontalMargin: 10,
        headingRowColor: WidgetStateColor.resolveWith((states) => c.lightblue),
        columnSpacing: colSpace,
        dataRowMinHeight: 15,
        dataRowMaxHeight: 25,
        columns: _buildGridHeader(['Dag', 'Beschikbaar']),
        rows: _buildDataRows(),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildGridHeader(List<String> headerLabels) {
    List<DataColumn> result = [];

    for (int i = 0; i < headerLabels.length; i++) {
      String label = headerLabels[i].toLowerCase();
      label = label.length > 3 ? label.substring(0, 3) : label;
      result.add(DataColumn(
          label: Container(
        color: c.lightblue,
        child: Text(label, style: const TextStyle(fontStyle: FontStyle.italic)),
      )));
    }
    return result;
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (int dateIndex = 0;
        dateIndex < AppData.instance.getActiveDates().length;
        dateIndex++) {
      DateTime date = AppData.instance.getActiveDates()[dateIndex];
      bool addRow = AppHelper.instance
          .addSchemaEditRow(date, AppData.instance.getTrainer());
      if (addRow) {
        result.add(DataRow(cells: _buildDataCells(day: date.day)));
      }
    }

    return result;
  }

  List<DataCell> _buildDataCells({required int day}) {
    List<DataCell> result = [];

    result.add(_buildDateDataCell(day: day));
    result.add(_buildAvailableDataCell(day: day));

    return result;
  }

  DataCell _buildDateDataCell({required int day}) {
    DateTime dateTime = DateTime(AppData.instance.getActiveYear(),
        AppData.instance.getActiveMonth(), day);
    String label = AppHelper.instance.getSimpleDayString(dateTime);
    return DataCell(Text(label));
  }

  DataCell _buildAvailableDataCell({required int day}) {
    int avail = 0;
    if (_isSchemaEntered()) {
      avail = AppHelper.instance.getAvailability(widget.trainer, day);
    } else {
      avail = 1;
    }

    Icon icon = _buildIcon(avail);

    return DataCell(Center(child: icon));
  }

  Icon _buildIcon(int value) {
    Icon icon = const Icon(Icons.done, color: Colors.green);
    if (value == 0) {
      icon = const Icon(Icons.block, color: Colors.red);
    } else if (value == 2) {
      icon = const Icon(
        Icons.change_history,
        color: Colors.brown,
      );
    }
    return icon;
  }

  TrainerData _getTrainerData() {
    return AppData.instance.getTrainerDataForTrainer(widget.trainer);
  }

  bool _isSchemaEntered() {
    return !_getTrainerData().trainerSchemas.isEmpty();
  }

  Widget _buildWhenEntered() {
    if (_isSchemaEntered()) {
      var formatter = DateFormat('dd-MM-yyyy');
      DateTime dateTime = _getTrainerData().trainerSchemas.modified != null
          ? _getTrainerData().trainerSchemas.modified!
          : _getTrainerData().trainerSchemas.created!;
      String dateStr = formatter.format(dateTime);
      return Text('Op $dateStr');
    } else {
      return const Text('Nog niet ingevuld');
    }
  }

  //-------------------------
  Widget _buildTrainerPrefGrid(List<String> headerLabels, List<DataRow> rows) {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 20,
        horizontalMargin: 10,
        headingRowColor: WidgetStateColor.resolveWith((states) => c.lightblue),
        columnSpacing: colSpace,
        dataRowMinHeight: 15,
        dataRowMaxHeight: 25,
        columns: _buildGridHeader(headerLabels),
        rows: rows,
      ),
    );
  }

  List<DataRow> _buildGroupPrefs() {
    List<DataCell> rowCells = [];
    for (String groupName in groupNames) {
      int prefValue = widget.trainer.getPrefValue(paramName: groupName);
      rowCells.add(DataCell(_buildIcon(prefValue)));
    }

    List<DataRow> result = [];
    result.add(DataRow(cells: rowCells));
    return result;
  }

  List<DataRow> _buildDayPrefs() {
    List<DataCell> rowCells = [];
    for (String day in dayNames) {
      int prefValue = widget.trainer.getPrefValue(paramName: day);
      rowCells.add(DataCell(_buildIcon(prefValue)));
    }

    List<DataRow> result = [];
    result.add(DataRow(cells: rowCells));
    return result;
  }

  Widget _buildMaxPref() {
    int maxPref = widget.trainer.getPrefValue(paramName: 'max');
    String text = maxPref > 0 ? 'Max = $maxPref' : 'Max = -1 (niet ingevuld)';
    return Text(text);
  }

  //-------------------------
  final dayNames = ['dinsdag', 'donderdag', 'zaterdag', 'sg'];
  final groupNames = ['pr', 'r1', 'r2', 'r3'];
}

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
          Text(
            widget.trainer.firstName(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          _buildWhenEntered(),
          wh.verSpace(10),
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return SingleChildScrollView(
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
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    var headerLabels = ['Dag', 'Beschikbaar'];

    for (int i = 0; i < headerLabels.length; i++) {
      result.add(DataColumn(
          label: Container(
        color: c.lightblue,
        child: Text(headerLabels[i],
            style: const TextStyle(fontStyle: FontStyle.italic)),
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
      bool addRow = date.weekday != DateTime.saturday ||
          date.weekday == DateTime.saturday &&
              AppData.instance.isZamoTrainer(AppData.instance.getTrainer().pk);
      if (addRow) {
        result.add(DataRow(cells: _buildDataCells(dateIndex)));
      }
    }

    return result;
  }

  List<DataCell> _buildDataCells(int dateIndex) {
    List<DataCell> result = [];

    result.add(_buildDateDataCell(dateIndex));
    result.add(_buildAvailableDataCell(dateIndex));

    return result;
  }

  DataCell _buildDateDataCell(int dateIndex) {
    DateTime dateTime = AppData.instance.getActiveDates()[dateIndex];
    String label = AppHelper.instance.getSimpleDayString(dateTime);
    return DataCell(Text(label));
  }

  DataCell _buildAvailableDataCell(int dateIndex) {
    int avail = 0;
    if (_isSchemaEntered()) {
      avail = _getTrainerData().trainerSchemas.availableList[dateIndex];
    } else {
      avail = 1;
    }

    Icon icon = const Icon(Icons.done, color: Colors.green);
    if (avail == 0) {
      icon = const Icon(Icons.block, color: Colors.red);
    } else if (avail == 2) {
      icon = const Icon(
        Icons.change_history,
        color: Colors.brown,
        // weight: 5,
      );
    }

    return DataCell(Center(child: icon));
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
}

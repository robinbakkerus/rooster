import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class AllEnteredSchemas extends StatefulWidget {
  const AllEnteredSchemas({super.key});

  @override
  State<AllEnteredSchemas> createState() => _AllEnteredSchemasState();
}

//---------------------------
class _AllEnteredSchemasState extends State<AllEnteredSchemas> with AppMixin {
  List<TrainerData> _allTrainerData = [];
  TrainerData _selectedTrainerData = TrainerData.empty();

  @override
  void initState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
    _allTrainerData = AppData.instance.getAllTrainerData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDropdown(),
              wh.horSpace(20),
              Text(_selectedTrainerData.trainer.firstName()),
            ],
          ),
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
      result.add(DataRow(cells: _buildDataCells(dateIndex)));
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
    Icon icon = const Icon(Icons.done, color: Colors.green);

    int avail = AppData.instance
        .getTrainerData()
        .trainerSchemas
        .availableList[dateIndex];
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

  Widget _buildDropdown() {
    List<TrainerData> schemasEntered =
        _allTrainerData.where((e) => !e.trainerSchemas.isEmpty()).toList();

    const topVal = 'Trainers ...';
    List<String> trainerList = [topVal];
    trainerList
        .addAll(schemasEntered.map((e) => e.trainer.firstName()).toList());

    var items = trainerList.map((item) {
      return DropdownMenuItem(
        value: item,
        child: Text(item),
      );
    }).toList();

    return DropdownButton(
      menuMaxHeight: AppData.instance.screenHeight * 0.75,
      isDense: true,
      value: topVal,
      items: items,
      onChanged: _onDropdownSelected,
    );
  }

  void _onDropdownSelected(Object? value) {
    TrainerData? trainerData =
        _allTrainerData.firstWhereOrNull((e) => e.trainer.firstName() == value);
    if (trainerData != null) {
      setState(() {
        _selectedTrainerData = trainerData;
      });
    } else {
      wh.showSnackbar('Kan trainerdata niet vinden');
    }
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _allTrainerData = AppData.instance.getAllTrainerData();
        _selectedTrainerData = TrainerData.empty();
      });
    }
  }
}

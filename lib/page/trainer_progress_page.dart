import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';

class TrainerProgressPage extends StatefulWidget {
  const TrainerProgressPage({super.key});

  @override
  State<TrainerProgressPage> createState() => _TrainerProgressPageState();
}

class _TrainerProgressPageState extends State<TrainerProgressPage>
    with AppMixin {
  // varbs
  List<Trainer> _allTrainers = [];

  _TrainerProgressPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
  }

  @override
  void initState() {
    _allTrainers = AppData.instance.getAllTrainers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return Scrollbar(
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
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    var headerLabels = ['Naam', 'Ingevuld?'];
    for (String label in headerLabels) {
      result.add(DataColumn(
          label: Text(label,
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }
    return result;
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (Trainer trainer in _allTrainers) {
      result.add(DataRow(cells: _buildDataCells(trainer)));
    }

    return result;
  }

  List<DataCell> _buildDataCells(Trainer trainer) {
    List<DataCell> result = [];

    result.add(_buildTrainerDataCell(trainer));
    result.add(_buildEnteredDataCell(trainer));

    return result;
  }

  DataCell _buildTrainerDataCell(Trainer trainer) {
    return DataCell(Text(trainer.firstName()));
  }

  DataCell _buildEnteredDataCell(Trainer trainer) {
    return DataCell(_buildEnteredWidget(trainer));
  }

  Widget _buildEnteredWidget(Trainer trainer) {
    TrainerSchema trainerSchemas =
        SpreadsheetGenerator.instance.getSchemaFromAllTrainerData(trainer);

    bool entered = !trainerSchemas.isEmpty();
    Icon icon = entered
        ? const Icon(
            Icons.done,
            color: Colors.green,
          )
        : const Icon(
            Icons.block,
            color: Colors.red,
          );

    return icon;
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _allTrainers = AppData.instance.getAllTrainers();
      });
    }
  }
}

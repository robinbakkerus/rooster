import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/widget/spreadsheet_top_buttons.dart';

class TrainerScheduledCount extends StatefulWidget {
  const TrainerScheduledCount({super.key});

  @override
  State<TrainerScheduledCount> createState() => _TrainerScheduledCountState();
}

//---------------
class _TrainerScheduledCountState extends State<TrainerScheduledCount>
    with AppMixin {
  // varbs
  List<Trainer> _allTrainers = [];
  SpreadSheet _spreadSheet = SpreadSheet(
      year: AppData.instance.getActiveYear(),
      month: AppData.instance.getActiveMonth());

  _TrainerScheduledCountState() {
    AppEvents.onSpreadsheetReadyEvent(_onReady);
  }

  @override
  void initState() {
    _allTrainers = AppData.instance.getAllTrainers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildGrid(),
    );
  }

  //------------------------------------------
  Widget _buildGrid() {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _buildChild(),
      ),
    );
  }

  //----------------------------
  Widget _buildChild() {
    List<Widget> rows = [];
    rows.add(const SpreadsheetTopButtons(index: 3));
    rows.add(_buildDataTable());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  //------------------------------
  Widget _buildDataTable() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;

    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: WidgetStateColor.resolveWith((states) => c.lightblue),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: _buildHeader(),
      rows: _buildDataRows(),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    var headerLabels = ['Naam', 'Aantal trainingen '];
    for (String label in headerLabels) {
      result.add(DataColumn(
          label: Text(label,
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }
    return result;
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    final trainers = List<Trainer>.of(_allTrainers)
      ..sort((a, b) => _scheduledCount(b).compareTo(_scheduledCount(a)));

    for (Trainer trainer in trainers) {
      result.add(DataRow(cells: _buildDataCells(trainer)));
    }

    return result;
  }

  List<DataCell> _buildDataCells(Trainer trainer) {
    List<DataCell> result = [];

    result.add(_buildTrainerDataCell(trainer));
    result.add(_buildScheduledCountDataCell(trainer));

    return result;
  }

  DataCell _buildTrainerDataCell(Trainer trainer) {
    return DataCell(Text(trainer.firstName()));
  }

  DataCell _buildScheduledCountDataCell(Trainer trainer) {
    return DataCell(Text(_scheduledCount(trainer).toString()));
  }

  int _scheduledCount(Trainer trainer) {
    int count = 0;
    for (SheetRow row in _spreadSheet.rows) {
      for (RowCell cell in row.rowCells) {
        if (cell.text == trainer.firstName()) {
          count++;
        }
      }
    }
    return count;
  }

  void _onReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _allTrainers = AppData.instance.getAllTrainers();
        _spreadSheet = AppData.instance.getSpreadsheet();
      });
    }
  }
}

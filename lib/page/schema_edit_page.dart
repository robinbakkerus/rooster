import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/widget/radiobutton_widget.dart';

class SchemaEditPage extends StatefulWidget {
  const SchemaEditPage({super.key});

  @override
  State<SchemaEditPage> createState() => _SchemaEditPageState();
}

class _SchemaEditPageState extends State<SchemaEditPage> with AppMixin {
  final Icon _fabIcon = const Icon(Icons.save);
  List<int> _availableList = [];

  _SchemaEditPageState();

  @override
  void initState() {
    AppEvents.onTrainerDataReadyEvent(_onReady);
    AppEvents.onSchemaUpdatedEvent(_onSchemaUpdated);
    super.initState();
  }

  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _availableList = AppData.instance.newAvailaibleList;
      });
    }

    if (AppData.instance.stackIndex == PageEnum.editSchema.code) {
      _showSnackbar();
    }
  }

  void _onSchemaUpdated(SchemaUpdatedEvent event) {
    if (mounted) {
      setState(() {
        _availableList = AppData.instance.newAvailaibleList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildGrid(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 30,
            horizontalMargin: 10,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => c.lightblue),
            columnSpacing: colSpace,
            dataRowMinHeight: 25,
            dataRowMaxHeight: 40,
            columns: _buildHeader(),
            rows: _buildDataRows(),
          ),
        ),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    return wh.buildYesNoIfNeededHeader();
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (int dateIndex = 0; dateIndex < _availableList.length; dateIndex++) {
      DateTime date = AppData.instance.getActiveDates()[dateIndex];

      bool addRow = date.weekday != DateTime.saturday ||
          date.weekday == DateTime.saturday &&
              AppData.instance.isZamoTrainer(AppData.instance.getTrainer().pk);

      if (addRow) {
        result.add(DataRow(
            cells: _buildDataCells(dateIndex),
            color: wh.getDaySchemaRowColor(dateIndex)));
      }
    }

    return result;
  }

  List<DataCell> _buildDataCells(int dateIndex) {
    List<DataCell> result = [];

    result.add(_buildDayDataCell(dateIndex));
    result.add(_buildRadioButtonDataCell(dateIndex, 1, Colors.green));
    result.add(_buildRadioButtonDataCell(dateIndex, 0, Colors.red));
    result.add(_buildRadioButtonDataCell(dateIndex, 2, Colors.brown));

    return result;
  }

  DataCell _buildDayDataCell(int dateIndex) {
    DateTime datetime = AppData.instance.getActiveDates()[dateIndex];
    String label = AppHelper.instance.getSimpleDayString(datetime);
    return DataCell(Center(child: Text(label)));
  }

  DataCell _buildRadioButtonDataCell(int dateIndex, int value, Color color) {
    int avail = _availableList[dateIndex];
    return DataCell(RadioButtonWidget.forAvailability(
        key: UniqueKey(),
        dateIndex: dateIndex,
        value: avail,
        rbValue: value,
        color: color));
  }

  Widget? _buildFab() {
    if (AppData.instance.isSchemaDirty()) {
      return FloatingActionButton(
        onPressed: _onSaveSchema,
        hoverColor: Colors.greenAccent,
        child: _fabIcon,
      );
    } else {
      return null;
    }
  }

  void _onSaveSchema() {
    setState(() {
      AppController.instance.updateTrainerSchemas();
    });
  }

  void _showSnackbar() {
    TrainerSchema ts = AppData.instance.getTrainerData().trainerSchemas;
    String msg = 'Hallo ${AppData.instance.getTrainer().firstName()} : ';
    Color col = Colors.lightBlue;

    String maand = AppData.instance.getActiveMonthAsString();

    if (ts.isNew != null && ts.isNew!) {
      msg +=
          'Schema voor $maand aangemaakt, deze wordt nu als ingevuld beschouwd';
    } else {
      msg += 'Schema $maand geopend';
      if (AppData.instance.spreadSheetStatus == SpreadsheetStatus.active) {
        msg += ', maar kan niet meer worden gewijzigd want deze is definitief';
        col = Colors.orange;
      }
    }

    wh.showSnackbar(msg, color: col);
  }
}

///----------------------------------------------------------------
///

final double w1 = 0.1 * AppData.instance.screenWidth;
final double w15 = 0.15 * AppData.instance.screenWidth;
final double w2 = 0.25 * AppData.instance.screenWidth;

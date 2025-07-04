import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/widget/animated_fab.dart';
import 'package:rooster/widget/radiobutton_widget.dart';

/*
This page is used to edit the schema for a trainer.
It shows a grid with the days of the month and the availability for each day.
*/
class SchemaEditPage extends StatefulWidget {
  const SchemaEditPage({super.key});

  @override
  State<SchemaEditPage> createState() => _SchemaEditPageState();
}

class _SchemaEditPageState extends State<SchemaEditPage> with AppMixin {
  List<int> _availableList = [];

  _SchemaEditPageState();

  @override
  void initState() {
    AppEvents.onTrainerDataReadyEvent(_onTrainerReady);
    AppEvents.onTrainerUpdatedEvent(_onTrainerPrefUpdatedReady);
    AppEvents.onSchemaUpdatedEvent(_onSchemaUpdated);
    super.initState();
  }

  void _onTrainerReady(TrainerDataReadyEvent event) {
    _handleReadyEvent();
  }

  void _onTrainerPrefUpdatedReady(TrainerUpdatedEvent event) {
    _handleReadyEvent();
  }

  void _handleReadyEvent() {
    if (mounted) {
      setState(() {
        _availableList = AppData.instance.newAvailaibleList;
      });
    }

    if (AppData.instance.stackIndex == PageEnum.editSchema.code) {
      _showSnackbarIfNeeded();
    }
  }

  void _onSchemaUpdated(SchemaUpdatedEvent event) {
    if (mounted) {
      setState(() {
        _availableList = AppData.instance.newAvailaibleList;
        if (AppData.instance.isSchemaDirty()) {
          wh.playWhooshSound();
        }
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
          child: Column(
            children: [
              DataTable(
                headingRowHeight: 30,
                horizontalMargin: 10,
                headingRowColor:
                    WidgetStateColor.resolveWith((states) => c.lonuBlauw),
                columnSpacing: colSpace,
                dataRowMinHeight: 25,
                dataRowMaxHeight: 40,
                columns: _buildHeader('Dag'),
                rows: _buildDataRows(),
              ),
              _showMaxTrainingCountIfNeeded(context),
            ],
          ),
        ),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader(String label) {
    return wh.buildYesNoIfNeededHeader(label);
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (int dateIndex = 0; dateIndex < _availableList.length; dateIndex++) {
      List<DateTime> dates = AppData.instance.getActiveDates();
      if (dateIndex > dates.length - 1) {
        break;
      }

      DateTime date = AppData.instance.getActiveDates()[dateIndex];

      bool addRow = AppHelper.instance
          .addSchemaEditRow(date, AppData.instance.getTrainer());

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
      color: color,
      isEditable: _isEditable(),
    ));
  }

  Widget? _buildFab() {
    if (AppData.instance.isSchemaDirty() && _isEditable()) {
      return FloatingActionButton(
        onPressed: _onSaveSchema,
        hoverColor: Colors.greenAccent,
        child: const AnimatedFab(),
      );
    } else {
      return null;
    }
  }

  void _onSaveSchema() async {
    bool result = await AppController.instance.updateTrainerSchemas();
    if (result) {
      wh.showSnackbar('Met succes wijzigingen opgeslagen!',
          color: Colors.lightGreen);
    }
  }

  void _showSnackbarIfNeeded() {
    TrainerSchema ts = AppData.instance.getTrainerData().trainerSchemas;
    String msg = 'Hallo ${AppData.instance.getTrainer().firstName()} : ';
    Color col = Colors.lightBlue;
    int seconds = 2;

    String maand = AppData.instance.getActiveMonthAsString();

    if (ts.isNew != null && ts.isNew!) {
      msg +=
          'Schema voor $maand aangemaakt, deze wordt nu als ingevuld beschouwd';
    } else {
      msg += 'Schema $maand geopend';
      // make use the datecheck is correct
      if (!_isEditable()) {
        msg += ', maar kan niet meer worden gewijzigd want deze is definitief';
        col = Colors.orange;
        seconds = 3;
      }
    }

    wh.showSnackbar(msg, color: col, seconds: seconds);
  }
}

///------------------------------------------------
bool _isEditable() {
  TrainerSchema ts = AppData.instance.getTrainerData().trainerSchemas;
  DateTime tsDate = DateTime(ts.year, ts.month, 1);
  // make use the datecheck is correct
  DateTime useDate = AppData.instance.lastActiveDate.copyWith(day: 2);
  return !useDate.isAfter(tsDate);
}

///------------------------------------------------
Widget _showMaxTrainingCountIfNeeded(BuildContext context) {
  int maxTrainingCount =
      AppData.instance.getTrainer().getMaxTrainingCountValue();
  if (maxTrainingCount < 5) {
    return Column(
      children: [
        Text(
          'Max aantal trainingen/maand staat nu op : $maxTrainingCount',
          style: const TextStyle(fontSize: 16, color: Colors.orange),
        ),
        Text(
          'Je kunt dit aanpassen in Voorkeuren.',
          style: const TextStyle(fontSize: 16, color: Colors.orange),
        ),
      ],
    );
  } else {
    return const SizedBox.shrink();
  }
}

///----------------------------------------------------------------

final double w1 = 0.1 * AppData.instance.screenWidth;
final double w15 = 0.15 * AppData.instance.screenWidth;
final double w2 = 0.25 * AppData.instance.screenWidth;

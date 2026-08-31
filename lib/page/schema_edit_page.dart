import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/widget/animated_fab.dart';
import 'package:rooster/widget/radiobutton_widget.dart';
import 'package:collection/collection.dart';

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
  _SchemaEditPageState();

// hier worden de nieuwe beschikbaarheden van de trainer opgeslagen, todat deze worden geSAVEd
  // daarna wordt de nieuwe lijst gekopieerd naar de _trainerData.trainerSchemas.availableDataList
  List<AvailableData> _updatedAvailableDataList = [];

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
        _updatedAvailableDataList = AppData.instance.cloneAvailableDataList();
      });
    }

    if (AppData.instance.stackIndex == PageEnum.editSchema.code) {
      _showSnackbarIfNeeded();
    }
  }

  void _onSchemaUpdated(SchemaUpdatedEvent event) {
    if (mounted) {
      setState(() {
        AppData.instance.cloneAvailableDataList();
        if (_isSchemaDirty()) {
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

    for (AvailableData availableData in AppData.instance
        .getTrainerData()
        .trainerSchemas
        .trainerAvailableList) {
      DateTime date = DateTime(AppData.instance.getActiveYear(),
          AppData.instance.getActiveMonth(), availableData.day);

      bool addRow = AppHelper.instance
          .addSchemaEditRow(date, AppData.instance.getTrainer());

      if (addRow) {
        result.add(DataRow(
            cells: _buildDataCells(day: availableData.day),
            color: wh.getDaySchemaRowColor(availableData.day)));
      }
    }

    return result;
  }

  List<DataCell> _buildDataCells({required int day}) {
    List<DataCell> result = [];

    AvailableData availableData = _getAvailableDataForDay(day);
    int availableValue = availableData.value;

    result.add(_buildDayDataCell(day: day));
    result.add(_buildRadioButtonDataCell(
        day: day,
        value: 1,
        color: Colors.green,
        availableValue: availableValue));

    result.add(_buildRadioButtonDataCell(
        day: day, value: 0, color: Colors.red, availableValue: availableValue));

    result.add(_buildRadioButtonDataCell(
        day: day,
        value: 2,
        color: Colors.brown,
        availableValue: availableValue));

    return result;
  }

  DataCell _buildDayDataCell({required int day}) {
    DateTime datetime = DateTime(AppData.instance.getActiveYear(),
        AppData.instance.getActiveMonth(), day);
    String label = AppHelper.instance.getSimpleDayString(datetime);
    return DataCell(Center(child: Text(label)));
  }

  DataCell _buildRadioButtonDataCell(
      {required int day,
      required int value,
      required Color color,
      required int availableValue}) {
    return DataCell(RadioButtonWidget.forAvailability(
      key: UniqueKey(),
      availableData: _getAvailableDataForDay(day),
      buttomValue: value,
      isEditable: _isEditable(),
    ));
  }

  //----------------------------------------
  AvailableData _getAvailableDataForDay(int day) {
    AvailableData? availableData =
        _updatedAvailableDataList.firstWhereOrNull((e) => e.day == day);
    return availableData ?? AvailableData(day: day, value: -1);
  }

  //----------------------------------------
  Widget? _buildFab() {
    if (_isSchemaDirty() && _isEditable()) {
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
    bool result = await AppController.instance.updateTrainerSchema(
        updatedAvailableDataList: _updatedAvailableDataList);
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

  ///-----------------------------------
  bool _isSchemaDirty() {
    for (int i = 0; i < _updatedAvailableDataList.length; i++) {
      AvailableData newAvailableData = _updatedAvailableDataList[i];
      AvailableData oldAvailableData = AppHelper.instance
          .getTrainerAvailableDataForDay(newAvailableData.day);

      if (oldAvailableData.value != newAvailableData.value) {
        return true;
      }
    }
    return false;
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

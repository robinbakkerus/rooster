import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
// import 'package:rooster/page/start_page.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';

class SchemaEditPage extends StatefulWidget {
  const SchemaEditPage({super.key});

  @override
  State<SchemaEditPage> createState() => _SchemaEditPageState();
}

class _SchemaEditPageState extends State<SchemaEditPage> with AppMixin {
  final Icon _fabIcon = const Icon(Icons.save);
  List<DaySchema> _daySchemaList = [];

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
        _daySchemaList = AppData.instance.getNewSchemas();
      });
    }

    if (AppData.instance.stackIndex == PageEnum.editSchema.code) {
      _showSnackbar();
    }
  }

  void _onSchemaUpdated(SchemaUpdatedEvent event) {
    if (mounted) {
      setState(() {
        _daySchemaList = AppData.instance.getNewSchemas();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildGrid(),
      floatingActionButton: _getFab(),
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
          dataRowMinHeight: 25,
          dataRowMaxHeight: 40,
          columns: _buildHeader(),
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    var headerLabels = ['Dag', 'Ja', 'Nee', 'Als nodig'];
    var colors = [Colors.black, Colors.green, Colors.red, Colors.brown];

    for (int i = 0; i < headerLabels.length; i++) {
      result.add(DataColumn(
          label: Center(
        child: Text(headerLabels[i],
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: colors[i])),
      )));
    }
    return result;
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (DaySchema daySchema in _daySchemaList) {
      result.add(DataRow(
          cells: _buildDataCells(daySchema), color: _getRowColor(daySchema)));
    }

    return result;
  }

  MaterialStateColor _getRowColor(DaySchema daySchema) {
    MaterialStateColor col =
        MaterialStateColor.resolveWith((states) => Colors.white);

    DateTime date = DateTime(daySchema.year, daySchema.month, daySchema.day);

    if (date.weekday == DateTime.tuesday) {
      col = MaterialStateColor.resolveWith((states) => c.lightGeen);
    } else if (date.weekday == DateTime.thursday) {
      col = MaterialStateColor.resolveWith((states) => c.lightOrange);
    } else if (date.weekday == DateTime.saturday) {
      col = MaterialStateColor.resolveWith((states) => c.lightBrown);
    }

    return col;
  }

  List<DataCell> _buildDataCells(DaySchema daySchema) {
    List<DataCell> result = [];

    result.add(_buildDayDataCell(daySchema));
    result.add(_buildRadioButtonDataCell(daySchema, 1, Colors.green));
    result.add(_buildRadioButtonDataCell(daySchema, 0, Colors.red));
    result.add(_buildRadioButtonDataCell(daySchema, 2, Colors.brown));

    return result;
  }

  DataCell _buildDayDataCell(DaySchema daySchema) {
    DateTime datetime =
        DateTime(daySchema.year, daySchema.month, daySchema.day);
    String label = AppHelper.instance.getSimpleDayString(datetime);
    return DataCell(Center(child: Text(label)));
  }

  DataCell _buildRadioButtonDataCell(
      DaySchema daySchema, int value, Color color) {
    return DataCell(RadioButtonWidget(
        key: UniqueKey(), daySchema: daySchema, rbValue: value, color: color));
  }

  Widget? _getFab() {
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

    if (ts.isNew != null && ts.isNew!) {
      msg +=
          'Met succes nieuw schema aangemaakt, deze wordt nu als ingevuld beschouwd';
    } else {
      msg += 'Met succes schema geopend';
      if (AppData.instance.schemaIsFinal()) {
        msg += ', maar kan niet meer worden gewijzigd want deze is definitief';
        col = Colors.orange;
      }
    }

    wh.showSnackbar(msg, color: col);
  }
}

///----------------------------------------------------------------
///

class RadioButtonWidget extends StatefulWidget {
  final DaySchema daySchema;
  final int rbValue;
  final Color color;

  const RadioButtonWidget({
    required Key key,
    required this.daySchema,
    required this.rbValue,
    required this.color,
  }) : super(key: key);

  @override
  State<RadioButtonWidget> createState() => _RadioButtonWidgetState();
}

///------------------------------------------------

class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  int? selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return _radioButton();
  }

  Widget _radioButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
        child: Radio<int>(
          activeColor: widget.color,
          value: widget.daySchema.available,
          groupValue: widget.rbValue,
          onChanged: (val) => onChangeValue(val),
        ),
      ),
    );
  }

  void onChangeValue(int? value) {
    setState(() {
      AppData.instance.updateAvailability(widget.daySchema, widget.rbValue);
      AppEvents.fireSchemaUpdated();
    });
  }
}

final double w1 = 0.1 * AppData.instance.screenWidth;
final double w15 = 0.15 * AppData.instance.screenWidth;
final double w2 = 0.25 * AppData.instance.screenWidth;

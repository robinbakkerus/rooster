import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/data_helper.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';

class SchemaEditPage extends StatefulWidget {
  const SchemaEditPage({super.key});

  @override
  State<SchemaEditPage> createState() => _SchemaEditPageState();
}

class _SchemaEditPageState extends State<SchemaEditPage> {
  final Icon _fabIcon = const Icon(Icons.save);
  List<DaySchema> _daySchemaList = [];

  _SchemaEditPageState() {
    AppEvents.onTrainerDataReadyEvent(_onReady);
    AppEvents.onSchemaUpdatedEvent(_onSchemaUpdated);
  }

  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _daySchemaList = AppData.instance.getNewSchemas();
      });
    }

    _showSnackbar();
  }

  void _onSchemaUpdated(SchemaUpdatedEvent event) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnWidgets = [];
    columnWidgets.add(_buildTopRow()!);
    for (DaySchema daySchema in _daySchemaList) {
      columnWidgets
          .add(ScheduleItemWidget(key: UniqueKey(), daySchema: daySchema));
    }

    return Scaffold(
      body: SizedBox(
        height: AppData.instance.screenHeight - 150,
        // width: AppData.instance.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnWidgets,
        ),
      ),
      floatingActionButton: _getFab(),
    );
  }

  Widget? _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _topRowBox(w15, 'Dag', Colors.blue),
        _topRowBox(w15, 'Ja', Colors.green),
        _topRowBox(w15, 'Nee', Colors.red),
        _topRowBox(w2, 'Als nodig', Colors.lightBlueAccent),
      ],
    );
  }

  Widget _topRowBox(double width, String title, Color color) {
    return Container(
      width: width,
      color: color,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1, 4, 1),
        child: Text(title),
      ),
    );
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
      if (_isReadonly()) {
        msg += ', maar kan niet meer worden gewijzigd want deze is definitief';
        col = Colors.orange;
      }
    }

    WidgetHelper.showSnackbar(msg, color: col);
  }

  bool _isReadonly() {
    DateTime activeDate = AppData.instance.getActiveDate();
    DateTime lastActiveDate = AppData.instance.lastActiveDate;
    return !activeDate.isAfter(lastActiveDate);
  }
}

///----------------------------------------------------------------
///

class ScheduleItemWidget extends StatefulWidget {
  final DaySchema daySchema;

  const ScheduleItemWidget({
    required Key key,
    required this.daySchema,
  }) : super(key: key);

  @override
  State<ScheduleItemWidget> createState() => _ScheduleItemWidgetState();
}

///------------------------------------------------

class _ScheduleItemWidgetState extends State<ScheduleItemWidget> {
  int? selectedOption = 1;

  int _getAvailable() => widget.daySchema.available;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(0)),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: Colors.grey,
            width: 0.2,
          )),
      child: Row(
        children: [
          _dayLabel(),
          _radioButton(1, Colors.green),
          _radioButton(0, Colors.red),
          _radioButton(2, Colors.brown),
        ],
      ),
    );
  }

  Widget _dayLabel() {
    DateTime dt = DateTime(
        widget.daySchema.year, widget.daySchema.month, widget.daySchema.day);
    String label = DataHelper.instance.getSimpleDayString(dt);
    return SizedBox(
      width: w15,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1, 1, 1),
        child: Text(label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _radioButton(int currentValue, Color color) {
    return SizedBox(
      width: w15,
      child: Center(
        child: Radio<int>(
          activeColor: color,
          value: currentValue,
          groupValue: _getAvailable(),
          onChanged: (val) => onChangeValue(val),
        ),
      ),
    );
  }

  void onChangeValue(int? value) {
    setState(() {
      selectedOption = value;
      widget.daySchema.available = value!;
      AppData.instance.updateAvailability(widget.daySchema, value);
      AppEvents.fireSchemaUpdated();
    });
  }
}

final double w1 = 0.1 * AppData.instance.screenWidth;
final double w15 = 0.15 * AppData.instance.screenWidth;
final double w2 = 0.25 * AppData.instance.screenWidth;

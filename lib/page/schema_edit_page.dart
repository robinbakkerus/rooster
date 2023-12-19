import 'dart:developer';

import 'package:firestore/data/trainer_data.dart';
import 'package:firestore/event/app_events.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/util/data_parser.dart';
import 'package:flutter/material.dart';
import 'package:firestore/controller/app_controler.dart';

class SchemaEditPage extends StatefulWidget {
  SchemaEditPage({super.key}) {
    if (TrainerData.instance.trainerId.isNotEmpty) {
      // AppController.instance.getTrainerData(TrainerData.instance.trainerId);
    }
  }

  @override
  State<SchemaEditPage> createState() => _SchemaEditPageState();
}

class _SchemaEditPageState extends State<SchemaEditPage> {
  Trainer trainer = Trainer.unknown();
  String topTitle = '...';
  bool firstTime = true;
  Icon fabIcon = const Icon(Icons.done);
  List<DaySchema> listsData = [];

  _SchemaEditPageState() {
    AppEvents.onTrainerDataReadyEvent(_onReady);
    AppEvents.onSchemaUpdatedEvent(_onSchemaUpdated);
  }

  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        trainer = TrainerData.instance.trainer;
        topTitle = '${trainer.fullname} : Januari 2024';
        listsData = TrainerData.instance.newSchemas;
        log(listsData.length.toString());
      });
    }
  }

  void _onSchemaUpdated(SchemaUpdatedEvent event) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: listsData.length,
        itemBuilder: (context, index) {
          return ScheduleItem(daySchema: listsData[index]);
        },
      ),
      floatingActionButton: _getFab(),
    );
  }

  Widget? _getFab() {
    if (TrainerData.instance.isDirty() || firstTime) {
      return FloatingActionButton(
        onPressed: _onSave,
        hoverColor: Colors.greenAccent,
        child: fabIcon,
      );
    } else {
      return null;
    }
  }

  void _onSave() {
    setState(() {
      firstTime = false;
      fabIcon = const Icon(Icons.save);

      AppController.instance.updateSchemas();
    });
  }
}

///----------------------------------------------------------------
///

class ScheduleItem extends StatefulWidget {
  final DaySchema daySchema;

  const ScheduleItem({
    Key? key,
    required this.daySchema,
  }) : super(key: key);

  @override
  State<ScheduleItem> createState() => _ScheduleItemState();
}

///------------------------------------------------

class _ScheduleItemState extends State<ScheduleItem> {
  int? selectedOption = 1;

  int _getAvailable() => widget.daySchema.available;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          _dayLabel(),
          _radioButton('Ja', 1, Colors.green),
          _radioButton('Nee', 0, Colors.red),
          _radioButton('Alleen als nodig', 2, Colors.brown),
        ],
      ),
    );
  }

  Widget _dayLabel() {
    DateTime dt = DateTime(
        widget.daySchema.year, widget.daySchema.month, widget.daySchema.day);
    String label = '${DateParser.parse(dt)}}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      child: SizedBox(
        width: 180,
        child: Text(label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _radioButton(String label, int currentValue, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        Radio<int>(
          activeColor: color,
          value: currentValue,
          groupValue: _getAvailable(),
          onChanged: (val) => _onChangeValue(val),
        ),
      ]),
    );
  }

  void _onChangeValue(int? value) {
    setState(() {
      selectedOption = value;
      widget.daySchema.available = value!;
      TrainerData.instance.update(widget.daySchema, value);
      AppEvents.fireSchemaUpdated();
    });
  }
}

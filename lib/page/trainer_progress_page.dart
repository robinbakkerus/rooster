import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';
import 'package:rooster/widget/widget_helper.dart';

class TrainerProgressPage extends StatefulWidget {
  const TrainerProgressPage({super.key});

  @override
  State<TrainerProgressPage> createState() => _TrainerProgressPageState();
}

class _TrainerProgressPageState extends State<TrainerProgressPage> {
  // varbs
  List<Trainer> _allTrainers = [];

  final double _screenWidth = AppData.instance.screenWidth;

  _TrainerProgressPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
  }

  @override
  void initState() {
    _allTrainers = AppData.instance.getAllTrainers();
    super.initState();
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _allTrainers = AppData.instance.getAllTrainers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: _getColumnChildren(),
      ),
    );
  }

  List<Widget> _getColumnChildren() {
    List<Widget> list = [];
    Widget topRow = _buildTopRow();

    list.add(topRow);

    for (Trainer trainer in _allTrainers) {
      Widget w = Row(
        children: [
          SizedBox(
              width: WH.w25,
              child: Text(
                trainer.firstName(),
                overflow: TextOverflow.ellipsis,
              )),
          _buildEntered(trainer),
        ],
      );
      list.add(w);
    }

    return list;
  }

  Widget _buildTopRow() {
    Widget topRow = Row(
      children: [
        Container(
            width: WH.w25, color: Colors.lightBlue, child: const Text('naam')),
        Container(
            width: WH.w2,
            color: Colors.lightGreen,
            child: const Center(child: Text('Ingevuld?'))),
      ],
    );
    return topRow;
  }

  Widget _buildEntered(Trainer trainer) {
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

    return SizedBox(width: WH.w2, child: icon);
  }
}

import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/data_helper.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'package:flutter/material.dart';

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({super.key});

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  _AvailabilityPageState() {
    AppEvents.onAllTrainersAndSchemasReadyEvent(_onReady);
  }

  @override
  void initState() {
    super.initState();
  }

  void _onReady(AllTrainersDataReadyEvent event) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: _buildColumnChildren(),
      ),
    );
  }

  List<Widget> _buildColumnChildren() {
    List<Widget> list = [];
    Widget topRow = _buildTopRow();

    list.add(topRow);

    for (DateTime dateTime in AppData.instance.getActiveDates()) {
      String s = DataHelper.instance.getSimpleDayString(dateTime);
      Widget w = Row(
        children: [
          SizedBox(width: w15, child: Text(s)),
          _buildAvailableRow(dateTime),
        ],
      );
      list.add(w);
      list.add(WidgetHelper.verSpace(1));
    }

    return list;
  }

  Widget _buildTopRow() {
    Widget topRow = Row(
      children: [
        Container(
            width: w15, color: Colors.lightBlue, child: const Text('Dag')),
        WidgetHelper.horSpace(1),
        Container(width: w2, color: Colors.lightGreen, child: const Text('PR')),
        WidgetHelper.horSpace(1),
        Container(width: w2, color: Colors.lightGreen, child: const Text('R1')),
        WidgetHelper.horSpace(1),
        Container(width: w2, color: Colors.lightGreen, child: const Text('R2')),
        WidgetHelper.horSpace(1),
        Container(width: w2, color: Colors.lightGreen, child: const Text('R3')),
      ],
    );
    return topRow;
  }

  Widget _buildAvailableRow(DateTime dateTime) {
    return Row(
      children: [
        _buildAvailableField(Groep.pr, dateTime),
        WidgetHelper.horSpace(1),
        _buildAvailableField(Groep.r1, dateTime),
        WidgetHelper.horSpace(1),
        _buildAvailableField(Groep.r2, dateTime),
        WidgetHelper.horSpace(1),
        _buildAvailableField(Groep.r3, dateTime),
      ],
    );
  }

  Widget _buildAvailableField(Groep group, DateTime dateTime) {
    AvailableCounts cnts =
        DataHelper.instance.getAvailableCounts(group, dateTime);

    String fieldText =
        '${cnts.confirmed.length}, ${cnts.ifNeeded.length}, ${cnts.notEnteredYet.length}';
    Color color = _buildAvailFieldColor(cnts, WidgetHelper.color1);
    return _buildAvailableFieldWidget(group, dateTime, color, fieldText);
  }

  Color _buildAvailFieldColor(AvailableCounts cnts, Color color) {
    if (cnts.confirmed.isNotEmpty) {
      color = WidgetHelper.color2;
    } else if (cnts.confirmed.isEmpty &&
        cnts.ifNeeded.isEmpty &&
        cnts.notEnteredYet.isEmpty) {
      color = WidgetHelper.color3;
    }
    return color;
  }

  Widget _buildAvailableFieldWidget(
      Groep group, DateTime dateTime, Color color, String text) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 0.1), color: color),
        width: w2,
        child: Text(text),
      ),
      onTap: () {
        _dialogBuilder(context, group, dateTime);
      },
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, Groep group, DateTime dateTime) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 300,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _buildAvailDetail(group, dateTime),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Sluit"))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailDetail(Groep group, DateTime dateTime) {
    AvailableCounts cnts =
        DataHelper.instance.getAvailableCounts(group, dateTime);

    List<Widget> colWidgets = [];

    colWidgets.add(const Text(
      'Aanwezig',
      style: TextStyle(color: Colors.green),
    ));
    colWidgets.add(_horLine());

    for (Trainer trainer in cnts.confirmed) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }
    colWidgets.add(WidgetHelper.verSpace(20));

    colWidgets.add(const Text(
      'Alleen als nodig',
      style: TextStyle(color: Colors.orange),
    ));
    colWidgets.add(_horLine());

    for (Trainer trainer in cnts.ifNeeded) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }
    colWidgets.add(WidgetHelper.verSpace(20));

    colWidgets.add(const Text('Nog niet ingevuld',
        style: TextStyle(
          color: Colors.brown,
        )));
    colWidgets.add(_horLine());

    for (Trainer trainer in cnts.notEnteredYet) {
      Widget w = Text(trainer.firstName());
      colWidgets.add(w);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colWidgets,
    );
  }

  _horLine() {
    return Container(
      height: 1,
      color: Colors.grey,
    );
  }
}

final double w15 = 0.15 * AppData.instance.screenWidth;
final double w2 = 0.2 * AppData.instance.screenWidth;
const Color colLightYellow = Color(0xffF4E9CA);
const Color colLightGreen = Color(0xffA6CD7A);
const Color colLightRed = Color(0xffF6AB94);

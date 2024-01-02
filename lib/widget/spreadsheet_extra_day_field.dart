import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:flutter/material.dart';
import 'package:rooster/util/data_helper.dart';
import 'package:rooster/widget/widget_helper.dart';

class SpreadsheeDayColumn extends StatefulWidget {
  final SheetRow sheetRow;
  final double width;
  const SpreadsheeDayColumn(
      {required super.key, required this.sheetRow, required this.width});

  @override
  State<SpreadsheeDayColumn> createState() => _SpreadsheeDayColumnState();
}

//--------------------------------
class _SpreadsheeDayColumnState extends State<SpreadsheeDayColumn> {
  final _textTextCtrl = TextEditingController();
  final _textDayCtrl = TextEditingController();
  bool _showRemoveButton = false;

  @override
  void initState() {
    _textDayCtrl.text = widget.sheetRow.date.day.toString();
    _textTextCtrl.text = widget.sheetRow.trainingText;
    _showRemoveButton = widget.sheetRow.trainingText.isNotEmpty;
    super.initState();
  }

  @override
  void dispose() {
    _textTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color col = widget.sheetRow.isExtraRow ? Colors.white : WH.color1;
    return InkWell(
      onTap: () => _dialogBuilder(context),
      child: Container(
          width: widget.width,
          decoration: BoxDecoration(border: Border.all(width: 0.1), color: col),
          child: Text(
            DataHelper.instance.getSimpleDayString(widget.sheetRow.date),
            overflow: TextOverflow.ellipsis,
          )),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 300,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                ),
                _buildDayField(),
                _buildExtraTextField(),
                _showRemoveButton
                    ? _buildRemoveExtraRowButton(context)
                    : Container(),
                WH.verSpace(10),
                _buildCloseButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: WH.w1,
            child: TextField(
                controller: _textDayCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  labelText: "Dag",
                  hintText: "Dag",
                )),
          ),
        ),
        WH.horSpace(10),
        Text(_monthAsString()),
      ],
    );
  }

  String _monthAsString() {
    var formatter = DateFormat('MMM');
    return formatter.format(AppData.instance.getActiveDate());
  }

  Widget _buildExtraTextField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: _textTextCtrl,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Extra regel',
          isDense: true, // Added this
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            int dag = int.parse(_textDayCtrl.text);
            AppEvents.fireExtraDayUpdatedEvent(dag, _textTextCtrl.text);
          });
          Navigator.of(context, rootNavigator: true)
              .pop(); // dismisses only the dialog and returns nothing
        },
        child: const Text("Close"));
  }

  Widget _buildRemoveExtraRowButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            int dag = widget.sheetRow.date.day;
            AppEvents.fireExtraDayUpdatedEvent(
                dag, WH.removeExtraSpreadsheetRow);
          });
          Navigator.of(context, rootNavigator: true)
              .pop(); // dismisses only the dialog and returns nothing
        },
        child: const Text("Verwijder deze regel"));
  }
}

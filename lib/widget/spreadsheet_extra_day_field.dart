import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';

class SpreadsheetDayColumn extends StatefulWidget {
  final SheetRow sheetRow;
  const SpreadsheetDayColumn({required super.key, required this.sheetRow});

  @override
  State<SpreadsheetDayColumn> createState() => _SpreadsheetDayColumnState();
}

//--------------------------------
class _SpreadsheetDayColumnState extends State<SpreadsheetDayColumn>
    with AppMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Decoration? decoration =
        _isEditable() ? BoxDecoration(border: Border.all(width: 0.1)) : null;
    return InkWell(
      onTap: _isEditable() ? () => _dialogBuilder(context) : null,
      child: Container(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Text(
              AppHelper.instance.getSimpleDayString(widget.sheetRow.date),
              overflow: TextOverflow.ellipsis,
            ),
          )),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SelectDayWidget(sheetRow: widget.sheetRow),
        );
      },
    );
  }

  bool _isEditable() {
    return AppData.instance.getTrainer().isSupervisor() &&
        AppData.instance.spreadSheetStatus != SpreadsheetStatus.active;
  }
}

///-----------------------------------------------------------------------------
class SelectDayWidget extends StatefulWidget {
  final SheetRow sheetRow;
  const SelectDayWidget({super.key, required this.sheetRow});

  @override
  State<SelectDayWidget> createState() => _SelectDayWidgetState();
}

class _SelectDayWidgetState extends State<SelectDayWidget> with AppMixin {
  final _textTextCtrl = TextEditingController();
  bool _showRemoveButton = false;
  late DateTime _selectDate;
  late Widget _dayField;

  @override
  void initState() {
    _selectDate = widget.sheetRow.date;
    _textTextCtrl.text =
        widget.sheetRow.isExtraRow ? widget.sheetRow.trainingText : '';
    _showRemoveButton =
        widget.sheetRow.isExtraRow && widget.sheetRow.trainingText.isNotEmpty;
    _dayField = _buildDayFieldRow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
          ),
          _dayField,
          _buildExtraTextField(),
          wh.verSpace(10),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildDayFieldRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        wh.horSpace(15),
        _dayAsString(),
        wh.horSpace(15),
        _plusMinButton('-'),
        wh.horSpace(10),
        Text(_selectDate.day.toString()),
        wh.horSpace(10),
        _plusMinButton('+'),
        wh.horSpace(15),
        _monthAsString(),
      ],
    );
  }

  Widget _plusMinButton(String txt) {
    return SizedBox(
      width: 20,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            shape: const BeveledRectangleBorder(
                side: BorderSide(color: Colors.grey)),
            elevation: 0,
          ),
          onPressed: () {
            setState(() {
              if (txt == '+') {
                _selectDate = _selectDate.add(const Duration(days: 1));
              } else {
                _selectDate = _selectDate.add(const Duration(days: -1));
              }
              _dayField = _buildDayFieldRow();
            });
          },
          child: Text(txt)),
    );
  }

  Widget _dayAsString() {
    var formatter = DateFormat('EEEE', c.localNL);
    return Text(formatter.format(_selectDate));
  }

  Widget _monthAsString() {
    var formatter = DateFormat('MMMM', c.localNL);
    return Text(formatter.format(widget.sheetRow.date));
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

  Widget _buildButtons(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      _showRemoveButton ? _buildRemoveExtraRowButton(context) : Container(),
      wh.horSpace(10),
      _buildCancelButton(context),
      wh.horSpace(10),
      _buildSaveButton(context),
    ]);
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            AppEvents.fireExtraDayUpdatedEvent(
                _selectDate.day, _textTextCtrl.text);
          });
          Navigator.of(context, rootNavigator: true)
              .pop(); // dismisses only the dialog and returns nothing
        },
        child: const Text("Save"));
  }

  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true)
              .pop(); // dismisses only the dialog and returns nothing
        },
        child: const Text("Cancel"));
  }

  Widget _buildRemoveExtraRowButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            int dag = widget.sheetRow.date.day;
            AppEvents.fireExtraDayUpdatedEvent(
                dag, c.removeExtraSpreadsheetRow);
          });
          Navigator.of(context, rootNavigator: true)
              .pop(); // dismisses only the dialog and returns nothing
        },
        child: const Text("Verwijder deze regel"));
  }
}

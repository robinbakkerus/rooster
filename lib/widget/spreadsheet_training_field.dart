import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:flutter/material.dart';

class SpreadsheetTrainingColumn extends StatefulWidget {
  final SheetRow sheetRow;
  final bool isEditable;
  const SpreadsheetTrainingColumn(
      {required super.key, required this.sheetRow, required this.isEditable});

  @override
  State<SpreadsheetTrainingColumn> createState() =>
      _SpreadsheetTrainingColumnState();
}

//--------------------------------
class _SpreadsheetTrainingColumnState extends State<SpreadsheetTrainingColumn> {
  final _textCtrl = TextEditingController();
  String _training = '';

  @override
  void initState() {
    _training = _getText();
    _textCtrl.text = _training;
    super.initState();
  }

  String _getText() {
    if (widget.sheetRow.isExtraRow) {
      return widget.sheetRow.trainingText;
    } else {
      if (widget.sheetRow.trainingText.isEmpty) {
        return widget.sheetRow.date.weekday == DateTime.saturday ? '' : '*';
      } else {
        return widget.sheetRow.trainingText;
      }
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Decoration? decoration =
        isEditable() ? BoxDecoration(border: Border.all(width: 0.1)) : null;
    return InkWell(
      onTap: isEditable()
          ? () => _buildEditTrainingDialog(context)
          : () => _buildReadOnlyDialog(context),
      child: Container(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Text(
              _training,
              overflow: TextOverflow.ellipsis,
            ),
          )),
    );
  }

  Future<void> _buildEditTrainingDialog(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: _buildDropdown(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Training',
                      isDense: true, // Added this
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _training = _textCtrl.text;
                          AppEvents.fireTrainingUpdatedEvent(
                              widget.sheetRow.rowIndex, _training);
                        });
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // dismisses only the dialog and returns nothing
                      },
                      child: const Text('Save')),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _buildReadOnlyDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(_textCtrl.text),
          ),
        );
      },
    );
  }

  Widget _buildDropdown() {
    String topVal = 'training...';
    List<String> trainingItems = [topVal];
    trainingItems.addAll(AppData.instance.trainerItems);

    return DropdownButton(
        value: topVal,
        items: trainingItems.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: _onDropdownSelected);
  }

  bool isEditable() {
    bool b = (widget.isEditable &&
            AppData.instance.getTrainer().isSupervisor()) ||
        (widget.isEditable &&
            widget.sheetRow.date.weekday == DateTime.saturday &&
            AppData.instance.isZamoTrainer(AppData.instance.getTrainer().pk));
    return b;
  }

  void _onDropdownSelected(Object? value) {
    setState(() {
      _training = value.toString();
      _textCtrl.text = _training;
    });

    AppEvents.fireTrainingUpdatedEvent(widget.sheetRow.rowIndex, _training);

    Navigator.of(context, rootNavigator: true)
        .pop(); // dismisses only the dialog and returns nothing
  }
}

import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:flutter/material.dart';
import 'package:rooster/widget/widget_helper.dart';

class SpreadsheetTrainingColumn extends StatefulWidget {
  final SheetRow sheetRow;
  final double width;
  const SpreadsheetTrainingColumn(
      {required super.key, required this.sheetRow, required this.width});

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
    if (_isExtraRow()) {
      return widget.sheetRow.trainingText;
    } else {
      if (widget.sheetRow.trainingText.isEmpty) {
        return widget.sheetRow.date.weekday == DateTime.saturday ? '' : '...';
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
    Color col = _isExtraRow() ? Colors.white : WH.color1;
    return InkWell(
      onTap: _isSupervisor() ? () => _dialogBuilder(context) : null,
      child: Container(
          width: widget.width,
          decoration: BoxDecoration(border: Border.all(width: 0.1), color: col),
          child: Text(
            _training,
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
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _training = _textCtrl.text;
                        AppEvents.fireTrainingUpdatedEvent(
                            widget.sheetRow.rowIndex, _training);
                      });
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // dismisses only the dialog and returns nothing
                    },
                    child: const Text("Close"))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown() {
    var items = [
      'training...',
      'rustige duurloop',
      'duurloop hestel',
      'pyramide loop',
      'climax duurloop',
      'interval kort',
      'interval lang',
      'bosloop',
      'gulbergen',
      'fartlek'
    ];
    return DropdownButton(
        value: 'training...',
        items: items.map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items),
          );
        }).toList(),
        onChanged: _onDropdownSelected);
  }

  bool _isExtraRow() => widget.sheetRow.isExtraRow;
  bool _isSupervisor() {
    return AppData.instance.getTrainer().isSupervisor();
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

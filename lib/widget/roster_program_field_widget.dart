import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:flutter/material.dart';

class SpreadsheetTrainingColumn extends StatefulWidget {
  final SheetRow sheetRow;
  final double width;
  const SpreadsheetTrainingColumn(
      {super.key, required this.sheetRow, required this.width});

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
    _training = widget.sheetRow.date.weekday == DateTime.saturday ? '' : '...';
    super.initState();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color col = const Color(0xffF4E9CA);
    return InkWell(
      onTap: () => _dialogBuilder(context),
      child: Container(width: widget.width, color: col, child: Text(_training)),
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
                      labelText: 'Programma',
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

  void _onDropdownSelected(Object? value) {
    setState(() {
      _training = value.toString();
    });

    AppEvents.fireTrainingUpdatedEvent(widget.sheetRow.rowIndex, _training);

    Navigator.of(context, rootNavigator: true)
        .pop(); // dismisses only the dialog and returns nothing
  }
}

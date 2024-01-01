import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:flutter/material.dart';
import 'package:rooster/util/data_helper.dart';

class SpreadsheetExtraDayColumn extends StatefulWidget {
  final SheetRow sheetRow;
  final double width;
  const SpreadsheetExtraDayColumn(
      {super.key, required this.sheetRow, required this.width});

  @override
  State<SpreadsheetExtraDayColumn> createState() =>
      _SpreadsheetExtraDayColumnState();
}

//--------------------------------
class _SpreadsheetExtraDayColumnState extends State<SpreadsheetExtraDayColumn> {
  final _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _dialogBuilder(context),
      child: Container(
          width: widget.width,
          decoration:
              BoxDecoration(border: Border.all(width: 0.1), color: col1),
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
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Extra',
                      isDense: true, // Added this
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      // setState(() {
                      //   _training = _textCtrl.text;
                      //   AppEvents.fireTrainingUpdatedEvent(
                      //       widget.sheetRow.rowIndex, _training);
                      // });
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
}

const Color col4 = Color(0xffADD3E4);
const Color col1 = Color(0xffF4E9CA);

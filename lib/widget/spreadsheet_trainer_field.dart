import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/util/spreadsheet_generator.dart';

class SpreadsheetTrainerColumn extends StatefulWidget {
  final SheetRow sheetRow;
  final String groupName;
  final bool isEditable;
  const SpreadsheetTrainerColumn(
      {required super.key,
      required this.sheetRow,
      required this.groupName,
      required this.isEditable});

  @override
  State<SpreadsheetTrainerColumn> createState() =>
      _SpreadsheetTrainerColumnState();
}

//--------------------------------
class _SpreadsheetTrainerColumnState extends State<SpreadsheetTrainerColumn>
    with AppMixin {
  final _textTextCtrl = TextEditingController();
  int _groupIndex = 0;

  @override
  void initState() {
    List<String> groupNames =
        SpreadsheetGenerator.instance.getGroupNames(widget.sheetRow.date);
    _groupIndex = groupNames.indexOf(widget.groupName);
    _textTextCtrl.text = widget.sheetRow.rowCells[_groupIndex].text;
    super.initState();
  }

  @override
  void dispose() {
    _textTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String txt = widget.sheetRow.rowCells[_groupIndex].text;
    bool addBorder = txt.isNotEmpty && _isEditable();
    return InkWell(
      onTap: _isEditable() ? () => _dialogBuilder(context) : null,
      child: Container(
          decoration:
              addBorder ? BoxDecoration(border: Border.all(width: 0.1)) : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Text(
              txt,
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
          child: SizedBox(
            height: AppData.instance.screenHeight * 0.8,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wh.verSpace(15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: _buildDropdown(),
                ),
                wh.verSpace(15),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: Text(
                      'Selecteer trainer van hierboven, of geef andere tekst'),
                ),
                wh.verSpace(15),
                _buildOtherTrainerField(),
                wh.verSpace(10),
                _buildCloseButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown() {
    const topVal = 'Trainers ...';
    List<String> trainerList = [topVal];
    trainerList.addAll(
        AppData.instance.getAllTrainers().map((e) => e.firstName()).toList());

    var items = trainerList.map((item) {
      return DropdownMenuItem(
        value: item,
        child: Text(item),
      );
    }).toList();

    return DropdownButton(
      menuMaxHeight: AppData.instance.screenHeight * 0.75,
      isDense: true,
      value: topVal,
      items: items,
      onChanged: _onDropdownSelected,
    );
  }

  void _onDropdownSelected(Object? value) {
    setState(() {});

    AppEvents.fireSpreadsheetTrainerUpdated(
        widget.sheetRow.rowIndex, _groupIndex, value.toString());

    Navigator.of(context, rootNavigator: true).pop();
  }

  bool _isEditable() {
    return (widget.isEditable &&
            AppData.instance.getTrainer().isSupervisor()) ||
        (widget.isEditable && _isSameTrainer());
  }

  bool _isSameTrainer() {
    String name = widget.sheetRow.rowCells[_groupIndex].text;
    Trainer trainer = AppHelper.instance.findTrainerByFirstName(name);
    if (!trainer.isEmpty()) {
      return trainer.pk == AppData.instance.getTrainer().pk;
    } else {
      return false;
    }
  }

  Widget _buildOtherTrainerField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: _textTextCtrl,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Trainer (of iemand anders)',
          isDense: true, // Added this
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          AppEvents.fireSpreadsheetTrainerUpdated(
              widget.sheetRow.rowIndex, _groupIndex, _textTextCtrl.text);

          Navigator.of(context, rootNavigator: true)
              .pop(); // dismisses only the dialog and returns nothing
        },
        child: const Text("Close"));
  }
}

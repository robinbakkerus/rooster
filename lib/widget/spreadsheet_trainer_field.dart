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
    if (widget.sheetRow.rowCells.length > _groupIndex) {
      _textTextCtrl.text = widget.sheetRow.rowCells[_groupIndex].text;
    }

    super.initState();
  }

  @override
  void dispose() {
    _textTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sheetRow.rowCells.length > _groupIndex) {
      return InkWell(
        onTap: _showDialog() ? () => _dialogBuilder(context) : null,
        child: Container(
            decoration: _showDialog()
                ? BoxDecoration(
                    border: Border.all(width: 0.1, color: Colors.grey))
                : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              child: Text(
                widget.sheetRow.rowCells[_groupIndex].text,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      );
    } else {
      return Container();
    }
  }

  bool _isSupervisor() => AppData.instance.getTrainer().isSupervisor();

  bool _showDialog() {
    String txt = widget.sheetRow.rowCells[_groupIndex].text;
    return txt.isNotEmpty && _isEditable();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    if (_isSameTrainer() || _isSupervisor()) {
      return _buildDialogForSupervisorOrOtherTrainer(context);
    } else {
      return _buildDialogForSameTrainer(context);
    }
  }

  Future<void> _buildDialogForSupervisorOrOtherTrainer(BuildContext context) {
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
                _buildCloseAndCancelButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _buildDialogForSameTrainer(BuildContext context) {
    String name = AppData.instance.getTrainer().firstName();
    String question =
        'Hallo $name wil jij training overnemen van ${_trainerName()}?';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: AppData.instance.screenHeight * 0.2,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
                  child: Text(question),
                ),
                wh.verSpace(10),
                _buildYesNoButtons(context),
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
    setState(() {
      _textTextCtrl.text = value.toString();
    });
  }

  bool _isEditable() {
    return widget.isEditable;
  }

  String _trainerName() {
    return widget.sheetRow.rowCells[_groupIndex].text;
  }

  bool _isSameTrainer() {
    String name = _trainerName();
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

  Widget _buildCloseAndCancelButtons(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: () {
              AppEvents.fireSpreadsheetTrainerUpdated(
                  widget.sheetRow.rowIndex, _groupIndex, _textTextCtrl.text);

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Save", style: TextStyle(color: Colors.green))),
        wh.horSpace(10),
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildYesNoButtons(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: () {
              AppEvents.fireSpreadsheetTrainerUpdated(widget.sheetRow.rowIndex,
                  _groupIndex, AppData.instance.getTrainer().firstName());

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Ja", style: TextStyle(color: Colors.green))),
        wh.horSpace(10),
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text(
              "Nee",
              style: TextStyle(color: Colors.red),
            )),
      ],
    );
  }
}

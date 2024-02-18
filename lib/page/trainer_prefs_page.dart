// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:rooster/widget/radiobutton_widget.dart';

class TrainerPrefsPage extends StatefulWidget {
  const TrainerPrefsPage({super.key});

  @override
  State<TrainerPrefsPage> createState() => _TrainerPrefsPageState();
}

class _TrainerPrefsPageState extends State<TrainerPrefsPage> with AppMixin {
  Trainer _trainer = Trainer.empty();
  Trainer _updateTrainer = Trainer.empty();
  final _textEmailCtrl = TextEditingController();
  final _textAccessCodeCtrl = TextEditingController();
  Widget? _fab;
  List<Widget> _columnWidgets = [];

  _TrainerPrefsPageState() {
    AppEvents.onTrainerDataReadyEvent(_onReady);
    AppEvents.onTrainerUpdatedEvent(_onTrainerUpdated);
    AppEvents.onTrainerPrefUpdatedEvent(_onTrainerPrefUpdated);
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);
  }

  @override
  void initState() {
    _trainer = AppData.instance.getTrainer();
    if (!_trainer.isEmpty()) {
      _updateTrainer = _trainer.copyWith();
      _fab = _getFab();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _columnWidgets,
      ),
      floatingActionButton: _fab,
    );
  }

  List<Widget> _buildColumnWidgets() {
    List<Widget> list = [];

    list.addAll(_readOnlyValues());
    list.add(const Padding(
      padding: EdgeInsets.only(left: 20, top: 10),
      child: Text('Voorkeur dagen'),
    ));
    list.add(_buildGridForPrefDays());
    list.add(const Padding(
      padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
      child: Text('Voorkeur groepen'),
    ));
    list.add(_buildGridForPrefGroups());
    return list;
  }

  List<Widget> _readOnlyValues() {
    List<Widget> list = [];
    list.add(_readOnlyRow('PK', 'pk'));
    list.add(_readOnlyRow('Naam', 'fullname'));
    list.add(_readOnlyRow('Rollen', 'roles'));
    list.add(wh.verSpace(10));
    list.add(_accesscodeRow());
    list.add(wh.verSpace(10));
    list.add(_emailRow());
    list.add(const Divider(
      height: 10,
    ));

    return list;
  }

  Widget _readOnlyRow(String label, String mapElem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 2, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: c.w15,
            child: Text(label),
          ),
          wh.horSpace(10),
          SizedBox(
              width: c.w25 * 2,
              child: Text(
                _getStringValue(mapElem),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              )),
        ],
      ),
    );
  }

  Widget _accesscodeRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 2, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: c.w1,
            child: const Text('toegangscode'),
          ),
          wh.horSpace(10),
          SizedBox(
            width: c.w25,
            child: TextField(
              controller: _textAccessCodeCtrl,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Toegangscode 4 letters',
                  contentPadding: EdgeInsets.all(2)),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                _getAllTrainersIfNeeded(value);
                if (_textAccessCodeCtrl.text != value.toUpperCase()) {
                  if (value.length > 4) {
                    value = value.substring(0, 4);
                  }
                  _textAccessCodeCtrl.value = _textAccessCodeCtrl.value
                      .copyWith(text: value.toUpperCase());
                }
                _updateTrainer.accessCode = _textAccessCodeCtrl.text;
                setState(() {
                  _fab = _getFab();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------
  void _getAllTrainersIfNeeded(String value) async {
    if (AppData.instance.getAllTrainerData().isEmpty && value.isNotEmpty) {
      await AppController.instance.getAllTrainerData();
    }
  }

  //----------------------------------
  Widget _emailRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 2, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: c.w1,
            child: const Text('email'),
          ),
          wh.horSpace(10),
          SizedBox(
            width: c.w25 * 3,
            child: TextField(
              controller: _textEmailCtrl,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Geef email adres',
                  contentPadding: EdgeInsets.all(2)),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (_textEmailCtrl.text != value.toLowerCase()) {
                  _textEmailCtrl.value =
                      _textEmailCtrl.value.copyWith(text: value.toLowerCase());
                }
                _updateTrainer.email = _textEmailCtrl.text;
                setState(() {
                  _fab = _getFab();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStringValue(String mapElem) {
    Map<String, dynamic> map = _updateTrainer.toMap();
    return map[mapElem];
  }

  ///------------------------------------------------
  Widget _buildGridForPrefDays() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 30,
            horizontalMargin: 10,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => c.lightblue),
            columnSpacing: colSpace,
            dataRowMinHeight: 25,
            dataRowMaxHeight: 40,
            columns: _buildHeader(),
            rows: _buildDataRowsForPrefDays(),
          ),
        ),
      ),
    );
  }

  ///------------------------------------------------
  Widget _buildGridForPrefGroups() {
    double colSpace = AppHelper.instance.isWindows() ? 30 : 15;
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 30,
            horizontalMargin: 10,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => c.lightblue),
            columnSpacing: colSpace,
            dataRowMinHeight: 25,
            dataRowMaxHeight: 40,
            columns: _buildHeader(),
            rows: _buildDataRowsForPrefGroups(),
          ),
        ),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    return wh.buildYesNoIfNeededHeader();
  }

  //-------------------------
  List<DataRow> _buildDataRowsForPrefDays() {
    List<DataRow> result = [];

    var days = SpreadsheetGenerator.instance.getTrainingDays(locale: c.localNL);

    for (String dag in days) {
      if (_addRowForPrefDay(dag)) {
        result.add(DataRow(cells: _buildDataCells(dag)));
      }
    }

    return result;
  }

  ///-------------------------
  bool _addRowForPrefDay(String dag) {
    int weekday =
        AppHelper.instance.weekdayFromString(weekday: dag, locale: c.localNL);
    return AppData.instance.getTrainer().getDayPrefValue(weekday: weekday) > 0;
  }

  //-------------------------
  List<DataRow> _buildDataRowsForPrefGroups() {
    List<DataRow> result = [];

    for (String groupName
        in AppData.instance.activeTrainingGroups[0].groupNames) {
      if (_addRowForPrefGroup(groupName)) {
        result.add(DataRow(cells: _buildDataCells(groupName)));
      }
    }

    return result;
  }

  ///-------------------------
  bool _addRowForPrefGroup(String groupName) {
    TrainingGroup? trainingGroup =
        AppHelper.instance.getTrainingGroupByName(groupName);
    if (trainingGroup != null &&
        trainingGroup.type == TrainingGroupType.regular) {
      return true;
    } else {
      return AppData.instance
          .isTrainerForGroup(AppData.instance.getTrainer(), groupName);
    }
  }

  //-------------------------
  List<DataCell> _buildDataCells(String paramName) {
    List<DataCell> result = [];

    result.add(DataCell(Text(paramName)));
    result.add(_buildRadioButtonDataCell(paramName, 1, Colors.green));
    result.add(_buildRadioButtonDataCell(paramName, 0, Colors.red));
    result.add(_buildRadioButtonDataCell(paramName, 2, Colors.brown));

    return result;
  }

  //-------------------------
  DataCell _buildRadioButtonDataCell(
      String paramName, int rbValue, Color color) {
    int value = _updateTrainer.getPrefValue(paramName: paramName);
    return DataCell(RadioButtonWidget.forPreference(
      key: UniqueKey(),
      rbValue: rbValue,
      color: color,
      paramName: paramName,
      value: value,
      isEditable: true,
    ));
  }

  ///------------------------------------------------
  Widget? _getFab() {
    if (_isDirty()) {
      return FloatingActionButton(
        onPressed: _onSaveTrainer,
        hoverColor: Colors.greenAccent,
        child: const Icon(Icons.save),
      );
    } else {
      return null;
    }
  }

  ///------------------------------------------------
  bool _isDirty() {
    return _trainer != _updateTrainer;
  }

  ///------------------------------------------------
  void _onSaveTrainer() async {
    if (_isValid()) {
      bool okay = await AppController.instance.updateTrainer(_updateTrainer);
      String msg = okay
          ? 'Met succes voorkeuren aangepast'
          : 'Fout tijdens aanpassen voorkeuren';
      wh.showSnackbar(msg, color: Colors.lightGreen);
    } else {}
  }

  ///------------------------------------------------
  bool _isValid() {
    if (!_textEmailCtrl.text.isNotEmpty && _isValidEmail(_textEmailCtrl.text)) {
      wh.showSnackbar('Ongeldige email', color: Colors.red);
    }
    if (_textAccessCodeCtrl.text.length != 4) {
      wh.showSnackbar('Toegangscode moet 4 letter zijn', color: Colors.red);
    }
    lp(AppData.instance.getAllTrainers().toString());
    Trainer? trainer = AppData.instance.getAllTrainers().firstWhereOrNull((e) =>
        e.originalAccessCode == _textAccessCodeCtrl.text ||
        e.accessCode == _textAccessCodeCtrl.text);
    if (trainer != null && trainer.pk != AppData.instance.getTrainer().pk) {
      wh.showSnackbar('Deze accesscode bestaat al', color: Colors.red);
    }

    return true;
  }

  ///------------------------------------------------
  bool _isValidEmail(String address) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(address);
  }

  ///------------------------------------------------
  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _trainer = AppData.instance.getTrainer();
        _updateTrainer = _trainer.copyWith();
        _textEmailCtrl.text = _trainer.email;
        _textAccessCodeCtrl.text = _trainer.accessCode;
        _fab = _getFab();
        _columnWidgets = _buildColumnWidgets();
      });
    }
  }

  ///------------------------------------------------
  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _columnWidgets = _buildColumnWidgets();
      });
    }
  }

  ///------------------------------------------------
  void _onTrainerUpdated(TrainerUpdatedEvent event) {
    if (mounted) {
      setState(() {
        _trainer = AppData.instance.getTrainer();
        _updateTrainer = event.trainer.copyWith();
        _columnWidgets = _buildColumnWidgets();
        _fab = _getFab();
      });
    }
  }

  ///------------------------------------------------
  void _onTrainerPrefUpdated(TrainerPrefUpdatedEvent event) {
    if (mounted) {
      setState(() {
        _updateTrainer.setPrefValue(event.paramName, event.newValue);
        _columnWidgets = _buildColumnWidgets();
        _fab = _getFab();
      });
    }
  }
}

import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/data/populate_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:rooster/widget/radiobutton_widget.dart';

class TrainerPrefsPage extends StatefulWidget {
  const TrainerPrefsPage({super.key});

  @override
  State<TrainerPrefsPage> createState() => _TrainerPrefsPageState();
}

class _TrainerPrefsPageState extends State<TrainerPrefsPage> with AppMixin {
  Trainer _trainer = Trainer.empty();
  Trainer _updateTrainer = Trainer.empty();
  final _textCtrl = TextEditingController();
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
    list.add(_buildGrid1());
    list.add(const Padding(
      padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
      child: Text('Voorkeur groepen'),
    ));
    list.add(_buildGrid2());
    return list;
  }

  List<Widget> _readOnlyValues() {
    List<Widget> list = [];
    list.add(_readOnlyRow('PK', 'pk'));
    list.add(_readOnlyRow('Naam', 'fullname'));
    list.add(_readOnlyRow('Rollen', 'roles'));
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
              controller: _textCtrl,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (_textCtrl.text != value.toLowerCase()) {
                  _textCtrl.value =
                      _textCtrl.value.copyWith(text: value.toLowerCase());
                }
                _updateTrainer.email = _textCtrl.text;
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
  Widget _buildGrid1() {
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
            rows: _buildDataRows1(),
          ),
        ),
      ),
    );
  }

  ///------------------------------------------------
  Widget _buildGrid2() {
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
            rows: _buildDataRows2(),
          ),
        ),
      ),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    return wh.buildYesNoIfNeededHeader();
  }

  List<DataRow> _buildDataRows1() {
    List<DataRow> result = [];

    var days = AppData.instance.trainingDays;

    for (String dag in days) {
      if (dag != AppData.instance.trainingDays[2] ||
          AppData.instance.isZamoTrainer(_trainer.pk)) {
        result.add(DataRow(cells: _buildDataCells(dag)));
      }
    }

    return result;
  }

  List<DataRow> _buildDataRows2() {
    List<DataRow> result = [];

    for (String groupName
        in AppData.instance.activeTrainingGroups[0].groupNames) {
      if (groupName.toLowerCase() !=
              Groep.zamo.name || //todo hoe maken we dit dynamisch
          AppData.instance.isZamoTrainer(_trainer.pk)) {
        result.add(DataRow(cells: _buildDataCells(groupName)));
      }
    }

    return result;
  }

  List<DataCell> _buildDataCells(String paramName) {
    List<DataCell> result = [];

    result.add(DataCell(Text(paramName)));
    result.add(_buildRadioButtonDataCell(paramName, 1, Colors.green));
    result.add(_buildRadioButtonDataCell(paramName, 0, Colors.red));
    result.add(_buildRadioButtonDataCell(paramName, 2, Colors.brown));

    return result;
  }

  DataCell _buildRadioButtonDataCell(
      String paramName, int rbValue, Color color) {
    int value = _updateTrainer.getPrefValue(paramName: paramName);
    return DataCell(RadioButtonWidget.forPreference(
        key: UniqueKey(),
        rbValue: rbValue,
        color: color,
        paramName: paramName,
        value: value));
  }

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

  bool _isDirty() {
    return _trainer != _updateTrainer;
  }

  void _onSaveTrainer() async {
    bool okay = await AppController.instance.updateTrainer(_updateTrainer);
    String msg = okay
        ? 'Met succes voorkeuren aangepast'
        : 'Fout tijdens aanpassen voorkeuren';
    wh.showSnackbar(msg, color: Colors.lightGreen);
    setState(() {
      _trainer = _trainer.copyWith();
      _fab = _getFab();
    });
  }

  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _trainer = AppData.instance.getTrainer();
        _updateTrainer = _trainer.copyWith();
        _textCtrl.text = _trainer.email;
        _textCtrl.text = _trainer.email;
        _fab = _getFab();
        _columnWidgets = _buildColumnWidgets();
      });
    }
  }

  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _columnWidgets = _buildColumnWidgets();
      });
    }
  }

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

import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class TrainerSettingsPage extends StatefulWidget {
  const TrainerSettingsPage({super.key});

  @override
  State<TrainerSettingsPage> createState() => _TrainerSettingsPageState();
}

class _TrainerSettingsPageState extends State<TrainerSettingsPage>
    with AppMixin {
  Trainer _trainer = Trainer.empty();
  Trainer _updateTrainer = Trainer.empty();
  List<Widget> _columnWidgets = [];
  final _textCtrl = TextEditingController();
  Widget? _fab;

  _TrainerSettingsPageState() {
    AppEvents.onTrainerDataReadyEvent(_onReady);
    AppEvents.onTrainerUpdatedEvent(_onTrainerUpdated);
  }

  @override
  void initState() {
    _trainer = AppData.instance.getTrainer();
    _updateTrainer = _trainer.copyWith();
    _columnWidgets = _buildColumnWidgets();
    _fab = _getFab();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: AppData.instance.screenHeight - 200,
            child: Column(
              children: _columnWidgets,
            ),
          ),
        ],
      ),
      floatingActionButton: _fab,
    );
  }

  List<Widget> _buildColumnWidgets() {
    List<Widget> list = [];

    list.addAll(_readOnlyValues());
    list.addAll(_voorkeurDagen());
    list.add(wh.verSpace(10));
    list.addAll(_voorkeurGroep());
    return list;
  }

  List<Widget> _readOnlyValues() {
    List<Widget> list = [];
    list.add(_readOnlyRow('PK', 'pk'));
    list.add(_readOnlyRow('Naam', 'fullname'));
    list.add(_readOnlyRow('Rollen', 'roles'));
    list.add(_emailRow());
    list.add(Padding(
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 1),
      child: Container(
        height: 1,
        color: Colors.grey,
      ),
    ));
    list.add(const Padding(
      padding: EdgeInsets.fromLTRB(20, 1, 20, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Voorkeurinstellingen : '),
        ],
      ),
    ));
    list.add(wh.verSpace(10));
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
          SizedBox(
              width: c.w25 * 2,
              child: Text(
                _getStringValue(mapElem),
                overflow: TextOverflow.ellipsis,
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'email',
              ),
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

  List<Widget> _voorkeurDagen() {
    List<Widget> list = [];
    list.add(_voorkeurTopRow('Dag')!);
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'dinsdag',
    ));
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'donderdag',
    ));
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'zaterdag',
    ));
    return list;
  }

  List<Widget> _voorkeurGroep() {
    List<Widget> list = [];
    list.add(_voorkeurTopRow('Groep')!);
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'pr',
    ));
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'r1',
    ));
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'r2',
    ));
    list.add(VoorkeurWidget(
      key: UniqueKey(),
      trainer: _updateTrainer,
      mapName: 'r3',
    ));
    return list;
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
      _trainer = _updateTrainer;
    });
  }

  Widget? _voorkeurTopRow(String label) {
    return Row(
      children: [
        _topRowBox(c.w2, 'Dag', Colors.blue),
        _topRowBox(c.w15, 'Ja', Colors.green),
        _topRowBox(c.w15, 'Nee', Colors.red),
        _topRowBox(c.w25, 'Als nodig', Colors.lightBlueAccent),
      ],
    );
  }

  Widget _topRowBox(double width, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
      child: Container(
        width: width,
        color: color,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 1, 4, 1),
          child: Text(title),
        ),
      ),
    );
  }

  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _trainer = AppData.instance.getTrainer();
        _updateTrainer = _trainer.copyWith();
        _columnWidgets = _buildColumnWidgets();
        _textCtrl.text = _trainer.email;
        _fab = _getFab();
      });
    }
  }

  void _onTrainerUpdated(TrainerUdatedEvent event) {
    if (mounted) {
      setState(() {
        _trainer = AppData.instance.getTrainer();
        _updateTrainer = event.trainer;
        _columnWidgets = _buildColumnWidgets();
        _fab = _getFab();
      });
    }
  }
}

///----------------

class VoorkeurWidget extends StatefulWidget {
  final String mapName;
  final Trainer trainer;
  const VoorkeurWidget(
      {required Key? key, required this.mapName, required this.trainer})
      : super(key: key);

  @override
  State<VoorkeurWidget> createState() => _VoorkeurWidgetState();
}

//--
class _VoorkeurWidgetState extends State<VoorkeurWidget> with AppMixin {
  int _selectedValue = 0;

  @override
  void initState() {
    _selectedValue = _getVoorkeurValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _dayLabel(),
        _radioButton(1, Colors.green),
        _radioButton(0, Colors.red),
        _radioButton(2, Colors.brown),
      ],
    );
  }

  Widget _dayLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 4, 1),
      child: SizedBox(
        width: c.w2,
        child: Text(
          widget.mapName,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _radioButton(int currentValue, Color color) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SizedBox(
        width: c.w15,
        child: Radio<int>(
          activeColor: color,
          value: currentValue,
          groupValue: _selectedValue,
          onChanged: (val) => onChangeValue(val),
        ),
      ),
    );
  }

  int _getVoorkeurValue() {
    Map<String, dynamic> map = widget.trainer.toMap();
    return map[widget.mapName];
  }

  void onChangeValue(int? value) {
    setState(() {
      _selectedValue = value!;
      Map<String, dynamic> map = widget.trainer.toMap();
      map[widget.mapName] = _selectedValue;
      Trainer updatedTrainer = Trainer.fromMap(map);
      AppEvents.fireTrainerUpdated(updatedTrainer);
    });
  }
}

///----------------



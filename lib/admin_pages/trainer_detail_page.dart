import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/widget/animated_fab.dart';

class TrainerDetailPage extends StatefulWidget {
  final Trainer trainer;
  final bool viewOnly;
  const TrainerDetailPage(
      {super.key, required this.trainer, required this.viewOnly});

  @override
  State<TrainerDetailPage> createState() => _TrainerDetailPageState();
}

enum TextCtrl { fullname, email, accesscode, pk }

class _TrainerDetailPageState extends State<TrainerDetailPage> with AppMixin {
  late Trainer _trainer;
  Trainer _updateTrainer = Trainer.empty();

  final List<TextEditingController> _textCtrls = [];
  List<Widget> _columnWidgets = [];

  @override
  void initState() {
    for (int i = 0; i < TextCtrl.values.length; i++) {
      _textCtrls.add(TextEditingController());
    }
    _columnWidgets = _buildColumnWidgets();
    _trainer = widget.trainer.clone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _columnWidgets,
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  //---------------------------------------------------
  List<Widget> _buildColumnWidgets() {
    List<Widget> list = [];
    list.add(wh.verSpace(20));
    list.add(_title());
    list.add(wh.verSpace(15));
    list.add(_fullnameRow());
    list.add(wh.verSpace(10));
    list.add(_emailRow());
    list.add(wh.verSpace(10));
    list.add(_accesscodeRow());
    list.add(wh.verSpace(10));
    list.add(_pkRow());
    list.add(wh.verSpace(20));
    list.add(_buildCloseButton());
    return list;
  }

//----------------------------------------------------------
  Widget _title() {
    String title = '';
    if (widget.trainer.isEmpty()) {
      title = 'Nieuwe trainer';
    } else {
      title = 'Trainer : ${widget.trainer.fullname}';
    }
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
      ),
    );
  }

//---------------------------------------------------------
  Widget _fullnameRow() {
    return _textFieldRow(TextCtrl.fullname, 'Naam (volledig)', 'volledige naam',
        c.w25, _onNameChanged, TextCapitalization.sentences);
  }

  void _onNameChanged(String value) {
    TextEditingController ctrl = _textCtrls[TextCtrl.fullname.index];
    List<String> tokens = ctrl.text.split(' ');
    if (tokens.length > 1) {
      String pk = tokens[0].substring(0, 1).toUpperCase();
      pk += tokens[tokens.length - 1].substring(0, 1).toUpperCase();
      _updateTrainer = _updateTrainer.copyWith(pk: pk);
      _textCtrls[TextCtrl.pk.index].text = pk;
    }
    setState(() {
      _updateTrainer = _updateTrainer.copyWith(fullname: ctrl.text);
    });
  }

  //---------------------------------------------------------
  Widget _accesscodeRow() {
    return _textFieldRow(TextCtrl.accesscode, 'Toegangscode', '4 letters', c.w1,
        _onAccessCodeChanged, TextCapitalization.characters);
  }

  void _onAccessCodeChanged(String value) {
    TextEditingController ctrl = _textCtrls[TextCtrl.accesscode.index];
    if (ctrl.text != value.toUpperCase()) {
      if (value.length > 4) {
        value = value.substring(0, 4);
      }
      ctrl.value = ctrl.value.copyWith(text: value.toUpperCase());
    }

    setState(() {
      _updateTrainer.accessCode = ctrl.text;
    });
  }

  //---------------------------------------------------------
  Widget _pkRow() {
    return _textFieldRow(TextCtrl.pk, 'PK', '', c.w1, _onPkChanged,
        TextCapitalization.characters);
  }

  void _onPkChanged(String value) {
    TextEditingController ctrl = _textCtrls[TextCtrl.pk.index];
    setState(() {
      _updateTrainer = _updateTrainer.copyWith(pk: ctrl.text);
    });
  }

  //----------------------------------
  Widget _emailRow() {
    return _textFieldRow(TextCtrl.email, 'Email', 'email adres', c.w25,
        _onEmailChanged, TextCapitalization.none);
  }

  void _onEmailChanged(String value) {
    TextEditingController ctrl = _textCtrls[TextCtrl.email.index];
    setState(() {
      _updateTrainer = _updateTrainer.copyWith(email: ctrl.text);
    });
  }

  //----------------------------------------------------------
  Widget _textFieldRow(
      TextCtrl textCtrl,
      String label,
      String hint,
      double textWidth,
      Function(String) onChanged,
      TextCapitalization textCap) {
    TextEditingController ctrl = _textCtrls[textCtrl.index];
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
            width: textWidth,
            child: TextField(
              enabled: !widget.viewOnly,
              controller: ctrl,
              decoration: InputDecoration(
                  isDense: true,
                  hintText: hint,
                  contentPadding: const EdgeInsets.all(2)),
              textCapitalization: textCap,
              onChanged: (value) => onChanged(value),
            ),
          ),
        ],
      ),
    );
  }

  ///------------------------------------------------
  Widget? _buildFab() {
    if (_isDirty() && _isValid()) {
      return FloatingActionButton(
        onPressed: _onSaveTrainer,
        hoverColor: Colors.greenAccent,
        child: const AnimatedFab(),
      );
    } else {
      return null;
    }
  }

  ///------------------------------------------------
  bool _isDirty() {
    return _trainer != _updateTrainer;
  }

  ///--------------------------------------------------
  bool _isValid() {
    TextEditingController ctrl1 = _textCtrls[TextCtrl.email.index];
    if (ctrl1.text.isEmpty || !_isValidEmail(ctrl1.text)) {
      return false;
    }

    TextEditingController ctrl2 = _textCtrls[TextCtrl.accesscode.index];
    if (ctrl2.text.length != 4) {
      return false;
    }

    Trainer? trainer = AppData.instance.getAllTrainers().firstWhereOrNull((e) =>
        e.originalAccessCode == ctrl2.text || e.accessCode == ctrl2.text);
    if (trainer != null && trainer.pk != AppData.instance.getTrainer().pk) {
      wh.showSnackbar('Deze accesscode bestaat al', color: Colors.red);
      return false;
    }

    return true;
  }

  ///------------------------------------------------
  void _onSaveTrainer() async {
    if (_isValid()) {
      bool okay = await AppController.instance.updateTrainer(_updateTrainer);
      String msg =
          okay ? 'Met succes trainer opgeslagen' : 'Fout opslaan van trainer';
      wh.showSnackbar(msg, color: Colors.lightGreen);
    } else {}
  }

  ///------------------------------------------------
  bool _isValidEmail(String address) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(address);
  }

  //-------------------------------------------------
  Widget _buildCloseButton() {
    return ElevatedButton(onPressed: _closeDialog, child: const Text('Sluit'));
  }

  void _closeDialog() {
    Navigator.pop(
      context,
    );
  }
}

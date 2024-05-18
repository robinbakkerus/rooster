import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/widget/animated_fab.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class TrainerDetailPage extends StatefulWidget {
  final Trainer trainer;
  final bool viewOnly;
  const TrainerDetailPage(
      {super.key, required this.trainer, required this.viewOnly});

  @override
  State<TrainerDetailPage> createState() => _TrainerDetailPageState();
}

enum TextCtrl { fullname, email, accesscode, pk, roles }

class _TrainerDetailPageState extends State<TrainerDetailPage> with AppMixin {
  late Trainer _trainer;
  late Trainer _updateTrainer;
  bool _newTrainer = false;

  final List<TextEditingController> _textCtrls = [];
  List<Widget> _columnWidgets = [];

  @override
  void initState() {
    for (int i = 0; i < TextCtrl.values.length; i++) {
      _textCtrls.add(TextEditingController());
    }
    _columnWidgets = _buildColumnWidgets();
    _trainer = widget.trainer.clone();
    _updateTrainer = _trainer.clone();
    _newTrainer = _trainer.isEmpty();
    if (_newTrainer) {
      _setupNewTrainer();
    }
    _fillTextControls();
    super.initState();
  }

  //------------------------------------------------------------
  void _fillTextControls() {
    _textCtrls[TextCtrl.fullname.index].text = _updateTrainer.fullname;
    _textCtrls[TextCtrl.email.index].text = _updateTrainer.email;
    _textCtrls[TextCtrl.pk.index].text = _updateTrainer.pk;
    _textCtrls[TextCtrl.accesscode.index].text = _updateTrainer.accessCode;
    _textCtrls[TextCtrl.roles.index].text = _updateTrainer.roles;
  }

  //------------------------------------------------------------
  void _setupNewTrainer() {
    _updateTrainer = _updateTrainer.copyWith(roles: 'T');
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
    list.add(_rolesRow());
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
    String fullname = toBeginningOfSentenceCase(ctrl.text);
    ctrl.value = ctrl.value.copyWith(text: fullname);
    if (_newTrainer) {
      _updateTrainerPk(fullname);
    }
    setState(() {
      _updateTrainer = _updateTrainer.copyWith(fullname: fullname);
    });
  }

  //------------------------------------------------------------
  void _updateTrainerPk(String fullname) {
    String pk = '';
    List<String> tokens = fullname.split(' ');
    if (tokens.length > 1 && !fullname.endsWith(' ')) {
      for (int i = 0; i < tokens.length; i++) {
        pk += tokens[i].substring(0, 1);
      }
    }
    _updateTrainer = _updateTrainer.copyWith(pk: pk);
    _textCtrls[TextCtrl.pk.index].text = pk;
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

//---------------------------------------------------------
  Widget _rolesRow() {
    return _textFieldRow(TextCtrl.roles, 'Rollen', '', c.w1, _onRolesChanged,
        TextCapitalization.characters);
  }

  void _onRolesChanged(String value) {
    TextEditingController ctrl = _textCtrls[TextCtrl.roles.index];
    setState(() {
      _updateTrainer = _updateTrainer.copyWith(pk: ctrl.text);
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
    if (_updateTrainer.fullname.length < 3) {
      return false;
    } else if (_updateTrainer.email.isEmpty ||
        !_isValidEmail(_updateTrainer.email)) {
      return false;
    } else if (_updateTrainer.accessCode.length != 4) {
      return false;
    } else {
      Trainer? trainer = AppData.instance.getAllTrainers().firstWhereOrNull(
          (e) =>
              e.originalAccessCode == _updateTrainer.accessCode ||
              e.accessCode == _updateTrainer.accessCode);
      if (trainer != null && trainer.pk != _updateTrainer.pk) {
        return false;
      }
    }

    return true;
  }

  ///------------------------------------------------
  void _onSaveTrainer() async {
    if (_isValid()) {
      bool okay = await AppController.instance
          .updateTrainerBySupervisor(_updateTrainer);
      String msg =
          okay ? 'Met succes trainer opgeslagen' : 'Fout opslaan van trainer';
      wh.showSnackbar(msg, color: Colors.lightGreen);

      setState(() {
        _trainer = _updateTrainer.clone();
      });
    }
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

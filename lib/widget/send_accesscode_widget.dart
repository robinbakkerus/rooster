// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_mixin.dart';

class SendAccessCodeWidget extends StatefulWidget {
  const SendAccessCodeWidget({super.key});

  @override
  State<SendAccessCodeWidget> createState() => _SendAccessCodeWidgetState();
}

class _SendAccessCodeWidgetState extends State<SendAccessCodeWidget>
    with AppMixin {
  final _textCtrl2 = TextEditingController();
  String _foundTrainerByFirstname = ''; //used in alertdialog
  List<Trainer> _allTrainers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vul je voornaam in ...'),
        wh.verSpace(5),
        TextField(
          controller: _textCtrl2,
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            _onFirstnameChanged(value);
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Voornaam',
            isDense: true, // Added this
          ),
        ),
        Text(_foundTrainerByFirstname),
      ],
    );
  }

  void _onFirstnameChanged(String value) async {
    if (_allTrainers.isEmpty) {
      _allTrainers = await Dbs.instance.getAllTrainers();
    }

    if (value.isNotEmpty) {
      String camelcase = value.substring(0, 1).toUpperCase();
      if (value.length > 1) {
        camelcase += value.substring(1).toLowerCase();
      }
      if (_textCtrl2.text != value.toUpperCase()) {
        _textCtrl2.value = _textCtrl2.value.copyWith(text: camelcase);
      }
    }

    if (value.length > 2) {
      Trainer? trainer = _allTrainers.firstWhereOrNull(
          (e) => e.firstName().toLowerCase() == value.toLowerCase());
      if (trainer != null) {
        setState(() {
          _foundTrainerByFirstname =
              'gevonden, email is verstuurd!\nja kan het scherm sluiten.';
        });
        Dbs.instance.sendEmail(
            toList: [trainer],
            ccList: [],
            subject: 'AccessCode',
            html: _buildMailHtml(trainer));
      } else {
        setState(() {
          _foundTrainerByFirstname = 'onbekende voornaam ...';
        });
      }
    }
  }

  String _buildMailHtml(Trainer trainer) {
    String result = '<div>';
    result += 'Hallo ${trainer.firstName()} <br><br>';
    result += 'Je accesscode = ${trainer.accessCode} <br>';
    result += 'success!';
    result += '</div>';
    return result;
  }
}

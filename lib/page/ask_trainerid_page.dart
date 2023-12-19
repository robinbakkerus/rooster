import 'dart:developer';

import 'package:firestore/controller/app_controler.dart';
import 'package:firestore/data/populate_data.dart' as populate;
import 'package:firestore/data/trainer_data.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/util/data_parser.dart';
import 'package:flutter/material.dart';

class AskTrainerIdPage extends StatefulWidget {
  const AskTrainerIdPage({super.key});

  @override
  State<AskTrainerIdPage> createState() => _AskTrainerIdPageState();
}

class _AskTrainerIdPageState extends State<AskTrainerIdPage> {
  final _textCtrl = TextEditingController();
  bool _submitDisabled = true;
  Color _submitBtnColor = Colors.grey;

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    _textCtrl.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('xx'),
          ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vul je accesscode in'),
              Container(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _textCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'accesscode',
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _submitBtnColor,
                    ),
                    onPressed: _submitDisabled ? null : _onSubmit,
                    child: const Text("submit"),
                  ),
                ],
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                onPressed: _onTest,
                child: const Text("test"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _printLatestValue() {
    final text = _textCtrl.text;
    if (text.length > 6) {
      setState(() {
        _submitDisabled = false;
        _submitBtnColor = Colors.blue;
      });
    }
  }

  void _onSubmit() {
    TrainerData.instance.trainerId = _textCtrl.text;
    AppController.instance.getTrainerData(_textCtrl.text);
  }

  //--------------- dummy test
  void _onTest() {
    TrainerData.instance.trainer = populate.trainerRobin;
    List<DaySchema> dsList =
        DateParser.buildFromTrainerSchemas(populate.trainerSchemas1);
    for (DaySchema ds in dsList) {
      log(ds.toJson());
    }
  }
}

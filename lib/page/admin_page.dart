import 'dart:developer';
import 'dart:html';

import 'package:firestore/controller/app_controler.dart';
import 'package:firestore/data/app_data.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/repo/firestore_helper.dart';
import 'package:firestore/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';
import 'package:firestore/data/populate_data.dart' as p;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          OutlinedButton(
              onPressed: _addTrainers, child: const Text('Add trainers')),
          OutlinedButton(
              onPressed: _removeCookie, child: const Text('Remove cookie')),
          OutlinedButton(
              onPressed: _generateRoster, child: const Text('Maak rooster'))
        ],
      ),
    );
  }

  void _addTrainers() {
    List<Trainer> trainers = [
      p.trainerRobin,
      p.trainerFried,
      p.trainerHuib,
      p.trainerJanneke,
      p.trainerJeroen,
      p.trainerMaria,
      p.trainerOlav,
      p.trainerPauline,
      p.trainerRonald
    ];

    for (Trainer trainer in trainers) {
      FirestoreHelper.instance.createOrUpdateTrainer(trainer);
    }
  }

  void _removeCookie() {
    document.cookie = "ac=";
  }

  void _generateRoster() async {
    await FirestoreHelper.instance.findTrainerByAccessCode('ROME');
    await AppController.instance.getAllTrainerData();

    List<Available> availableList = [];
    SpreadSheet spreadSheet = SpreadSheet();
    availableList =
        SpreadsheetGenerator.instance.generateAvailableTrainersCounts();
    spreadSheet = SpreadsheetGenerator.instance
        .generateSpreadsheet(availableList, AppData.instance.getActiveDate());

    List<String> csvList =
        SpreadsheetGenerator.instance.generateCsv(spreadSheet);
    for (String s in csvList) {
      log(s);
    }

    String html = SpreadsheetGenerator.instance.generateHtml(spreadSheet);
    log(html);
  }
}
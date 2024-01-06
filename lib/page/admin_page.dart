import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:universal_html/html.dart' as html;
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/firestore_helper.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';
import 'package:rooster/data/populate_data.dart' as p;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with AppMixin {
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
              onPressed: _generateRoster, child: const Text('Maak rooster')),
          OutlinedButton(
              onPressed: _saveFsSpreadsheet,
              child: const Text('Firestore spreadsheet')),
          OutlinedButton(
              onPressed: _deleteOldLogs, child: const Text('Delete old logs'))
        ],
      ),
    );
  }

  void _addTrainers() {
    List<Trainer> trainers = [
      // p.trainerAnne,
      // p.trainerPaula,
      // p.trainerRobin,
      // p.trainerFried,
      // p.trainerHuib,
      // p.trainerJanneke,
      // p.trainerJeroen,
      // p.trainerMaria,
      // p.trainerOlav,
      // p.trainerPauline,
      // p.trainerRonald,
      p.trainerCyriel
    ];

    for (Trainer trainer in trainers) {
      FirestoreHelper.instance.createOrUpdateTrainer(trainer);
    }
  }

  void _removeCookie() {
    html.document.cookie = "ac=";
  }

  void _generateRoster() async {
    await FirestoreHelper.instance.findTrainerByAccessCode('ROME');
    await AppController.instance.generateSpreadsheet();

    List<Available> availableList =
        SpreadsheetGenerator.instance.generateAvailableTrainersCounts();
    SpreadSheet spreadSheet = SpreadsheetGenerator.instance
        .generateSpreadsheet(availableList, AppData.instance.getActiveDate());
    lp(spreadSheet.toString());
  }

  void _saveFsSpreadsheet() async {
    // List<Available> availableList =
    //     SpreadsheetGenerator.instance.generateAvailableTrainersCounts();
    // SpreadSheet spreadSheet = SpreadsheetGenerator.instance
    //     .generateSpreadsheet(availableList, AppData.instance.getActiveDate());
    // spreadSheet.year = 2024;
    // spreadSheet.month = 1;
    // FsSpreadsheet fsSpreadsheet =
    //     SpreadsheetGenerator.instance.fsSpreadsheetFrom(spreadSheet);

    FsSpreadsheet fsSpreadsheet = FsSpreadsheet(
        year: 2024, month: 1, rows: _januariRows(), isFinal: true);
    await FirestoreHelper.instance.saveFsSpreadsheet(fsSpreadsheet);
  }

  void _deleteOldLogs() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference logRef = firestore.collection('logs');
    await logRef.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  List<FsSpreadsheetRow> _januariRows() {
    List<FsSpreadsheetRow> rows = [];
    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 2),
        trainingText: 'Kerstvakantie training',
        isExtraRow: false,
        rowCells: ['Olav', 'Robin', 'Fried', 'Paula', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 4),
        trainingText: 'Kerstvakantie training',
        isExtraRow: false,
        rowCells: ['(met R1)', 'Ronald', '(met R3)', 'Anne', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 6),
        trainingText: 'ZAMO',
        isExtraRow: false,
        rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 9),
        trainingText: 'korte training + NY borrel',
        isExtraRow: false,
        rowCells: ['Olav', 'Jeroen', 'Maria', 'Anne', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 11),
        trainingText: 'Tempo duurloop D2',
        isExtraRow: false,
        rowCells: ['(met R1)', 'Ronald', 'Fried', 'Pauline', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 13),
        trainingText: 'ZAMO',
        isExtraRow: false,
        rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 16),
        trainingText: 'Fartlek',
        isExtraRow: false,
        rowCells: ['Janneke', 'Robin', 'Ronald', 'Huib', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 18),
        trainingText: 'Duurloop D1',
        isExtraRow: false,
        rowCells: ['(met R1)', 'Jeroen', 'Cyriel', 'Fried', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 20),
        trainingText: 'ZAMO',
        isExtraRow: false,
        rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 23),
        trainingText: 'Herstelduurloop',
        isExtraRow: false,
        rowCells: ['Olav', 'Janneke', 'Maria', 'Huib', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 25),
        trainingText: 'Climaxduurloop D1/D2',
        isExtraRow: false,
        rowCells: ['(met R1)', 'Jeroen', 'Cyriel', 'Pauline', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 27),
        trainingText: 'ZAMO',
        isExtraRow: false,
        rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 30),
        trainingText: 'Interval korte afstand',
        isExtraRow: false,
        rowCells: ['Janneke', 'Robin', 'Maria', 'Paula', '']));

    rows.add(FsSpreadsheetRow(
        date: DateTime(2024, 1, 21),
        trainingText: 'Houffalize ultra trail	',
        isExtraRow: true,
        rowCells: []));

    return rows;
  }
}

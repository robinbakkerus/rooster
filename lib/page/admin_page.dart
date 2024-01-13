import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rooster/data/populate_data.dart' as p;
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/firestore_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:universal_html/html.dart' as html;

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
              onPressed: _addTrainerSchemas,
              child: const Text('add trainer schemas')),
          OutlinedButton(
              onPressed: _saveFsSpreadsheet,
              child: const Text('Firestore spreadsheet')),
          OutlinedButton(
              onPressed: _deleteOldLogs, child: const Text('Delete old logs')),
          OutlinedButton(
              onPressed: _addApplyWeightValues,
              child: const Text('Add ApplyWeightValue(s)')),
          OutlinedButton(
              onPressed: _addTrainingItems,
              child: const Text('Add training items')),
          OutlinedButton(onPressed: _sendEmail, child: const Text('Send email'))
        ],
      ),
    );
  }

  void _addTrainers() {
    List<Trainer> trainers = [
      p.trainerAnne,
      p.trainerPaula,
      p.trainerRobin,
      p.trainerFried,
      p.trainerHuib,
      p.trainerJanneke,
      p.trainerJeroen,
      p.trainerMaria,
      p.trainerOlav,
      p.trainerPauline,
      p.trainerRonald,
      p.trainerCyriel,
    ];

    for (Trainer trainer in trainers) {
      FirestoreHelper.instance.createOrUpdateTrainer(trainer);
    }
  }

  void _removeCookie() {
    html.document.cookie = "ac=";
  }

  void _addTrainerSchemas() async {
    List<TrainerSchema> schemas = [
      p.trainerSchemasAnne,
      p.trainerSchemasCyriel,
      p.trainerSchemasFried,
      p.trainerSchemasHuib,
      p.trainerSchemasJanneke,
      p.trainerSchemasMaria,
      p.trainerSchemasMaria,
      p.trainerSchemasOlav,
      p.trainerSchemasPaula,
      p.trainerSchemasPauline,
      p.trainerSchemasRonald,
      p.trainerSchemasJeroen,
    ];

    for (TrainerSchema ts in schemas) {
      FirestoreHelper.instance
          .createOrUpdateTrainerSchemas(ts, updateSchema: false);
    }
  }

  void _saveFsSpreadsheet() async {
    FsSpreadsheet fsSpreadsheet = p.spreadSheetFebruari();
    await FirestoreHelper.instance.saveFsSpreadsheet(fsSpreadsheet);
  }

  void _deleteOldLogs() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference logRef = firestore.collection('logs');
    bool firstOne =
        true; // dont remove all logs becauce then de whole table is gone
    await logRef.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (!firstOne) {
          doc.reference.delete();
        }
        firstOne = false;
      }
    });
  }

  void _addApplyWeightValues() async {
    ApplyWeightValues weightValues = p.getApplyWeightValues();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference ref = firestore.collection('metadata');
    await ref.doc('apply_weights').set(weightValues.toMap()).then((val) {
      lp('weights added ');
    }).onError((error, stackTrace) => lp(error.toString()));
  }

  void _addTrainingItems() async {
    List<String> items = p.getTrainerItems();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference ref = firestore.collection('metadata');
    var map = {'items': items};
    await ref.doc('training_items').set(map).then((val) {
      lp('training items added ');
    }).onError((error, stackTrace) => lp(error.toString()));
  }

  void _sendEmail() async {
    List<Trainer> toTrainers = [p.trainerRobin];
    String html = '<p>Test</p>';
    FirestoreHelper.instance
        .sendEmail(toTrainers: toTrainers, subject: 'subject', html: html);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rooster/data/populate_data.dart' as p;
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/authentication.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_helper.dart';
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
          OutlinedButton(
              onPressed: _sendEmail, child: const Text('Send email')),
          OutlinedButton(onPressed: _testRule, child: const Text('Test rule')),
          OutlinedButton(
              onPressed: _signUpOrSignIn, child: const Text('SignUp')),
          OutlinedButton(
              onPressed: _addTrainingGroups,
              child: const Text('Add Training groups')),
        ],
      ),
    );
  }

  void _addTrainers() {
    List<Trainer> trainers = _allTrainers();

    for (Trainer trainer in trainers) {
      Dbs.instance.createOrUpdateTrainer(trainer);
    }
  }

  List<Trainer> _allTrainers() {
    List<Trainer> trainers = [
      p.trainerAnne,
      p.trainerPaula,
      // p.trainerRobin,
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
    return trainers;
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
      p.trainerSchemasRobin,
    ];

    for (TrainerSchema ts in schemas) {
      Dbs.instance.createOrUpdateTrainerSchemas(ts, updateSchema: false);
    }
  }

  void _saveFsSpreadsheet() async {
    FsSpreadsheet fsSpreadsheet = p.allFsSpreadsheets[1]; //februari
    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
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
    PlanRankValues weightValues = p.getPlanRankValues();
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
    Dbs.instance.sendEmail(
        toList: toTrainers, ccList: [], subject: 'subject', html: html);
  }

  void _testRule() async {
    List<Trainer> toTrainers = [p.trainerRobin];
    String html = '<p>Test</p>';
    Dbs.instance.sendEmail(
        toList: toTrainers, ccList: [], subject: 'subject', html: html);
  }

  void _signUpOrSignIn() async {
    for (Trainer trainer in _allTrainers()) {
      AuthHelper.instance.signUp(
          email: trainer.email,
          password: AppHelper.instance.getAuthPassword(trainer));
    }
  }

  void _addTrainingGroups() async {
    List<TrainingGroup> groups = p.allTrainingGroups();
    Dbs.instance.saveTrainingGroups(groups);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rooster/data/populate_data.dart' as p;
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/authentication.dart';
import 'package:rooster/repo/firestore_helper.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wh.adminPageAppBar(context, 'Admin page'),
      body: Center(
        child: Column(
          children: [
            OutlinedButton(
                onPressed: _addTrainers, child: const Text('Add trainers')),
            OutlinedButton(
                onPressed: _removeAccessCodePref,
                child: const Text('Remove access code pref')),
            OutlinedButton(
                onPressed: _addTrainerSchemas,
                child: const Text('add trainer schemas')),
            OutlinedButton(
                onPressed: _saveFsSpreadsheet,
                child: const Text('Save spreadsheet')),
            OutlinedButton(
                onPressed: _deleteOldLogs,
                child: const Text('Delete old logs')),
            OutlinedButton(
                onPressed: _deleteOldErrors,
                child: const Text('Delete old errors')),
            OutlinedButton(
                onPressed: _addMetaData, child: const Text('Add MetaData')),
            OutlinedButton(
                onPressed: _sendEmail, child: const Text('Send email')),
            OutlinedButton(
                onPressed: _sendAccessCodes,
                child: const Text('Email accesscodes')),
            OutlinedButton(
                onPressed: _signUpOrSignIn, child: const Text('SignUp')),
          ],
        ),
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
    return trainers;
  }

  void _removeAccessCodePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ac', '');
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
    FsSpreadsheet fsSpreadsheet = p.allFsSpreadsheets[0]; //januari
    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
    fsSpreadsheet = p.allFsSpreadsheets[1]; //februari
    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
  }

  void _deleteOldLogs() async {
    CollectionReference logRef =
        FirestoreHelper.instance.collectionRef(FsCol.logs);
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

  void _deleteOldErrors() async {
    CollectionReference logRef =
        FirestoreHelper.instance.collectionRef(FsCol.error);
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

  void _sendEmail() async {
    List<Trainer> toTrainers = [p.trainerRobin];
    String html = '<p>Test</p>';
    Dbs.instance.sendEmail(
        toList: toTrainers, ccList: [], subject: 'subject', html: html);
  }

  void _sendAccessCodes() async {
    // for (Trainer trainer in _allTrainers()) {
    for (Trainer trainer in p.allTrainers) {
      String html = _accessCodeHtml(trainer);
      Dbs.instance.sendEmail(
          toList: [trainer], ccList: [], subject: 'Toegangscode', html: html);
    }
  }

  void _signUpOrSignIn() async {
    for (Trainer trainer in _allTrainers()) {
      AuthHelper.instance.signUp(
          email: trainer.email,
          password: AppHelper.instance.getAuthPassword(trainer));
    }
  }

  void _addMetaData() async {
    await _addPlanRankValues();
    await _addTrainingItems();
    await _addSpecialDays();
    await _addTrainingGroups();
  }

  Future<void> _addPlanRankValues() async {
    MetaPlanRankValues planRankValues = p.getPlanRankValues();
    await FirestoreHelper.instance.savePlanRankValues(planRankValues);
  }

  Future<void> _addSpecialDays() async {
    await FirestoreHelper.instance.saveSpecialDays(p.specialDays);
  }

  Future<void> _addTrainingItems() async {
    List<String> items = p.getTrainerItems();
    CollectionReference ref =
        FirestoreHelper.instance.collectionRef(FsCol.metadata);
    var map = {'items': items};
    await ref
        .doc('training_items')
        .set(map)
        .then((val) {})
        .onError((error, stackTrace) => lp(error.toString()));
  }

  Future<void> _addTrainingGroups() async {
    List<TrainingGroup> groups = p.allTrainingGroups();
    Dbs.instance.saveTrainingGroups(groups);
  }

  //------------------ private -------------------------

  String _accessCodeHtml(Trainer trainer) {
    String html = '<div>';
    html += 'Hallo ${trainer.firstName()}<br><br>';
    html +=
        'Je kunt vanaf nu verhindering doorgeven via deze url: <b>https://lonutrainingschema.web.app</b> <br>';
    html += 'Je toegangscode is: <b>${trainer.accessCode}</b> <br><br>';
    html += 'Een korte uitleg vind je hier: <br>';
    html +=
        '<b>https://drive.google.com/file/d/1P1VRW5GXnh7jFimqcddL_0VJlvLq3Qrs/view?usp=sharing</b> <br><br>';

    html += 'Gr Robin <br>';
    return '$html</div>';
  }
}

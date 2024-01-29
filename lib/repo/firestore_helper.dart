import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/dbs_simulator.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/data/populate_data.dart' as p;

class FirestoreHelper with AppMixin implements Dbs {
  FirestoreHelper._();
  static final FirestoreHelper instance = FirestoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// find Trainer
  @override
  Future<Trainer> findTrainerByAccessCode(String accessCode) async {
    CollectionReference trainersRef = firestore.collection('trainer');

    Trainer trainer = Trainer.empty();

    await trainersRef
        .where('accessCode', isEqualTo: accessCode)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size > 0) {
        var map = Map<String, dynamic>.from(
            querySnapshot.docs[0].data() as Map<dynamic, dynamic>);
        trainer = Trainer.fromMap(map);
      }
    });

    return trainer;
  }

  ///- get trainer, or null if not exists
  @override
  Future<Trainer?> getTrainerById(String trainerPk) async {
    CollectionReference trainersRef = firestore.collection('trainer');

    Trainer? trainer;

    await trainersRef.doc(trainerPk).get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var map =
            Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
        map['id'] = trainerPk;
        trainer = Trainer.fromMap(map);
      }
    });

    return trainer;
  }

  /// receive all data used for editSchema view
  @override
  Future<TrainerSchema> getTrainerSchema(String trainerSchemaId) async {
    if (AppData.instance.runMode == RunMode.dev) {
      return Simulator.instance.getTrainerSchema(trainerSchemaId);
    } else {
      TrainerSchema schemas = await _getTheTrainerSchema(trainerSchemaId);
      return schemas;
    }
  }

  /// update the available value of the given DaySchema
  @override
  Future<bool> createOrUpdateTrainerSchemas(TrainerSchema trainerSchemas,
      {required bool updateSchema}) async {
    bool result = false;

    if (AppData.instance.runMode != RunMode.dev) {
      CollectionReference schemaRef = firestore.collection('schemas');

      if (updateSchema) {
        trainerSchemas.modified = DateTime.now();
        trainerSchemas.isNew = false;
      } else {
        trainerSchemas.isNew = true;
      }

      await schemaRef.doc(trainerSchemas.id).set(trainerSchemas.toMap()).then(
          (value) {
        result = true;
        _handleSucces(LogAction.modifySchema);
      }, onError: (e) => _updateError("$e"));
    } else {
      result = true;
    }

    return result;
  }

  ///--------------------------------------------

  @override
  Future<List<Trainer>> getAllTrainers() async {
    List<Trainer> result = [];

    if (AppData.instance.runMode != RunMode.dev) {
      CollectionReference trainerRef = firestore.collection('trainer');
      await trainerRef.get().then(
        (querySnapshot) {
          for (var doc in querySnapshot.docs) {
            var map = doc.data() as Map<String, dynamic>;
            map['id'] = doc.id;
            Trainer trainer = Trainer.fromMap(map);
            result.add(trainer);
          }
        },
        onError: (e) => lp("Error completing: $e"),
      ).catchError((e) {
        lp('Error in getAllTrainers : $e');
        throw e;
      });
    } else {
      return Simulator.instance.getAllTrainers();
    }

    return result;
  }

  ///--------------------------
  @override
  Future<Trainer> createOrUpdateTrainer(trainer) async {
    Trainer result = Trainer.empty();

    CollectionReference trainerRef = firestore.collection('trainer');
    await trainerRef.doc(trainer.pk).set(trainer.toMap()).then((val) {
      result = trainer;
      _handleSucces(LogAction.modifySettings);
    }).onError((error, stackTrace) {
      lp('Error in createOrUpdateTrainer $error');
    });

    return result;
  }

  ///--------------------------------------------

  @override
  Future<List<String>> getZamoTrainers() async {
    List<String> result = [];

    if (AppData.instance.runMode != RunMode.dev) {
      CollectionReference zamoRef = firestore.collection('metadata');
      await zamoRef.doc('zamo_trainers').get().then(
        (val) {
          Map<String, dynamic> map = val.data()! as Map<String, dynamic>;
          var list = map['trainers'];
          for (var pk in list) {
            result.add(pk.toString());
          }
        },
        onError: (e) => lp("Error completing getZamoTrainers: $e"),
      ).catchError((e) {
        lp('Error in getZamoTrainers : $e');
        throw e;
      });
    } else {
      return ['HC', 'PG', 'RV'];
    }

    return result;
  }

  ///--------------------------------------------

  @override
  Future<String> getZamoTrainingDefault() async {
    CollectionReference zamoRef = firestore.collection('metadata');
    DocumentSnapshot snapshot = await zamoRef.doc('zamo_default').get();
    Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
    return map['training'];
  }

  ///--------------------------------------------
// get list of items used to populate combobox of training items
  @override
  Future<List<String>> getTrainingItems() async {
    List<String> result = [];

    if (AppData.instance.runMode != RunMode.dev) {
      CollectionReference ref = firestore.collection('metadata');
      await ref.doc('training_items').get().then(
        (val) {
          Map<String, dynamic> map = val.data() as Map<String, dynamic>;
          result = List<String>.from(map['items'] as List);
        },
        onError: (e) => lp("Error getting trainer_items: $e"),
      ).catchError((e) {
        lp('Error in getTrainerItems : $e');
        throw e;
      });
    } else {
      return p.getTrainerItems();
    }

    return result;
  }

  ///--------------------------------------------

  @override
  Future<MetaPlanRankValues> getApplyWeightValues() async {
    MetaPlanRankValues? result;

    if (AppData.instance.runMode != RunMode.dev) {
      CollectionReference ref = firestore.collection('metadata');
      await ref.doc('apply_weights').get().then(
        (val) {
          Map<String, dynamic> map = val.data() as Map<String, dynamic>;
          result = MetaPlanRankValues.fromMap(map);
        },
        onError: (e) => lp("Error getting weight_values: $e"),
      ).catchError((e) {
        lp('Error in getApplyWeightValues : $e');
        throw e;
      });
    } else {
      result = p.getPlanRankValues();
    }

    return result!;
  }

  ///--------------------------
  @override
  Future<LastRosterFinal> saveLastRosterFinal() async {
    LastRosterFinal lrf = LastRosterFinal(
        at: DateTime.now(),
        by: AppData.instance.getTrainer().pk,
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth());

    CollectionReference trainerRef = firestore.collection('metadata');
    await trainerRef.doc('last_published').set(lrf.toMap()).then((val) {
      _handleSucces(LogAction.finalizeSpreadsheet);
    }).catchError((e) {
      lp('Error in saveLastRosterFinal $e');
      throw e;
    });

    return lrf;
  }

  ///--------------------------
  @override
  Future<LastRosterFinal?> getLastRosterFinal() async {
    LastRosterFinal? result;
    CollectionReference trainerRef = firestore.collection('metadata');
    await trainerRef.doc('last_published').get().then((val) {
      result = LastRosterFinal.fromMap(val.data() as Map<String, dynamic>);
    }).catchError((e) {
      lp(' Error in getLastRosterFinal $e');
      throw e;
    });

    return result;
  }

  ///--------------------------
  @override
  Future<void> saveFsSpreadsheet(FsSpreadsheet fsSpreadsheet) async {
    CollectionReference colRef = firestore.collection('spreadsheet');
    await colRef
        .doc(fsSpreadsheet.getID())
        .set(fsSpreadsheet.toMap())
        .then((val) {})
        .catchError((e) {
      lp('Error in saveFsSpreadsheet $e');
      throw e;
    });
  }

  //-----------------------------------------
  @override
  Future<FsSpreadsheet?> retrieveSpreadsheet(
      {required int year, required int month}) async {
    CollectionReference colref = firestore.collection('spreadsheet');

    String docId = '${year}_$month';
    DocumentSnapshot snapshot =
        await colref.doc(docId).get().catchError((error) {
      lp(' Error in retrieveSpreadsheet $error');
      throw error;
    });

    if (snapshot.exists) {
      return FsSpreadsheet.fromMap(snapshot.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  ///-------- sendEmail
  @override
  Future<bool> sendEmail(
      {required List<Trainer> toList,
      required List<Trainer> ccList,
      required String subject,
      required String html}) async {
    bool result = false;
    CollectionReference mailRef = firestore.collection('mail');

    Map<String, dynamic> map = {};
    map['to'] = _buildEmailAdresList(toList);
    map['cc'] = _buildEmailAdresList(ccList);
    map['message'] = _buildEmailMessageMap(subject, html);

    await mailRef
        .add(map)
        .then((DocumentReference doc) => result = true)
        .onError((e, _) {
      lp('Error in sendEmail $e');
      return false;
    });

    return result;
  }

  ///--------------------------

  @override
  Future<void> saveTrainingGroups(List<TrainingGroup> trainingGroups) async {
    CollectionReference colRef =
        FirebaseFirestore.instance.collection('metadata');

    List<Map<String, dynamic>> groupsMap = [];
    for (TrainingGroup trainingGroup in trainingGroups) {
      groupsMap.add(trainingGroup.toMap());
    }
    Map<String, dynamic> map = {'groups': groupsMap};

    await colRef.doc('training_groups').set(map).then((val) {}).catchError((e) {
      lp('Error in saveFsSpreadsheet $e');
      throw e;
    });
  }

  @override
  Future<List<TrainingGroup>> getTrainingGroups() async {
    CollectionReference colRef =
        FirebaseFirestore.instance.collection('metadata');

    DocumentSnapshot snapshot = await colRef.doc('training_groups').get();
    if (snapshot.exists) {
      Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
      List<dynamic> data = List<dynamic>.from(map['groups'] as List);
      List<TrainingGroup> r =
          data.map((e) => TrainingGroup.fromMap(e)).toList();
      return r;
    } else {
      return [];
    }
  }

  ///============ private methods --------

  Map<String, dynamic> _buildEmailMessageMap(String subject, String html) {
    Map<String, dynamic> msgMap = {};
    msgMap['subject'] = subject;
    msgMap['html'] = html;
    return msgMap;
  }

  List<String> _buildEmailAdresList(List<Trainer> trainerList) {
    List<String> toList = [];
    for (Trainer trainer in trainerList) {
      if (trainer.email.isNotEmpty) {
        toList.add(trainer.email);
      }
    }

    return toList;
  }

  ///-- get schema's for trainer
  Future<TrainerSchema> _getTheTrainerSchema(String schemaId) async {
    CollectionReference schemaRef = firestore.collection('schemas');

    TrainerSchema trainerSchema = TrainerSchema.empty();

    await schemaRef.doc(schemaId).get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var map =
            Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
        map['id'] = schemaId;
        trainerSchema = TrainerSchema.fromMap(map);
        trainerSchema.isNew = false;
      } else {
        return [];
      }
    });

    return trainerSchema;
  }

  void _updateError(Object? ex) {}

  void _handleSucces(LogAction logAction) {
    Map<String, dynamic> map = {
      'at': DateTime.now(),
      'action': logAction.index
    };

    CollectionReference logsRef = firestore.collection('logs');
    String id =
        '${AppData.instance.getTrainer().pk}-${DateTime.now().microsecondsSinceEpoch}';
    logsRef.doc(id).set(map);
  }
}

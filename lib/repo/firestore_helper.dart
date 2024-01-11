import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/simulator.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:rooster/data/populate_data.dart' as p;

class FirestoreHelper with AppMixin {
  FirestoreHelper._();
  static final FirestoreHelper instance = FirestoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// find Trainer
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
        lp(trainer.toString());
      }
    });

    return trainer;
  }

  ///- get trainer, or null if not exists
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
  Future<TrainerSchema> getTrainerSchema(String trainerSchemaId) async {
    if (AppData.instance.simulate) {
      return Simulator.instance.getTrainerSchema(trainerSchemaId);
    } else {
      TrainerSchema schemas = await _getTheTrainerSchema(trainerSchemaId);
      return schemas;
    }
  }

  /// update the available value of the given DaySchema
  Future<bool> createOrUpdateTrainerSchemas(
      TrainerSchema trainerSchemas, bool updateSchema) async {
    bool result = false;

    if (!AppData.instance.simulate) {
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

  Future<List<Trainer>> getAllTrainers() async {
    List<Trainer> result = [];

    if (!AppData.instance.simulate) {
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

  Future<List<String>> getZamoTrainers() async {
    List<String> result = [];

    if (!AppData.instance.simulate) {
      CollectionReference zamoRef = firestore.collection('metadata');
      await zamoRef.doc('zamo_trainers').get().then(
        (val) {
          Map<String, dynamic> map = val.data() as Map<String, dynamic>;
          return map['trainers'];
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

  Future<List<String>> getTrainingItems() async {
    List<String> result = [];

    if (!AppData.instance.simulate) {
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

  Future<ApplyWeightValues> getApplyWeightValues() async {
    ApplyWeightValues? result;

    if (!AppData.instance.simulate) {
      CollectionReference ref = firestore.collection('metadata');
      await ref.doc('apply_weights').get().then(
        (val) {
          Map<String, dynamic> map = val.data() as Map<String, dynamic>;
          result = ApplyWeightValues.fromMap(map);
        },
        onError: (e) => lp("Error getting weight_values: $e"),
      ).catchError((e) {
        lp('Error in getZamoTrainers : $e');
        throw e;
      });
    } else {
      result = p.getApplyWeightValues();
    }

    return result!;
  }

  ///--------------------------
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
  Future<void> saveFsSpreadsheet(FsSpreadsheet fsSpreadsheet) async {
    CollectionReference trainerRef = firestore.collection('spreadsheet');
    await trainerRef
        .doc(fsSpreadsheet.getID())
        .set(fsSpreadsheet.toMap())
        .then((val) {})
        .catchError((e) {
      lp('Error in saveFsSpreadsheet $e');
      throw e;
    });
  }

  ///-------- sendEmail
  Future<bool> sendEmail(
      {required List<Trainer> toTrainers,
      required String subject,
      required String html}) async {
    bool result = false;
    CollectionReference mailRef = firestore.collection('mail');

    Map<String, dynamic> map = {};
    List<String> recipients = [];
    for (Trainer trainer in toTrainers) {
      if (trainer.email.isNotEmpty) {
        recipients.add(trainer.email);
      }
    }
    map['to'] = recipients;

    Map<String, dynamic> msgmap = {};
    msgmap['subject'] = subject;
    msgmap['html'] = html;

    map['message'] = msgmap;

    await mailRef
        .add(map)
        .then((DocumentReference doc) => result = true)
        .onError((e, _) {
      lp('Error in sendEmail $e');
      return false;
    });

    return result;
  }

  ///============ private methods --------

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

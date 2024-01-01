import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/simulator.dart';

class FirestoreHelper {
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
      TrainerSchema schemas = await _getSchemas(trainerSchemaId);
      return schemas;
    }
  }

  /// update the available value of the given DaySchema
  Future<bool> createOrUpdateTrainerSchemas(
      TrainerSchema trainerSchemas, bool updateSchema) async {
    bool result = false;

    if (!AppData.instance.simulate) {
      CollectionReference schemaRef = firestore.collection('schemas');

      if (updateSchema) trainerSchemas.modified = DateTime.now();

      await schemaRef.doc(trainerSchemas.id).set(trainerSchemas.toMap()).then(
          (value) {
        result = true;
        _handleSucces('updated trainerschema');
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
        onError: (e) => log("Error completing: $e"),
      ).catchError((e) {
        log('Error in getAllTrainers : $e');
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
    }).catchError((e) {
      log('Error in createOrUpdateTrainer $e');
      throw e;
    });

    return result;
  }

  ///--------------------------
  Future<LastRosterFinal> saveLastRosterFinal() async {
    LastRosterFinal lrf = LastRosterFinal(
        at: DateTime.now(),
        by: AppData.instance.getTrainer().pk,
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth());

    CollectionReference trainerRef = firestore.collection('metadata');
    await trainerRef
        .doc('last_published')
        .set(lrf.toMap())
        .then((val) {})
        .catchError((e) {
      log('Error in saveLastRosterFinal $e');
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
      log(' Error in getLastRosterFinal $e');
      throw e;
    });

    return result;
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
      log('Error in sendEmail $e');
      return false;
    });

    return result;
  }

  ///============ private methods --------

  ///-- get schema's for trainer
  Future<TrainerSchema> _getSchemas(String schemaId) async {
    CollectionReference schemaRef = firestore.collection('schemas');

    TrainerSchema trainerSchema = TrainerSchema.empty();

    await schemaRef.doc(schemaId).get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var map =
            Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
        map['id'] = schemaId;
        trainerSchema = TrainerSchema.fromMap(map);
      } else {
        return [];
      }
    });

    return trainerSchema;
  }

  void _updateError(Object? ex) {}

  void _handleSucces(String msg) {
    CollectionReference logsRef = firestore.collection('logs');
    String id =
        '${AppData.instance.getTrainer().pk}-${DateTime.now().microsecondsSinceEpoch}';
    logsRef.doc(id).set({'message': msg});
  }
}

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore/controller/app_controler.dart';
import 'package:firestore/data/populate_data.dart';
import 'package:firestore/data/trainer_data.dart';
import 'package:firestore/event/app_events.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/util/data_parser.dart';

class FirestoreHelper {
  static void addTrainers() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference trainers = firestore.collection('trainers');

    trainers
        .add(trainerRobin.toMap())
        .then((DocumentReference doc) =>
            log('DocumentSnapshot added with ID: ${doc.id}'))
        .onError((e, _) => log("Error writing document: $e"));
  }

  /// temp funtion to add schema's
  static void addSchemas() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference schemas = firestore.collection('schema');

    List<DaySchema> list = [ds3, ds4, ds5, ds6, ds7];

    for (DaySchema ds in list) {
      schemas
          .add(ds.toMap())
          .then((DocumentReference doc) =>
              log('DocumentSnapshot added with ID: ${doc.id}'))
          .onError((e, _) => log("Error writing document: $e"));
    }
  }

  /// receive all data used for editSchema view
  static void getAllTrainerData(String trainerId) async {
    Trainer? trainer = await _getTrainer(trainerId);
    if (trainer != null) {
      TrainerData.instance.trainer = trainer;
      String schemaId = AppController.instance.buildSchemaId();
      List<DaySchema> schemas = await _getSchemas(schemaId);
      AppEvents.fireTrainerDataReceived(trainer, schemas);
    }
  }

  /// update the available value of the given DaySchema
  static void updateSchema(DaySchema daySchema) {
    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    // CollectionReference schemaRef = firestore.collection('schema');
    // schemaRef.doc(daySchema.id).update({
    //   'available': daySchema.available,
    //   'modified': DateTime.now()
    // }).then(
    //     (value) => log(
    //         "DocumentSnapshot successfully updated! ${daySchema.id} => ${daySchema.available}"),
    //     onError: (e) => log("Error updating document $e"));
  }

  ///--- private methods --------
  static Future<Trainer?> _getTrainer(String trainerId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference trainersRef = firestore.collection('trainer');

    Trainer? trainer;

    await trainersRef.doc(trainerId).get().then((DocumentSnapshot snapshot) {
      var map =
          Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
      map['id'] = trainerId;
      trainer = Trainer.fromMap(map);
    });

    return trainer;
  }

  ///-- get schema's for trainer
  static Future<List<DaySchema>> _getSchemas(String schemaId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference schemaRef = firestore.collection('schemas');

    TrainerSchemas trainerSchemas = TrainerSchemas.empty();
    await schemaRef.doc(schemaId).get().then((DocumentSnapshot snapshot) {
      var map =
          Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
      map['id'] = schemaId;
      trainerSchemas = TrainerSchemas.fromMap(map);
      log(trainerSchemas.toJson());
    });

    List<DaySchema> daySchemas =
        DateParser.buildFromTrainerSchemas(trainerSchemas);

    daySchemas.sort((a, b) => a.day.compareTo(b.day));
    return daySchemas;
  }
}

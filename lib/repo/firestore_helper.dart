import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/data/populate_data.dart' as p;
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:stack_trace/stack_trace.dart';

enum FsCol {
  logs,
  trainer,
  schemas,
  spreadsheet,
  mail,
  metadata,
  error;
}

final Trainer administrator = p.trainerRobin;

class FirestoreHelper with AppMixin implements Dbs {
  FirestoreHelper._();
  static final FirestoreHelper instance = FirestoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// find Trainer
  @override
  Future<Trainer> findTrainerByAccessCode(String accessCode) async {
    CollectionReference colRef = collectionRef(FsCol.trainer);
    Trainer trainer = Trainer.empty();

    late QuerySnapshot querySnapshot;
    try {
      querySnapshot =
          await colRef.where('accessCode', isEqualTo: accessCode).get();
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    try {
      if (querySnapshot.size > 0) {
        var map = Map<String, dynamic>.from(
            querySnapshot.docs[0].data() as Map<dynamic, dynamic>);
        trainer = Trainer.fromMap(map);
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return trainer;
  }

  ///- get trainer, or null if not exists
  @override
  Future<Trainer?> getTrainerByPk(String trainerPk) async {
    CollectionReference colRef = collectionRef(FsCol.trainer);
    Trainer? trainer;

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc(trainerPk).get();
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    try {
      if (snapshot.exists) {
        var map =
            Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
        map['id'] = trainerPk;
        trainer = Trainer.fromMap(map);
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return trainer;
  }

  /// receive all data used for editSchema view
  @override
  Future<TrainerSchema> getTrainerSchema(String trainerSchemaId) async {
    TrainerSchema schemas = await _getTheTrainerSchema(trainerSchemaId);
    return schemas;
  }

  /// update the available value of the given DaySchema
  @override
  Future<bool> createOrUpdateTrainerSchemas(TrainerSchema trainerSchemas,
      {required bool updateSchema}) async {
    bool result = false;

    CollectionReference colRef = collectionRef(FsCol.schemas);

    if (updateSchema) {
      trainerSchemas.modified = DateTime.now();
      trainerSchemas.isNew = false;
    } else {
      trainerSchemas.isNew = true;
    }

    try {
      await colRef.doc(trainerSchemas.id).set(trainerSchemas.toMap());
      result = true;
      _handleSucces(LogAction.modifySchema);
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return result;
  }

  ///--------------------------------------------

  @override
  Future<List<Trainer>> getAllTrainers() async {
    List<Trainer> result = [];

    CollectionReference colRef = collectionRef(FsCol.trainer);
    late QuerySnapshot querySnapshot;

    try {
      querySnapshot = await colRef.get();
      for (var doc in querySnapshot.docs) {
        var map = doc.data() as Map<String, dynamic>;
        map['id'] = doc.id;
        Trainer trainer = Trainer.fromMap(map);
        result.add(trainer);
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return result;
  }

  ///--------------------------
  @override
  Future<Trainer> createOrUpdateTrainer(trainer) async {
    Trainer result = Trainer.empty();

    CollectionReference colRef = collectionRef(FsCol.trainer);

    try {
      Map<String, dynamic> map = trainer.toMap();
      await colRef.doc(trainer.pk).set(map);
      result = trainer;
      _handleSucces(LogAction.modifySettings);
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return result;
  }

  ///--------------------------------------------
  // get list of items used to populate combobox of training items
  @override
  Future<List<String>> getTrainingItems() async {
    List<String> result = [];

    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('training_items').get();
      Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
      result = List<String>.from(map['items'] as List);
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  ///--------------------------------------------

  @override
  Future<MetaPlanRankValues> getApplyPlanRankValues() async {
    MetaPlanRankValues? result;

    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('rank_values').get();
      Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
      result = MetaPlanRankValues.fromMap(map);
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result!;
  }

  ///--------------------------------------------

  @override
  Future<void> savePlanRankValues(MetaPlanRankValues planRankValues) async {
    CollectionReference colRef = collectionRef(FsCol.metadata);

    try {
      await colRef.doc('rank_values').set(planRankValues.toMap());
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }
  }

  ///--------------------------
  @override
  Future<LastRosterFinal> saveLastRosterFinal() async {
    LastRosterFinal lrf = LastRosterFinal(
        at: DateTime.now(),
        by: AppData.instance.getTrainer().pk,
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth());

    CollectionReference colRef = collectionRef(FsCol.metadata);

    try {
      await colRef.doc('last_published').set(lrf.toMap());
      _handleSucces(LogAction.finalizeSpreadsheet);
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return lrf;
  }

  ///--------------------------
  @override
  Future<LastRosterFinal?> getLastRosterFinal() async {
    LastRosterFinal? result;

    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('last_published').get();
      result = LastRosterFinal.fromMap(snapshot.data() as Map<String, dynamic>);
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  ///--------------------------
  @override
  Future<void> saveFsSpreadsheet(FsSpreadsheet fsSpreadsheet) async {
    CollectionReference colRef = collectionRef(FsCol.spreadsheet);

    try {
      await colRef.doc(fsSpreadsheet.getID()).set(fsSpreadsheet.toMap());
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }
  }

  //-----------------------------------------
  @override
  Future<FsSpreadsheet?> retrieveSpreadsheet(
      {required int year, required int month}) async {
    FsSpreadsheet? result;
    CollectionReference colRef = collectionRef(FsCol.spreadsheet);

    String docId = '${year}_$month';
    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc(docId).get();
      if (snapshot.exists) {
        result = FsSpreadsheet.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  ///-------- sendEmail
  @override
  Future<bool> sendEmail(
      {required List<Trainer> toList,
      required List<Trainer> ccList,
      required String subject,
      required String html}) async {
    bool result = false;
    CollectionReference colRef = collectionRef(FsCol.mail);

    Map<String, dynamic> map = {};
    map['to'] = _buildEmailAdresList(toList);
    map['cc'] = _buildEmailAdresList(ccList);
    map['message'] = _buildEmailMessageMap(subject, html);

    await colRef
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
    CollectionReference colRef = collectionRef(FsCol.metadata);

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
  Future<void> saveExcludeDays(List<ExcludeDay> excludeDays) async {
    CollectionReference colRef = collectionRef(FsCol.metadata);

    List<Map<String, dynamic>> excludeDaysMap = [];
    for (ExcludeDay excDay in excludeDays) {
      excludeDaysMap.add(excDay.toMap());
    }
    Map<String, dynamic> map = {'days': excludeDaysMap};

    await colRef.doc('exclude_days').set(map).then((val) {}).catchError((e) {
      lp('Error in saveExcludeDays $e');
      throw e;
    });
  }

  @override
  Future<List<ExcludeDay>> getExcludeDays() async {
    List<ExcludeDay> result = [];
    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('exclude_days').get();
      if (snapshot.exists) {
        Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
        List<dynamic> data = List<dynamic>.from(map['days'] as List);
        result = data.map((e) => ExcludeDay.fromMap(e)).toList();
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  @override
  Future<List<TrainingGroup>> getTrainingGroups() async {
    List<TrainingGroup> result = [];
    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('training_groups').get();
      if (snapshot.exists) {
        Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
        List<dynamic> data = List<dynamic>.from(map['groups'] as List);
        result = data.map((e) => TrainingGroup.fromMap(e)).toList();
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
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

    if (AppData.instance.runMode != RunMode.prod) {
      toList = [administrator.email];
    }

    return toList;
  }

  ///-- get schema's for trainer
  Future<TrainerSchema> _getTheTrainerSchema(String schemaId) async {
    CollectionReference colRef = collectionRef(FsCol.schemas);

    TrainerSchema trainerSchema = TrainerSchema.empty();

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc(schemaId).get();
      if (snapshot.exists) {
        var map =
            Map<String, dynamic>.from(snapshot.data() as Map<dynamic, dynamic>);
        map['id'] = schemaId;
        trainerSchema = TrainerSchema.fromMap(map);
        trainerSchema.isNew = false;
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return trainerSchema;
  }

  void _saveError(String errMsg, String trace) {
    CollectionReference colRef = collectionRef(FsCol.error);

    Map<String, dynamic> map = {
      'at': DateTime.now(),
      'err': errMsg,
      'trace': trace,
    };

    String id = _uniqueDocId();
    colRef.doc(id).set(map);
  }

  ///--------------------------------------------
  void handleError(Object? ex, StackTrace stackTrace) {
    String traceMsg = _buildTraceMsg(stackTrace);
    _saveError(ex.toString(), traceMsg);

    String by = AppData.instance.getTrainer().isEmpty()
        ? ''
        : ' by ${AppData.instance.getTrainer().pk}';

    String html = '<div>Error detected $by : $ex <br> $traceMsg</div>';
    sendEmail(
        toList: [administrator], ccList: [], subject: 'Error', html: html);

    AppEvents.fireErrorEvent(ex.toString());
  }

  String _buildTraceMsg(StackTrace stackTrace) {
    String traceMsg = '';
    Trace trace = Trace.from(stackTrace).terse;
    List<Frame> frames = trace.frames;
    for (Frame frame in frames) {
      String s = frame.toString();
      if (s.contains('rooster')) {
        traceMsg += '$s;';
      }
    }
    return traceMsg;
  }

  ///----------------
  void _handleSucces(LogAction logAction) {
    Map<String, dynamic> map = {
      'at': DateTime.now(),
      'action': logAction.index
    };

    CollectionReference colRef = collectionRef(FsCol.logs);
    String id = _uniqueDocId();
    colRef.doc(id).set(map);
  }

  ///----------------
  String _uniqueDocId() {
    String id =
        '${AppData.instance.getTrainer().pk}-${DateTime.now().microsecondsSinceEpoch}';
    return id;
  }

  ///--------------------------------------------
  CollectionReference collectionRef(FsCol fsCol) {
    String collectionName = AppData.instance.runMode == RunMode.prod
        ? fsCol.name
        : '${fsCol.name}_acc';

    if (collectionName.startsWith('mail')) {
      collectionName = 'mail';
    }

    return firestore.collection(collectionName);
  }
}

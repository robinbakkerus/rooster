import 'package:firestore/data/trainer_data.dart';
import 'package:firestore/event/app_events.dart';
import 'package:firestore/model/app_models.dart';
import 'package:firestore/repo/firestore_helper.dart';
// ignore: depend_on_referenced_packages
// import 'package:collection/collection.dart';

class AppController {
  AppController._() {
    AppEvents.onTrainerDataReceivedEvent(_onTrainerDataReceived);
  }

  static AppController instance = AppController._();

  /// get trainer data
  void getTrainerData(String trainerId) {
    FirestoreHelper.getAllTrainerData(trainerId);
  }

  /// update all modified DaySchema's
  void updateSchemas() {
    // List<DaySchema> modifiedSchemaList = [];
    // for (DaySchema dsOld in TrainerData.instance.oldSchemas) {
    //   DaySchema? dsNew = TrainerData.instance.newSchemas
    //       .firstWhereOrNull((elem) => elem.id == dsOld.id);

    //   if (dsNew != null && dsNew.available != dsOld.available) {
    //     modifiedSchemaList.add(dsNew);
    //   }
    // }

    // for (DaySchema daySchema in modifiedSchemaList) {
    //   FirestoreHelper.updateSchema(daySchema);
    // }

    // getTrainerData(TrainerData.instance.trainer.id);
  }

  ///---
  ///
  String buildSchemaId() {
    String result = TrainerData.instance.trainer.shortname;
    result += '_${TrainerData.instance.year}';
    result += '_${TrainerData.instance.month}';
    return result;
  }

  /// private methods
  ///
  void _onTrainerDataReceived(TrainerDataReceivedEvent event) {
    TrainerData.instance.trainer = event.trainer;
    TrainerData.instance.oldSchemas = event.schemas;

    TrainerData.instance.newSchemas = [];
    for (DaySchema daySchema in TrainerData.instance.oldSchemas) {
      TrainerData.instance.newSchemas.add(daySchema.copyWith());
    }

    AppEvents.fireTrainerDataReady();
  }
}

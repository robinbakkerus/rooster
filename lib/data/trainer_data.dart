import 'dart:developer';

import 'package:firestore/model/app_models.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class TrainerData {
  TrainerData._() {
    _initialize();
  }

  static final instance = TrainerData._();

  void _initialize() {}

  /// these contains the current active values
  late String trainerId = "";
  Trainer trainer = Trainer.unknown();
  int year = 2024;
  int month = 1;
  List<DaySchema> oldSchemas = [];
  List<DaySchema> newSchemas = [];

  ///--- setTrainerId
  void setTrainerId() {
    String path = Uri.base.path;
    if (path.isNotEmpty) {
      trainerId = path.substring(1);
    }
  }

  ///--- update the avavailability in the newSchemas list
  void update(DaySchema daySchema, int newValue) {
    DaySchema? ds =
        newSchemas.firstWhereOrNull((elem) => elem.day == daySchema.day);

    if (ds != null) {
      ds.available = newValue;
      // log('updated $ds.id => $newValue');
    }
  }

  ///--- update the avavailability in the oldSchemas list
  bool isDirty() {
    for (int i = 0; i < oldSchemas.length; i++) {
      DaySchema oldS = oldSchemas[i];
      DaySchema newS = newSchemas[i];
      if (oldS.available != newS.available) {
        log('dirty ');
        return true;
      }
    }
    log(' not dirty');
    return false;
  }

  String getFirstname() {
    List<String> tokens = trainer.fullname.split(' ');
    if (tokens.isNotEmpty) {
      return tokens[0];
    } else {
      return trainer.fullname;
    }
  }
}

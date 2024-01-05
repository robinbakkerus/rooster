import 'dart:developer';

import 'package:rooster/model/app_models.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/util/app_helper.dart';

class AppData {
  AppData._() {
    _initialize();
  }

  static final instance = AppData._();

  void _initialize() {}

  /// these contains the current active values
  bool simulate = false;
  double screenWidth = 600.0; //assume
  double screenHeight = 600.0; //assume
  late String trainerId = "";

  TrainerData _trainerData = TrainerData.empty();
  List<TrainerData> _allTrainerData = [];

  TrainerData getTrainerData() {
    return _trainerData;
  }

  void setTrainerData(TrainerData trainerData) {
    _setTrainerData(trainerData);
  }

  List<TrainerData> getAllTrainerData() {
    return _allTrainerData;
  }

  void setAllTrainerData(List<TrainerData> allTrainerData) {
    _setAllTrainerData(allTrainerData);
  }

  List<Trainer> getAllTrainers() {
    List<Trainer> result = [];
    for (TrainerData trainerData in _allTrainerData) {
      result.add(trainerData.trainer);
    }
    return result;
  }

  DateTime _activeDate = DateTime(2024, 1, 1);
  final DateTime firstMonth = DateTime(2024, 1, 1);
  DateTime lastMonth = DateTime(2024, 1, 1);

  Trainer getTrainer() {
    return _trainerData.trainer;
  }

  void setTrainer(Trainer trainer) {
    _trainerData.trainer = trainer;
  }

  List<DaySchema> getOldSchemas() {
    return _trainerData.oldSchemas;
  }

  List<DaySchema> getNewSchemas() {
    return _trainerData.newSchemas;
  }

  // List<Trainer> allTrainers = [];
  // List<List<DaySchema>> allSchemas = [];
  List<DateTime> _activeDates = [];

  // ---
  void setActiveDate(DateTime date) {
    _activeDate = date;
    List<DateTime> allDates = AppHelper.instance.getDaysInBetween(date);
    _activeDates = allDates
        .where((e) =>
            e.weekday == DateTime.tuesday ||
            e.weekday == DateTime.thursday ||
            e.weekday == DateTime.saturday)
        .toList();
  }

  DateTime getActiveDate() {
    return _activeDate;
  }

  List<DateTime> getActiveDates() {
    return _activeDates;
  }

  int getActiveMonth() {
    return _activeDate.month;
  }

  int getActiveYear() {
    return _activeDate.year;
  }

  ///
  String getActiveMonthAsString() {
    return maanden[getActiveMonth() - 1];
  }

  ///--- update the avavailability in the newSchemas list
  void updateAvailability(DaySchema daySchema, int newValue) {
    DaySchema? ds = _trainerData.newSchemas
        .firstWhereOrNull((elem) => elem.day == daySchema.day);

    if (ds != null) {
      ds.available = newValue;
    } else {
      log('!!! dit kan niet (updateAvailability)');
    }
  }

  ///--- update the avavailability in the oldSchemas list
  bool isSchemaDirty() {
    for (int i = 0; i < getOldSchemas().length; i++) {
      DaySchema oldS = getOldSchemas()[i];
      DaySchema newS = getNewSchemas()[i];
      if (oldS.available != newS.available) {
        return true;
      }
    }
    return false;
  }

  List<String> maanden = [
    'Januari',
    'Februari',
    'Maart',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Augustus',
    'September',
    'Oktober',
    'November',
    'December'
  ];

  //---------- private --------------

  void _setTrainerData(TrainerData trainerData) {
    _trainerData = trainerData;
    List<List<DaySchema>> oldAndNewDaySchemas =
        _buildOldAndNewDaySchemaList(trainerData.trainerSchemas);

    _trainerData.oldSchemas = oldAndNewDaySchemas[0];
    _trainerData.newSchemas = oldAndNewDaySchemas[1];
  }

  void _setAllTrainerData(List<TrainerData> trainerDataList) {
    _allTrainerData = trainerDataList;

    for (TrainerData trainerData in _allTrainerData) {
      List<List<DaySchema>> oldAndNewDaySchemas =
          _buildOldAndNewDaySchemaList(trainerData.trainerSchemas);

      trainerData.oldSchemas = oldAndNewDaySchemas[0];
      trainerData.newSchemas = oldAndNewDaySchemas[1];
    }
  }

  List<List<DaySchema>> _buildOldAndNewDaySchemaList(
      TrainerSchema trainerSchemas) {
    List<List<DaySchema>> result = [];

    List<DaySchema> oldSchemas =
        AppHelper.instance.buildFromTrainerSchemas(trainerSchemas);
    oldSchemas.sort((a, b) => a.day.compareTo(b.day));
    result.add(oldSchemas);

    List<DaySchema> newSchemas = [];
    for (DaySchema daySchema in oldSchemas) {
      newSchemas.add(daySchema.copyWith());
    }
    result.add(newSchemas);

    return result;
  }
}

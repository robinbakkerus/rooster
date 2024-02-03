import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class AppData {
  AppData._() {
    _initialize();
  }

  static final instance = AppData._();

  void _initialize() {}

  /// these contains the current active values
  RunMode runMode = RunMode.prod;

  double screenWidth = 600.0; //assume
  double screenHeight = 600.0; //assume
  double shortestSide = 600; //assume
  String trainerId = "";

  DateTime _activeDate = DateTime(2024, 1, 1);
  DateTime lastActiveDate = DateTime(2024, 1, 1);
  DateTime lastMonth = DateTime(2024, 1, 1);
  DateTime firstSpreadDate = DateTime(2024, 1, 1);

  int stackIndex = 0;
  List<String> zamoTrainers = [];
  String zamoDefaultTraing = '';
  List<String> trainerItems = [];
  late MetaPlanRankValues planRankValues;

  SpreadsheetStatus spreadSheetStatus = SpreadsheetStatus.initial; //asume
  SpreadsheetStatus _prevSpreadSheetStatus = SpreadsheetStatus.initial; //asume
  // this is set in the start_page when you click on the showSpreadsheet, or next/prev month
  SpreadSheet _spreadSheet = SpreadSheet(year: 2024, month: 1);
  SpreadSheet _originalSpreadSheet =
      SpreadSheet(year: 2024, month: 1); // to obtain the diffs

  List<TrainingGroup> trainingGroups = [];
  List<ActiveTrainingGroup> activeTrainingGroups = [];

  String lastSnackbarMsg = '';

  List<String> trainingDays = ['dinsdag', 'donderdag', 'zaterdag'];

  SpreadSheet getSpreadsheet() {
    return _spreadSheet;
  }

  SpreadSheet getOriginalpreadsheet() {
    return _originalSpreadSheet;
  }

  bool isSpreadsheetDirty() {
    return AppData.instance.getSpreadsheet() !=
        AppData.instance.getOriginalpreadsheet();
  }

  DateTime getSpreadsheetDate() {
    return DateTime(getSpreadsheet().year, getSpreadsheet().month, 1);
  }

  void setSpreadsheet(SpreadSheet spreadSheet) {
    _spreadSheet = spreadSheet;
    _originalSpreadSheet = spreadSheet.clone();

    spreadSheetStatus = spreadSheet.isFinal
        ? SpreadsheetStatus.active
        : SpreadsheetStatus.initial;
  }

  void updateSpreadsheet(SpreadSheet spreadSheet) {
    _spreadSheet = spreadSheet;
    if (_spreadSheet != getOriginalpreadsheet()) {
      _prevSpreadSheetStatus = spreadSheetStatus;
      spreadSheetStatus = SpreadsheetStatus.dirty;
    } else {
      spreadSheetStatus = _prevSpreadSheetStatus;
    }
  }

  TrainerData _trainerData = TrainerData.empty();
  List<int> newAvailaibleList = [];
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

  void setAllTrainerData(List<TrainerData> allTrainerDataList) {
    _allTrainerData = allTrainerDataList;
  }

  TrainerData getTrainerDataForTrainer(Trainer trainer) {
    TrainerData? trainerData =
        getAllTrainerData().firstWhereOrNull((e) => e.trainer == trainer);

    return trainerData ?? TrainerData.empty();
  }

  List<Trainer> getAllTrainers() {
    List<Trainer> result = [];
    for (TrainerData trainerData in _allTrainerData) {
      result.add(trainerData.trainer);
    }
    return result;
  }

  Trainer getTrainer() {
    return _trainerData.trainer;
  }

  void setTrainer(Trainer trainer) {
    _trainerData.trainer = trainer;
  }

  List<DateTime> _activeDates = [];

  // ---
  void setActiveDate(DateTime date) {
    DateTime useDate = DateTime(date.year, date.month, 1);
    _activeDate = useDate;
    List<DateTime> allDates = AppHelper.instance.getDaysInBetween(useDate);
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

  ///--- update the avavailability in the newAvailabilities list
  void updateAvailability({required int dateIndex, required int newValue}) {
    newAvailaibleList[dateIndex] = newValue;
  }

  void updateTrainerPref(String paramName, int newValue) {
    Map<String, dynamic> map = _trainerData.trainer.toMap();
    map[paramName] = newValue;
    _trainerData.trainer = Trainer.fromMap(map);
  }

  ///-----------------------------------
  bool isSchemaDirty() {
    for (int i = 0; i < AppData.instance.newAvailaibleList.length; i++) {
      int oldAvail =
          AppData.instance.getTrainerData().trainerSchemas.availableList[i];
      int newAvail = AppData.instance.newAvailaibleList[i];
      if (oldAvail != newAvail) {
        return true;
      }
    }
    return false;
  }

  bool isZamoTrainer(String trainerPk) {
    return zamoTrainers.contains(trainerPk);
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

    newAvailaibleList = [];
    for (int avail
        in AppData.instance.getTrainerData().trainerSchemas.availableList) {
      newAvailaibleList.add(avail);
    }
  }
}

import 'dart:developer';
import 'dart:html';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/firestore_helper.dart';
import 'package:rooster/util/data_helper.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
// import 'package:collection/collection.dart';

class AppController {
  AppController._();

  static AppController instance = AppController._();

  /// get screen widt and save this
  void initializeAppData(BuildContext context) {
    _setScreenSizes(context);
    _setDates();
  }

  /// find the trainer gived the access code
  Future<bool> findTrainer(String accessCode) async {
    bool result = false;

    Trainer trainer =
        await FirestoreHelper.instance.findTrainerByAccessCode(accessCode);

    if (!trainer.isEmpty()) {
      getTrainerData(trainer: trainer);
      document.cookie = "ac=${trainer.accessCode}";
      result = true;
    } else {
      log("no trainer with access code $accessCode");
      result = false;
    }

    return result;
  }

  /// get trainer data
  Future<void> getTrainerData({String? trainerPk, Trainer? trainer}) async {
    TrainerData trainerData = await _getTheTrainerData(
        trainerPk: trainerPk, trainer: trainer, forAllTrainers: false);
    AppData.instance.setTrainerData(trainerData);
    AppEvents.fireTrainerDataReady();
  }

  /// get TrainerData for all trainers
  Future<List<TrainerData>> _getAllTrainerData() async {
    List<Trainer> allTrainers = await FirestoreHelper.instance.getAllTrainers();

    List<TrainerData> allTrainerData = [];
    for (Trainer trainer in allTrainers) {
      TrainerData trainerData =
          await _getTheTrainerData(trainer: trainer, forAllTrainers: true);
      allTrainerData.add(trainerData);
    }

    AppData.instance.setAllTrainerData(allTrainerData);
    AppEvents.fireAllTrainerDataReady();

    return allTrainerData;
  }

  /// update all modified DaySchema's
  void updateTrainerSchemas() {
    List<DaySchema> daySchemas = AppData.instance.getNewSchemas();
    TrainerSchema trainerSchemas =
        DataHelper.instance.buildFromDaySchemas(daySchemas);
    FirestoreHelper.instance.createOrUpdateTrainerSchemas(trainerSchemas, true);
    getTrainerData(trainer: AppData.instance.getTrainer());
  }

  ///----- updateTrainer
  Future<bool> updateTrainer(Trainer trainer) async {
    Trainer updatedTrainer =
        await FirestoreHelper.instance.createOrUpdateTrainer(trainer);
    AppData.instance.setTrainer(updatedTrainer);
    return true;
  }

  ///----------------------------
  void setActiveDate(DateTime date) {
    AppData.instance.setActiveDate(date);
    AppEvents.fireDatesReady();
  }

  Future<SpreadSheet> generateSpreadsheet() async {
    List<TrainerData> trainerData = await _getAllTrainerData();

    List<Available> availableList =
        SpreadsheetGenerator.instance.generateAvailableTrainersCounts();
    SpreadSheet spreadSheet = SpreadsheetGenerator.instance
        .generateSpreadsheet(availableList, AppData.instance.getActiveDate());

    AppData.instance.setAllTrainerData(trainerData);
    AppData.instance.setSpreadsheet(spreadSheet);
    AppEvents.fireAllTrainerDataReady();

    return spreadSheet;
  }

  ///--------------------
  void finalizeRoster(SpreadSheet spreadSheet) async {
    await _sendEmailToTrainers(spreadSheet);
    await FirestoreHelper.instance.saveLastRosterFinal();
  }

  Future<void> _sendEmailToTrainers(SpreadSheet spreadSheet) async {
    String html = SpreadsheetGenerator.instance.generateHtml(spreadSheet);
    List<String> csvList =
        SpreadsheetGenerator.instance.generateCsv(spreadSheet);
    String content = '$html<br><br>';
    for (String line in csvList) {
      content += '$line<br>';
    }
    bool okay = await FirestoreHelper.instance.sendEmail(
        toTrainers: AppData.instance.getAllTrainers(),
        subject: 'Trainingschema',
        html: content);

    if (okay) {
      log("email okay");
    } else {
      log("!email NOT  okay");
    }
  }

  ///--------------------
  Future<LastRosterFinal?> getLastRosterFinal() async {
    return await FirestoreHelper.instance.getLastRosterFinal();
  }

  /// private methods -----------------

  /// get trainer data
  Future<TrainerData> _getTheTrainerData(
      {String? trainerPk,
      Trainer? trainer,
      required bool forAllTrainers}) async {
    TrainerData result = TrainerData.empty();

    Trainer? useTrainer = (trainer == null && trainerPk != null)
        ? await FirestoreHelper.instance.getTrainerById(trainerPk)
        : trainer;

    result.trainer = useTrainer!;
    String schemaId = DataHelper.instance.buildTrainerSchemaId(useTrainer);

    TrainerSchema trainerSchemas =
        await FirestoreHelper.instance.getTrainerSchema(schemaId);

    if (!trainerSchemas.isEmpty()) {
      result.trainerSchemas = trainerSchemas;
    } else if (!forAllTrainers) {
      TrainerSchema newTrainerSchemas =
          DataHelper.instance.buildNewSchemaForTrainer(useTrainer);

      bool updateSchema = false;
      bool updateOkay = await FirestoreHelper.instance
          .createOrUpdateTrainerSchemas(newTrainerSchemas, updateSchema);
      if (updateOkay) {
        result.trainerSchemas = newTrainerSchemas;
      }
    }
    return result;
  }

  void _setDates() async {
    DateTime lastActiveDate = await _getLastActiveDate();

    DateTime nextMonth = lastActiveDate.day > 15
        ? lastActiveDate.add(const Duration(days: 20))
        : lastActiveDate.add(const Duration(days: 31));

    setActiveDate(DateTime(nextMonth.year, nextMonth.month, 1));

    const int nMonths = 2;
    DateTime lastMonth = lastActiveDate.day > 15
        ? lastActiveDate.add(const Duration(days: (nMonths * 31) - 5))
        : lastActiveDate.add(const Duration(days: nMonths * 31));
    AppData.instance.lastMonth = lastMonth;
  }

  Future<DateTime> _getLastActiveDate() async {
    DateTime now = DateTime.now();
    DateTime lastActiveDate = DateTime(now.year, now.month, 1); //assume
    LastRosterFinal? lastRosterFinal = await getLastRosterFinal();

    if (lastRosterFinal != null) {
      DateTime lrfDate =
          DateTime(lastRosterFinal.year, lastRosterFinal.month, 1);
      if (lrfDate.millisecondsSinceEpoch >
          lastActiveDate.millisecondsSinceEpoch) {
        log('use lastRosterFinal to calc active date = ${lastRosterFinal.month}');
        lastActiveDate =
            DateTime(lastRosterFinal.year, lastRosterFinal.month, 1);
      }
    }
    return lastActiveDate;
  }

  void _setScreenSizes(BuildContext context) {
    double width = (MediaQuery.of(context).size.width);
    AppData.instance.screenWidth = width;
    double height = (MediaQuery.of(context).size.height);
    AppData.instance.screenHeight = height;
  }
}

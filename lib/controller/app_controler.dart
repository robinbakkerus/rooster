import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:rooster/repo/authentication.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/date_symbol_data_local.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/data/populate_data.dart' as p;

class AppController {
  AppController._();

  static AppController instance = AppController._();

  /// get screen sizes and save this
  Future<void> initializeAppData(BuildContext context) async {
    _setScreenSizes(context);
    _setDates();
    await initializeDateFormatting('nl_NL', null);
  }

  /// find the trainer gived the access code
  Future<bool> findTrainer(String accessCode) async {
    Trainer trainer = await Dbs.instance.findTrainerByAccessCode(accessCode);

    bool signInOkay = await AuthHelper.instance.signIn(
        email: trainer.email,
        password: AppHelper.instance.getAuthPassword(trainer));

    if (signInOkay) {
      _setCookieIfNeeded(trainer, accessCode);
      AppEvents.fireTrainerReady();
      return true;
    } else {
      return false;
    }
  }

  bool _setCookieIfNeeded(Trainer trainer, String accessCode) {
    if (!trainer.isEmpty()) {
      getTrainerData(trainer: trainer);
      html.document.cookie = "ac=${trainer.accessCode}";
      return true;
    } else {
      log("no trainer with access code $accessCode");
      return false;
    }
  }

  /// get trainer data
  Future<void> getTrainerData({String? trainerPk, Trainer? trainer}) async {
    TrainerData trainerData = await _getTheTrainerData(
        trainerPk: trainerPk, trainer: trainer, forAllTrainers: false);
    AppData.instance.setTrainerData(trainerData);
    AppEvents.fireTrainerDataReady();
  }

  // get Zamo trainers
  Future<void> getZamoTrainersAndDefaultTraining() async {
    List<String> zamoTrainers = await Dbs.instance.getZamoTrainers();
    AppData.instance.zamoTrainers = zamoTrainers;

    String defaultTraining = await Dbs.instance.getZamoTrainingDefault();
    AppData.instance.zamoDefaultTraing = defaultTraining;
  }

  // get Zamo trainers
  Future<void> getApplyWeightValues() async {
    ApplyWeightValues applyWeightValues =
        await Dbs.instance.getApplyWeightValues();
    AppData.instance.applyWeightValues = applyWeightValues;
  }

  // get trainer_items (to fill combobox)
  Future<void> getTrainingItems() async {
    List<String> trainerItems = await Dbs.instance.getTrainingItems();
    AppData.instance.trainerItems = trainerItems;
  }

  /// update all modified DaySchema's
  void updateTrainerSchemas() {
    TrainerSchema trainerSchemas =
        AppData.instance.getTrainerData().trainerSchemas;
    trainerSchemas.availableList = AppData.instance.newAvailaibleList;
    Dbs.instance
        .createOrUpdateTrainerSchemas(trainerSchemas, updateSchema: true);
    getTrainerData(trainer: AppData.instance.getTrainer());
  }

  ///----- updateTrainer
  Future<bool> updateTrainer(Trainer trainer) async {
    Trainer updatedTrainer = await Dbs.instance.createOrUpdateTrainer(trainer);
    AppData.instance.setTrainer(updatedTrainer);
    return true;
  }

  ///----------------------------
  void setActiveDate(DateTime date) {
    AppData.instance.setActiveDate(date);
    AppEvents.fireDatesReady();
  }

  Future<SpreadSheet> generateOrRetrieveSpreadsheet() async {
    SpreadSheet result;

    await _getAllTrainerDataForThisSpreadsheet();

    SpreadSheet? spreadSheet = await _getTheActiveSpreadsheet();
    if (spreadSheet != null) {
      result = spreadSheet;
    } else {
      result = _generateTheSpreadsheet();
    }

    AppData.instance.setSpreadsheet(result);
    AppEvents.fireSpreadsheetReady();
    return result;
  }

  ///------------------------------------------------
  SpreadSheet _generateTheSpreadsheet() {
    List<Available> availableList =
        SpreadsheetGenerator.instance.generateAvailableTrainersCounts();
    SpreadSheet spreadSheet = SpreadsheetGenerator.instance
        .generateSpreadsheet(availableList, AppData.instance.getActiveDate());
    return spreadSheet;
  }

  ///------------------------------------------------
  Future<SpreadSheet?> _getTheActiveSpreadsheet() async {
    FsSpreadsheet? fsSpreadsheet = await Dbs.instance.retrieveSpreadsheet(
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth());

    return fsSpreadsheet != null ? _mapFromFsSpreadsheet(fsSpreadsheet) : null;
  }

  ///-------------- map spreadsheet
  SpreadSheet _mapFromFsSpreadsheet(FsSpreadsheet fsSpreadsheet) {
    SpreadSheet spreadSheet =
        SpreadSheet(year: fsSpreadsheet.year, month: fsSpreadsheet.month);
    spreadSheet.isFinal = fsSpreadsheet.isFinal;

    List<Available> availableList =
        SpreadsheetGenerator.instance.generateAvailableTrainersCounts();

    for (int r = 0; r < fsSpreadsheet.rows.length; r++) {
      FsSpreadsheetRow fsRow = fsSpreadsheet.rows[r];
      SheetRow row =
          SheetRow(rowIndex: r, date: fsRow.date, isExtraRow: fsRow.isExtraRow);
      row.trainingText = fsRow.trainingText;

      for (int c = 0; c < fsRow.rowCells.length; c++) {
        RowCell cell = RowCell(rowIndex: r, colIndex: c);
        cell.text = fsRow.rowCells[c];
        cell.availableCounts = _getAvailable(availableList, row.date).counts[c];
        row.rowCells.add(cell);
      }

      spreadSheet.rows.add(row);
    }
    return spreadSheet;
  }

  Available _getAvailable(List<Available> availableList, DateTime date) {
    Available? result = availableList.firstWhereOrNull((e) => e.date == date);
    return result ?? Available(date: date);
  }

  ///--------------------
  void finalizeSpreadsheet(SpreadSheet spreadSheet) async {
    FsSpreadsheet fsSpreadsheet =
        SpreadsheetGenerator.instance.fsSpreadsheetFrom(spreadSheet);
    fsSpreadsheet.isFinal = true;
    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
    await Dbs.instance.saveLastRosterFinal();
    await _mailSpreadsheetIsFinal(spreadSheet);
  }

  ///--------------------
  Future<void> updateSpreadsheet(SpreadSheet spreadSheet) async {
    FsSpreadsheet fsSpreadsheet =
        SpreadsheetGenerator.instance.fsSpreadsheetFrom(spreadSheet);
    FsSpreadsheet oldFsSpreadsheet = SpreadsheetGenerator.instance
        .fsSpreadsheetFrom(AppData.instance.getOriginalpreadsheet());
    List<SpreedsheetDiff> diffs = _getSpreadsheetDiffs(
        newSpreadsheet: fsSpreadsheet, oldSpreadsheet: oldFsSpreadsheet);
    String html =
        _getSpreadsheetDiffsAsHtml(diffs: diffs, spreadSheet: spreadSheet);
    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
    List<Trainer> toTrainers =
        _getSpreadsheetDiffsEmailRecipients(diffs: diffs);
    await _mailSpreadsheetUpdate(html, to: toTrainers, cc: []);
    AppEvents.fireSpreadsheetReady();
  }

  ///--------------------
  Future<LastRosterFinal?> getLastRosterFinal() async {
    return await Dbs.instance.getLastRosterFinal();
  }

  /// ============ private methods -----------------

  /// get trainer data
  Future<TrainerData> _getTheTrainerData(
      {String? trainerPk,
      Trainer? trainer,
      required bool forAllTrainers}) async {
    TrainerData result = TrainerData.empty();

    Trainer? useTrainer = (trainer == null && trainerPk != null)
        ? await Dbs.instance.getTrainerById(trainerPk)
        : trainer;

    result.trainer = useTrainer!;
    String schemaId = AppHelper.instance.buildTrainerSchemaId(useTrainer);

    TrainerSchema trainerSchemas =
        await Dbs.instance.getTrainerSchema(schemaId);

    if (!trainerSchemas.isEmpty()) {
      result.trainerSchemas = trainerSchemas;
    } else if (!forAllTrainers) {
      try {
        await _createNewTrainerSchema(useTrainer, result);
      } catch (ex) {
        log('ex $ex');
      }
    }
    return result;
  }

  /// ---------- get TrainerData for all trainers
  Future<List<TrainerData>> _getAllTrainerDataForThisSpreadsheet() async {
    List<Trainer> allTrainers = await Dbs.instance.getAllTrainers();

    List<TrainerData> allTrainerData = [];
    for (Trainer trainer in allTrainers) {
      TrainerData trainerData =
          await _getTheTrainerData(trainer: trainer, forAllTrainers: true);
      allTrainerData.add(trainerData);
    }

    AppData.instance.setAllTrainerData(allTrainerData);
    AppEvents.fireSpreadsheetReady();

    return allTrainerData;
  }

  ///------------------------------------------------
  Future<void> _createNewTrainerSchema(
      Trainer useTrainer, TrainerData result) async {
    TrainerSchema newTrainerSchemas =
        AppHelper.instance.buildNewSchemaForTrainer(useTrainer);

    bool updateOkay = await Dbs.instance
        .createOrUpdateTrainerSchemas(newTrainerSchemas, updateSchema: false);
    if (updateOkay) {
      result.trainerSchemas = newTrainerSchemas;
    }
  }

  //-------------------------------------------
  void _setDates() async {
    DateTime lastActiveDate = await _getLastActiveDate();

    DateTime nextMonth =
        lastActiveDate.copyWith(month: lastActiveDate.month + 1);

    setActiveDate(nextMonth);
    AppData.instance.lastActiveDate = lastActiveDate;

    // trainer may create 2 months ahead if where near the end the curr month (day=20), else 1 month ahead
    DateTime lastMonth = DateTime.now().day > 15
        ? AppHelper.instance.addMonths(lastActiveDate, 2)
        : AppHelper.instance.addMonths(lastActiveDate, 1);
    AppData.instance.lastMonth = lastMonth;
  }

  //-------------------------------------------
  Future<DateTime> _getLastActiveDate() async {
    DateTime lastActiveDate =
        DateTime(DateTime.now().year, DateTime.now().month, 1);

    LastRosterFinal? lastRosterFinal = await getLastRosterFinal();
    if (lastRosterFinal != null) {
      DateTime lrfDate =
          DateTime(lastRosterFinal.year, lastRosterFinal.month, 1);

      if (lrfDate.isAfter(lastActiveDate)) {
        lastActiveDate = lrfDate;
      }
    }
    return lastActiveDate;
  }

  //-------------------------------------------
  void _setScreenSizes(BuildContext context) {
    double width = (MediaQuery.of(context).size.width);
    AppData.instance.screenWidth = width;
    double height = (MediaQuery.of(context).size.height);
    AppData.instance.screenHeight = height;

    AppData.instance.shortestSide = MediaQuery.of(context).size.shortestSide;
  }

  //-------------------------------------
  Future<void> _mailSpreadsheetIsFinal(SpreadSheet spreadSheet) async {
    String html = _generateSpreadsheetIsFinalHtml(spreadSheet);
    List<Trainer> toTrainers = AppData.instance.getAllTrainers();
    toTrainers = [p.trainerRobin]; //todo

    bool okay = await Dbs.instance.sendEmail(
        toList: toTrainers,
        ccList: [],
        subject: 'Trainingschema definitief',
        html: html);

    if (okay) {
      log("email okay");
    } else {
      log("!email NOT  okay");
    }
  }

  //-------------------------------------
  Future<void> _mailSpreadsheetUpdate(String html,
      {required List<Trainer> to, required List<Trainer> cc}) async {
    bool okay = await Dbs.instance.sendEmail(
        toList: to,
        ccList: cc,
        subject: 'Trainingschema wijziging',
        html: html);

    if (okay) {
      log("email okay");
    } else {
      log("!email NOT  okay");
    }
  }

  //-------------------------------------------
  String _generateSpreadsheetIsFinalHtml(SpreadSheet spreadSheet) {
    String html = '<div>';
    html += 'Hallo <br><br>';
    String maand = AppHelper.instance
        .monthAsString(DateTime(spreadSheet.year, spreadSheet.month, 1));
    html += 'Het trainingschema voor $maand is nu definitief. <br>';
    html +=
        'Deze is zichtbaar op https://public-lonutrainingschemas.web.app <br>';
    html +=
        'Er kunnen nu geen verhinderingen meer in deze maand worden opgegeven. <br>';

    return '$html</div>';
  }

  //------------------------------------
  List<SpreedsheetDiff> _getSpreadsheetDiffs(
      {required FsSpreadsheet newSpreadsheet,
      required FsSpreadsheet oldSpreadsheet}) {
    List<SpreedsheetDiff> diffs = [];
    for (int r = 0; r < newSpreadsheet.rows.length; r++) {
      FsSpreadsheetRow newRow = newSpreadsheet.rows[r];
      FsSpreadsheetRow oldRow = oldSpreadsheet.rows[r];
      if (newRow.trainingText != oldRow.trainingText) {
        SpreedsheetDiff diff = SpreedsheetDiff(
            date: newRow.date,
            column: 'Training',
            oldValue: oldRow.trainingText,
            newValue: newRow.trainingText);
        diffs.add(diff);
      }
      for (int c = 0; c < newRow.rowCells.length; c++) {
        String newVal = newRow.rowCells[c];
        String oldVal = oldRow.rowCells[c];
        if (newVal != oldVal) {
          String column = Groep.values[c].name;
          SpreedsheetDiff diff = SpreedsheetDiff(
              date: newRow.date,
              column: column,
              oldValue: oldVal,
              newValue: newVal);
          diffs.add(diff);
        }
      }
    }

    return diffs;
  }

  //--------------------------------------
  String _getSpreadsheetDiffsAsHtml(
      {required List<SpreedsheetDiff> diffs,
      required SpreadSheet spreadSheet}) {
    String html = '<div>';
    html += 'Hallo <br><br>';
    String maand = AppHelper.instance
        .monthAsString(DateTime(spreadSheet.year, spreadSheet.month, 1));
    String by = AppData.instance.getTrainer().firstName();
    html += 'Het trainingschema voor $maand is aangepast door <b>$by</b> <br>';
    html += 'Wijzigingen : <br>';
    for (SpreedsheetDiff diff in diffs) {
      var formatter = DateFormat('EEEE dd MMMM', AppConstants().localNL);
      String dateStr = formatter.format(diff.date);
      html +=
          '$dateStr : <b>${diff.column.toUpperCase()}</b>,  van <b>"${diff.oldValue}"</b> naar <b>"${diff.newValue}"</b> <br>';
    }
    html +=
        '<br>Deze is zichtbaar op https://public-lonutrainingschemas.web.app <br>';

    return '$html</div>';
  }

  //--------------------------------------
  List<Trainer> _getSpreadsheetDiffsEmailRecipients(
      {required List<SpreedsheetDiff> diffs}) {
    List<Trainer> result = AppHelper.instance.getAllSupervisors();
    //plus the one who made the change
    result.add(AppData.instance.getTrainer());

    // plus all trainers that are affected
    for (SpreedsheetDiff diff in diffs) {
      Trainer trainer =
          AppHelper.instance.findTrainerByFirstName(diff.newValue);
      if (!trainer.isEmpty()) {
        result.add(trainer);
      }
    }
    return result;
  }
}

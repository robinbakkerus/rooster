// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:developer';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/authentication.dart';
import 'package:rooster/repo/firestore_helper.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_constants.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/spreadsheet_generator.dart';
import 'package:rooster/widget/busy_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooster/data/populate_data.dart' as p;

class AppController {
  AppHelper ah = AppHelper.instance;
  final Trainer administrator = p.trainerRobin;

  AppController._();

  static AppController instance = AppController._();

  /// get screen sizes and save this
  Future<void> initializeAppData(BuildContext context) async {
    _setScreenSizes(context);
    _setDates();
    await initializeDateFormatting('nl_NL', null);
  }

  /// find the trainer given the access code
  Future<bool> findTrainer(String accessCode) async {
    Trainer trainer = await Dbs.instance.findTrainerByAccessCode(accessCode);
    if (trainer.isEmpty()) {
      return false;
    }

    bool signInOkay;
    try {
      signInOkay = await AuthHelper.instance.signIn(
        email: trainer.originalEmail,
        password: AppHelper.instance.getAuthPassword(trainer),
      );
    } catch (ex, stackTrace) {
      FirestoreHelper.instance.handleError(ex, stackTrace);
      signInOkay = false;
    }

    if (signInOkay) {
      _setAccessCodePrefIfNeeded(trainer, accessCode);
      _setDates();
      AppEvents.fireTrainerReady();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _setAccessCodePrefIfNeeded(
      Trainer trainer, String accessCode) async {
    if (!trainer.isEmpty()) {
      getTrainerData(trainer: trainer);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('ac', trainer.accessCode);
      return true;
    } else {
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

  // get TrainingGroups
  Future<void> getTrainerGroups() async {
    AppData.instance.trainingGroups = await Dbs.instance.getTrainingGroups();

    //fill excludePeriods
    for (TrainingGroup trainingGroup in AppData.instance.trainingGroups) {
      if (trainingGroup.name.toLowerCase() == Groep.zomer.name.toLowerCase()) {
        trainingGroup.setStartDate(AppData.instance.getSummerPeriod().fromDate);
        trainingGroup.setEndDate(AppData.instance.getSummerPeriod().toDate);
      } else {
        trainingGroup.setStartDate(DateTime(2025, 1, 1));
        trainingGroup.setEndDate(DateTime(2099, 1, 1));
        trainingGroup.setSummerPeriod(AppData.instance.getSummerPeriod());
      }

      if (trainingGroup.name.toLowerCase() == Groep.zamo.name.toLowerCase()) {
        trainingGroup.setSummerPeriod(SpecialPeriod.empty());
      }

      if (trainingGroup.name.toLowerCase() == Groep.sg.name.toLowerCase()) {
        SpecialPeriod startgroup = AppData.instance.specialDays.startersGroup;
        trainingGroup.setStartDate(startgroup.fromDate);
        trainingGroup.setEndDate(startgroup.toDate);
      }
    }

    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();
  }

  // get Zamo trainers
  Future<void> getPlanRankValues() async {
    MetaPlanRankValues applyWeightValues =
        await Dbs.instance.getApplyPlanRankValues();
    AppData.instance.planRankValues = applyWeightValues;
  }

  Future<void> getSpecialDays() async {
    SpecialDays specialDays = await Dbs.instance.getSpecialsDays();
    AppData.instance.specialDays = specialDays;
  }

  Future<void> saveSpecialDays(SpecialDays specialDays) async {
    await Dbs.instance.saveSpecialDays(specialDays);
    AppData.instance.specialDays = specialDays;
  }

  // get trainer_items (to fill combobox)
  Future<void> getTrainingItems() async {
    List<String> trainerItems = await Dbs.instance.getTrainingItems();
    AppData.instance.trainerItems = trainerItems;
  }

  /// update all modified DaySchema's
  Future<bool> updateTrainerSchemas() async {
    TrainerSchema trainerSchemas =
        AppData.instance.getTrainerData().trainerSchemas;
    trainerSchemas.availableList = AppData.instance.newAvailaibleList;
    bool result = await Dbs.instance
        .createOrUpdateTrainerSchemas(trainerSchemas, updateSchema: true);
    getTrainerData(trainer: AppData.instance.getTrainer());
    return result;
  }

  ///----- updateTrainer via trainer_prefs_page
  Future<bool> updateTrainer(Trainer trainer) async {
    Trainer updatedTrainer = await Dbs.instance.createOrUpdateTrainer(trainer);
    AppData.instance.setTrainer(updatedTrainer);
    AppEvents.fireTrainerUpdated(updatedTrainer);
    return true;
  }

  Future<bool> updateTrainerBySupervisor(Trainer trainer) async {
    await Dbs.instance.createOrUpdateTrainer(trainer);
    await getAllTrainerData();
    AppEvents.fireTrainerDataReady();

    final html = '''
  <div>Trainer ${trainer.fullname} aangepast of toegevoegd.</div>
''';
    Dbs.instance.sendEmail(
        toList: [administrator],
        ccList: [],
        subject: 'Trainer updated',
        html: html);
    return true;
  }

  ///----- updateTrainer
  Future<bool> deleteTrainer(Trainer trainer) async {
    await Dbs.instance.deleteTrainer(trainer);
    await getAllTrainerData();

    final html = '''
  <div>Trainer ${trainer.fullname} verwijderd.</div>
''';
    Dbs.instance.sendEmail(
        toList: [administrator],
        ccList: [],
        subject: 'Trainer updated',
        html: html);

    AppEvents.fireTrainerDataReady();
    return true;
  }

  ///----------------------------
  void setActiveDate(DateTime date) {
    AppData.instance.setActiveDate(date);
    AppEvents.fireDatesReady();
  }

  ///---------------------------------------
  Future<SpreadSheet> generateOrRetrieveSpreadsheet() async {
    LoadingIndicatorDialog().show();
    SpreadSheet result;

    await _getAllTrainerDataForThisSpreadsheet();

    SpreadSheet? spreadSheet = await _getTheActiveSpreadsheet();
    if (spreadSheet != null) {
      result = spreadSheet;
    } else {
      result = _generateTheSpreadsheet();
    }

    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();
    AppData.instance.setSpreadsheet(result);
    AppEvents.fireSpreadsheetReady();
    return result;
  }

  ///---------------------------------------
  /// triggered via Supervisor admin page
  Future<void> regenerateSpreadsheet() async {
    LoadingIndicatorDialog().show();
    SpreadSheet? activeSpreadsheet;
    SpreadSheet updatedSpreadsheet;

    await _getAllTrainerDataForThisSpreadsheet();

    activeSpreadsheet = await _getTheActiveSpreadsheet();

    updatedSpreadsheet = _generateTheSpreadsheet();

    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();

    // copy training text
    if (activeSpreadsheet != null) {
      for (SheetRow row in activeSpreadsheet.rows) {
        SheetRow? resultRow = _findCorrRow(row, updatedSpreadsheet);
        if (resultRow != null) {
          resultRow.trainingText = row.trainingText;
        } else {
          updatedSpreadsheet.rows.add(row);
        }
      }
    }

    AppData.instance.setSpreadsheet(updatedSpreadsheet);
    AppEvents.fireSpreadsheetReady();
    return;
  }

  ///------------------------------------
  SheetRow? _findCorrRow(SheetRow row, SpreadSheet result) {
    return result.rows.firstWhereOrNull(
        (e) => e.date.day == row.date.day && e.isExtraRow == row.isExtraRow);
  }

  ///------------------------------------------------
  SpreadSheet _generateTheSpreadsheet() {
    SpreadSheet spreadSheet = SpreadsheetGenerator.instance
        .generateSpreadsheet(AppData.instance.getActiveDate());
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
    spreadSheet.status = fsSpreadsheet.isFinal
        ? SpreadsheetStatus.active
        : SpreadsheetStatus.underConstruction;

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
        Available available = _getAvailable(availableList, row.date);
        if (available.counts.length > c) {
          cell.availableCounts = available.counts[c];
        } else {
          cell.availableCounts = AvailableCounts();
        }
        row.rowCells.add(cell);
      }

      spreadSheet.rows.add(row);
    }
    return spreadSheet;
  }

  ///---------------------------------------------------------
  /// Return the 'Available' object. We look this up in the given list and date.
  /// If no such Available can be found, an Available with an empty countList
  /// is returned, with a length of active groupnames

  Available _getAvailable(List<Available> availableList, DateTime date) {
    Available? result = availableList.firstWhereOrNull((e) => e.date == date);
    int count = SpreadsheetGenerator.instance.getGroupNames(date).length;
    return result ?? Available(date: date, groupCount: count);
  }

  ///--------------------
  void finalizeSpreadsheet(SpreadSheet spreadSheet) async {
    FsSpreadsheet fsSpreadsheet =
        SpreadsheetGenerator.instance.mapFsSpreadsheetFrom(spreadSheet);
    fsSpreadsheet.isFinal = true;
    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
    await Dbs.instance.saveLastRosterFinal();
    await _mailSpreadsheetIsFinal(spreadSheet);
  }

  ///--------------------
  Future<void> updateSpreadsheet(SpreadSheet spreadSheet) async {
    FsSpreadsheet fsSpreadsheet =
        SpreadsheetGenerator.instance.mapFsSpreadsheetFrom(spreadSheet);

    if (fsSpreadsheet.isFinal) {
      await _mailSpreadsheetDiffs(fsSpreadsheet, spreadSheet);
    }

    await Dbs.instance.saveFsSpreadsheet(fsSpreadsheet);
    await generateOrRetrieveSpreadsheet();
    AppEvents.fireSpreadsheetReady();
  }

  ///--------------------
  Future<void> _mailSpreadsheetDiffs(
      FsSpreadsheet fsSpreadsheet, SpreadSheet spreadSheet) async {
    FsSpreadsheet oldFsSpreadsheet = SpreadsheetGenerator.instance
        .mapFsSpreadsheetFrom(AppData.instance.getOriginalpreadsheet());
    List<SpreedsheetDiff> diffs = _getSpreadsheetDiffs(
        newSpreadsheet: fsSpreadsheet, oldSpreadsheet: oldFsSpreadsheet);
    String html =
        _getSpreadsheetDiffsAsHtml(diffs: diffs, spreadSheet: spreadSheet);

    List<Trainer> toTrainers =
        _getSpreadsheetDiffsEmailRecipients(diffs: diffs);
    await _mailSpreadsheetUpdate(html, to: toTrainers, cc: []);
  }

  ///--------------------
  Future<LastRosterFinal?> getLastRosterFinal() async {
    return await Dbs.instance.getLastRosterFinal();
  }

  Future<bool> importTrainerData(String jsonText) async {
    try {
      Map<String, dynamic> map = json.decode(jsonText);
      List<Map<String, dynamic>> trainersMapList =
          (map["trainers"] as List).cast<Map<String, dynamic>>();

      List<Map<String, dynamic>> importSchemasMapList =
          _prepareImportSchemas(map);

      await Dbs.instance
          .importTrainerData(trainersMapList, importSchemasMapList);

      await generateOrRetrieveSpreadsheet();
      return true;
    } catch (ex, stackTrace) {
      FirestoreHelper.instance.handleError(ex, stackTrace);
      return false;
    }
  }

  List<Map<String, dynamic>> _prepareImportSchemas(Map<String, dynamic> map) {
    List<Map<String, dynamic>> schemasMapList =
        (map["schemas"] as List).cast<Map<String, dynamic>>();
    List<Map<String, dynamic>> importSchemasMapList = [];
    for (Map<String, dynamic> schemaMap in schemasMapList) {
      if (schemaMap["trainerPk"] != null &&
          schemaMap["trainerPk"].toString().isNotEmpty) {
        String schemaId = ah.buildTrainerSchemaIdFromMap(schemaMap);
        schemaMap["id"] = schemaId;
        importSchemasMapList.add(schemaMap);
      }
    }
    return importSchemasMapList;
  }

  /// ============ private methods -----------------

  /// get trainer data
  Future<TrainerData> _getTheTrainerData(
      {String? trainerPk,
      Trainer? trainer,
      required bool forAllTrainers}) async {
    TrainerData result = TrainerData.empty();

    Trainer? useTrainer = (trainer == null && trainerPk != null)
        ? await Dbs.instance.getTrainerByPk(trainerPk)
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
      } catch (ex, stackTrace) {
        FirestoreHelper.instance.handleError(ex, stackTrace);
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

    return allTrainerData;
  }

  /// ---------- get TrainerData for all trainers
  Future<List<TrainerData>> getAllTrainerData() async {
    List<Trainer> allTrainers = await Dbs.instance.getAllTrainers();

    List<TrainerData> allTrainerData = [];
    for (Trainer trainer in allTrainers) {
      TrainerData trainerData =
          await _getTheTrainerData(trainer: trainer, forAllTrainers: true);
      allTrainerData.add(trainerData);
    }

    AppData.instance.setAllTrainerData(allTrainerData);

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

    // trainer may create 2 months ahead if we are near the end the curr month (day=20), else 1 month ahead
    // admin and hoofdtrainer may create 5 months ahead.
    if (AppData.instance.getTrainer().isSupervisor()) {
      DateTime lastMonth = DateTime.now().day > 15
          ? AppHelper.instance.addMonths(lastActiveDate, 6)
          : AppHelper.instance.addMonths(lastActiveDate, 5);
      AppData.instance.lastMonth = lastMonth;
    } else {
      DateTime lastMonth = DateTime.now().day > 15
          ? AppHelper.instance.addMonths(lastActiveDate, 2)
          : AppHelper.instance.addMonths(lastActiveDate, 1);
      AppData.instance.lastMonth = lastMonth;
    }
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
    for (Trainer trainer in AppData.instance.getAllTrainers()) {
      String html = _generateSpreadsheetIsFinalHtml(spreadSheet, trainer);
      List<Trainer> toList = [trainer];
      await Dbs.instance.sendEmail(
          toList: toList,
          ccList: [],
          subject: 'Trainingschema definitief',
          html: html);
    }
  }

  //-------------------------------------
  Future<void> _mailSpreadsheetUpdate(String html,
      {required List<Trainer> to, required List<Trainer> cc}) async {
    await Dbs.instance.sendEmail(
        toList: to,
        ccList: cc,
        subject: 'Trainingschema wijziging',
        html: html);
  }

  //-------------------------------------------
  String _generateSpreadsheetIsFinalHtml(
      SpreadSheet spreadSheet, Trainer trainer) {
    String html = '<div>';
    html += 'Hallo ${trainer.firstName()}<br><br>';
    String maand = AppHelper.instance
        .monthAsString(DateTime(spreadSheet.year, spreadSheet.month, 1));
    html += 'Het trainingschema voor $maand is nu definitief. <br>';
    html +=
        'Deze is zichtbaar op https://public-lonutrainingschemas.web.app <br>';
    html +=
        'Er kunnen nu geen verhinderingen meer in deze maand worden opgegeven. <br><br>';
    html += 'Je bent ingedeeld op de volgende dagen: <br>';
    html += _generateWhenClassifiedHtml(spreadSheet, trainer);

    return '$html</div>';
  }

  //-------------------------------------------
  String _generateWhenClassifiedHtml(SpreadSheet spreadSheet, Trainer trainer) {
    String html = '';
    for (SheetRow row in spreadSheet.rows) {
      for (RowCell cell in row.rowCells) {
        if (cell.text == trainer.firstName()) {
          String dag = AppHelper.instance.weekDayStringFromDate(
              date: row.date, locale: AppConstants().localNL);
          html += '$dag<br>';
        }
      }
    }
    return html;
  }

  //------------------------------------
  List<SpreedsheetDiff> _getSpreadsheetDiffs(
      {required FsSpreadsheet newSpreadsheet,
      required FsSpreadsheet oldSpreadsheet}) {
    List<SpreedsheetDiff> diffs = [];
    for (FsSpreadsheetRow oldRow in oldSpreadsheet.rows) {
      FsSpreadsheetRow? newRow = _getCorrSpreadsheetRow(oldRow, newSpreadsheet);
      if (newRow == null) {
        SpreedsheetDiff diff = SpreedsheetDiff(
            date: oldRow.date,
            column: 'column',
            oldValue: oldRow.trainingText,
            newValue: 'verwijderd');
        diffs.add(diff);
      } else {
        _buildDiff(newRow, oldRow, diffs);
      }
    }

    return diffs;
  }

  void _buildDiff(FsSpreadsheetRow newRow, FsSpreadsheetRow oldRow,
      List<SpreedsheetDiff> diffs) {
    if (newRow.trainingText != oldRow.trainingText) {
      SpreedsheetDiff diff = SpreedsheetDiff(
          date: newRow.date,
          column: 'Training',
          oldValue: oldRow.trainingText,
          newValue: newRow.trainingText);
      diffs.add(diff);
    }

    for (int c = 0; c < newRow.rowCells.length; c++) {
      List<String> groupNames =
          SpreadsheetGenerator.instance.getGroupNames(newRow.date);

      String newVal = newRow.rowCells[c];
      if (oldRow.rowCells.length > c) {
        String oldVal = oldRow.rowCells[c];
        if (newVal != oldVal) {
          String column = groupNames[c];
          SpreedsheetDiff diff = SpreedsheetDiff(
              date: newRow.date,
              column: column,
              oldValue: oldVal,
              newValue: newVal);
          diffs.add(diff);
        }
      }
    }
  }

  //------------------------------------
  FsSpreadsheetRow? _getCorrSpreadsheetRow(
      FsSpreadsheetRow oldRow, FsSpreadsheet newSpreadsheet) {
    return newSpreadsheet.rows.firstWhereOrNull(
        (e) => e.date == oldRow.date && e.isExtraRow == oldRow.isExtraRow);
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
    List<Trainer> trainerList = AppHelper.instance.getAllSupervisors();
    //plus the one who made the change
    trainerList.add(AppData.instance.getTrainer());

    // plus all trainers that are affected
    for (SpreedsheetDiff diff in diffs) {
      Trainer newTrainer =
          AppHelper.instance.findTrainerByFirstName(diff.newValue);
      if (!newTrainer.isEmpty()) {
        trainerList.add(newTrainer);
      }

      Trainer oldTrainer =
          AppHelper.instance.findTrainerByFirstName(diff.oldValue);
      if (!newTrainer.isEmpty()) {
        trainerList.add(oldTrainer);
      }
    }

    //remove duplicates
    List<Trainer> result = [];
    for (Trainer trainer in trainerList) {
      if (!result.contains(trainer)) {
        result.add(trainer);
      }
    }
    return result;
  }
}

// ignore_for_file: depend_on_referenced_packages

// import 'dart:developer' as dev;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';

class SpreadsheetGenerator with AppMixin {
  SpreadSheet _spreadSheet = SpreadSheet(
      year: AppData.instance.getActiveYear(),
      month: AppData.instance.getActiveMonth());

  SpreadsheetGenerator._();

  static SpreadsheetGenerator instance = SpreadsheetGenerator._();

  //-------------
  //
  TrainerSchema getSchemaFromAllTrainerData(Trainer trainer) {
    TrainerData? trainerData = AppData.instance
        .getAllTrainerData()
        .firstWhereOrNull((e) => e.trainer.pk == trainer.pk);

    return trainerData!.trainerSchemas;
  }

  //-------------
  //
  List<Trainer> _getTrainersForGroup(String groupName) {
    return AppData.instance
        .getAllTrainers()
        .where((trainer) => _availableForGroep(trainer, groupName))
        .toList();
  }

  bool _availableForGroep(Trainer trainer, String groupName) {
    return trainer.getPrefValue(paramName: groupName) > 0;
  }

  //-------------------------------
  List<Available> generateAvailableTrainersCounts() {
    List<Available> result = [];

    for (int i = 0; i < AppData.instance.getActiveDates().length; i++) {
      DateTime date = AppData.instance.getActiveDates()[i];
      result.add(_genCountsProcessDate(i, date));
    }

    return result;
  }

  //------------------------------------------
  SpreadSheet generateSpreadsheet(
      List<Available> availableList, DateTime date) {
    _spreadSheet = SpreadSheet(
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth());

    // first fill the spreadsheet with available trainer data
    List<SheetRow> sheetRows = _getAvailabilityForSpreadsheet(availableList);
    _spreadSheet.rows = sheetRows;

    // next find the best trainer, first we skip zamo
    for (int rowNr = 0; rowNr < _spreadSheet.rows.length; rowNr++) {
      for (String groupName
          in SpreadsheetGenerator.instance.getGroupNames(date)) {
        _findSuitableTrainer(rowNr: rowNr, groupName: groupName, date: date);
      }
    }
    for (int rowNr = 0; rowNr < _spreadSheet.rows.length; rowNr++) {
      if (_isSaturday(rowNr)) {
        _findSuitableZamoTrainer(rowNr: rowNr);
      }
    }

    postProcessSpreadsheet();
    return _spreadSheet;
  }

  //----------------
  FsSpreadsheet mapFsSpreadsheetFrom(SpreadSheet spreadSheet) {
    List<FsSpreadsheetRow> fsRows = [];
    for (SheetRow sheetRow in spreadSheet.rows) {
      fsRows.add(_mapFromRow(sheetRow));
    }

    FsSpreadsheet result = FsSpreadsheet(
        year: spreadSheet.year,
        month: spreadSheet.month,
        rows: fsRows,
        isFinal: spreadSheet.isFinal);

    return result;
  }

  FsSpreadsheetRow _mapFromRow(SheetRow sheetRow) {
    List<String> fsCells = [];
    for (RowCell cell in sheetRow.rowCells) {
      fsCells.add(cell.text);
    }

    return FsSpreadsheetRow(
        date: sheetRow.date,
        isExtraRow: sheetRow.isExtraRow,
        trainingText: sheetRow.trainingText,
        rowCells: fsCells);
  }

  //-------------
  List<ActiveTrainingGroup> generateActiveTrainingGroups() {
    List<ActiveTrainingGroup> result = [];

    ActiveTrainingGroup activeTrainingGroup = ActiveTrainingGroup(
        startDate: AppData.instance.getActiveDates().first, groupNames: []);

    for (DateTime date in AppData.instance.getActiveDates()) {
      List<String> names = getGroupNames(date);
      if (listEquals(names, activeTrainingGroup.groupNames)) {
        activeTrainingGroup.endDate = date;
      } else {
        activeTrainingGroup =
            ActiveTrainingGroup(startDate: date, groupNames: names);
        activeTrainingGroup.endDate = date;
        result.add(activeTrainingGroup);
      }
    }

    return result;
  }

  ///-------------
  /// returns a list of group names for the given date
  List<String> getGroupNames(DateTime date) {
    List<String> result = [];
    for (TrainingGroup trainingGroup in AppData.instance.trainingGroups) {
      if (trainingGroup.startDate.isBefore(date) &&
          trainingGroup.endDate.isAfter(date) &&
          !_isExcluded(trainingGroup, date)) {
        result.add(trainingGroup.name);
      }
    }
    return result;
  }

  //--------------------------------
  int getGroupIndex(String groupName, DateTime dateTime) {
    List<String> getGroupNames =
        SpreadsheetGenerator.instance.getGroupNames(dateTime);
    for (int i = 0; i < getGroupNames.length; i++) {
      if (getGroupNames[i].toLowerCase() == groupName.toLowerCase()) {
        return i;
      }
    }
    return -1; // should not happen
  }

  //---- private --

  bool _isExcluded(TrainingGroup trainingGroup, DateTime date) {
    return trainingGroup.excludeDays.contains(date);
  }

  //------------- first fill the spreadsheet with available trainer data
  List<SheetRow> _getAvailabilityForSpreadsheet(List<Available> availableList) {
    List<SheetRow> result = [];
    int rowIdx = 0;
    for (Available avail in availableList) {
      SheetRow sheetRow =
          SheetRow(date: avail.date, rowIndex: rowIdx, isExtraRow: false);
      for (String groupName in getGroupNames(avail.date)) {
        int groupIndex = getGroupIndex(groupName, avail.date);
        RowCell rowCell = RowCell(rowIndex: rowIdx, colIndex: groupIndex);
        rowCell.availableCounts = avail.counts[groupIndex];
        sheetRow.rowCells.add(rowCell);
      }
      result.add(sheetRow);

      rowIdx++;
    }

    return result;
  }

  //--- here we fill which trainers are (not) available.
  Available _genCountsProcessDate(int dateIndex, DateTime date) {
    List<String> groupNames = getGroupNames(date);
    Available available = Available(date: date, groupCount: groupNames.length);

    for (String groepName in groupNames) {
      AvailableCounts availableCounts = AvailableCounts();

      for (Trainer trainer in _getTrainersForGroup(groepName)) {
        TrainerSchema trainerSchema = getSchemaFromAllTrainerData(trainer);

        int groupPref = trainer.getPrefValue(paramName: groepName);
        int dayPref = trainer.getDayPrefValue(weekday: date.weekday);

        if (trainerSchema.isEmpty()) {
          _genCountsEmptySchema(groupPref, dayPref, availableCounts, trainer);
        } else {
          _genCountsForEnteredSchema(
              trainerSchema, dateIndex, availableCounts, trainer, groupPref);
        }
      }

      available.counts.add(availableCounts);
    }

    return available;
  }

  void _genCountsEmptySchema(int groupPref, int dayPref,
      AvailableCounts availableCounts, Trainer trainer) {
    if (groupPref == 2 || dayPref == 2) {
      availableCounts.ifNeededBnye.add(trainer);
    } else if (groupPref == 1 && dayPref == 1) {
      availableCounts.availableBnye.add(trainer);
    } else {
      availableCounts.notAvailableBnye.add(trainer);
    }
  }

  void _genCountsForEnteredSchema(TrainerSchema trainerSchema, int dateIndex,
      AvailableCounts availableCounts, Trainer trainer, int groupPref) {
    if (trainerSchema.availableList.length >= dateIndex &&
        trainerSchema.availableList[dateIndex] == 0) {
      availableCounts.notAvailable.add(trainer);
    } else if (trainerSchema.availableList.length >= dateIndex &&
        trainerSchema.availableList[dateIndex] == 1) {
      if (groupPref == 2) {
        availableCounts.ifNeeded.add(trainer);
      } else {
        availableCounts.available.add(trainer);
      }
    } else if (trainerSchema.availableList.length >= dateIndex &&
        trainerSchema.availableList[dateIndex] == 2) {
      availableCounts.ifNeeded.add(trainer);
    }
  }

  ///---------------
  void _findSuitableTrainer(
      {required int rowNr, required String groupName, required DateTime date}) {
    int groupIndex = getGroupIndex(groupName, date);
    if (_spreadSheet.rows[rowNr].rowCells.length > groupIndex) {
      AvailableCounts cnts =
          _spreadSheet.rows[rowNr].rowCells[groupIndex].availableCounts;

      List<TrainerPlanningRank> possibleTrainerRanks =
          _getPossibleTrainers(cnts, isZamo: false);

      _applyRanks(possibleTrainerRanks,
          rowNr: rowNr, groepName: groupName, groepNr: groupIndex);

      bool setTrainer = true; //assume
      if (_isThursdayAndPR(rowNr, groupName) ||
          (_isSaturday(rowNr) && !_isSaturdayAndZamo(rowNr, groupName))) {
        setTrainer = false;
      }

      if (setTrainer) {
        Trainer trainer = _getTrainerFromPossibleList(possibleTrainerRanks,
            rowNr: rowNr, groepNr: groupIndex);
        _spreadSheet.rows[rowNr].rowCells[groupIndex].setTrainer(trainer);
      }
    }
  }

  ///---------------
  void _findSuitableZamoTrainer({required int rowNr}) {
    int zamoIndex = getGroupIndex(c.zamoGroup, _spreadSheet.rows[rowNr].date);
    AvailableCounts cnts =
        _spreadSheet.rows[rowNr].rowCells[zamoIndex].availableCounts;

    List<TrainerPlanningRank> possibleTrainerRanks =
        _getPossibleTrainers(cnts, isZamo: true);

    _applyZamoRanks(possibleTrainerRanks, rowNr: rowNr);

    Trainer trainer = _getTrainerFromPossibleList(possibleTrainerRanks,
        rowNr: rowNr, groepNr: zamoIndex);
    _spreadSheet.rows[rowNr].rowCells[zamoIndex].setTrainer(trainer);
  }

//-----------------------
  List<TrainerPlanningRank> _getPossibleTrainers(AvailableCounts cnts,
      {required bool isZamo}) {
    List<TrainerPlanningRank> result = [];

    List<Trainer> trainerList = [];
    trainerList.addAll(cnts.available);
    trainerList.addAll(cnts.availableBnye);
    for (Trainer trainer in trainerList) {
      double rank = _getStartRank(trainer: trainer, isZamo: isZamo);
      result.add(TrainerPlanningRank(trainer: trainer, rank: rank));
    }

    trainerList = [];
    trainerList.addAll(cnts.ifNeeded);
    trainerList.addAll(cnts.ifNeededBnye);
    for (Trainer trainer in trainerList) {
      double rank = _getStartRank(trainer: trainer, isZamo: isZamo) +
          AppData.instance.planRankValues.onlyIfNeeded;
      result.add(TrainerPlanningRank(trainer: trainer, rank: rank));
    }

    return result;
  }

  double _getStartRank({required Trainer trainer, required bool isZamo}) {
    PlanRankStartValue? startVal = isZamo
        ? AppData.instance.planRankValues.startValues
            .firstWhereOrNull((e) => e.trainerPk == trainer.pk)
        : AppData.instance.planRankValues.zamoStartValues
            .firstWhereOrNull((e) => e.trainerPk == trainer.pk);

    if (startVal != null) {
      return startVal.value;
    } else {
      PlanRankStartValue? startVal = AppData.instance.planRankValues.startValues
          .firstWhereOrNull((e) => e.trainerPk == '*');
      if (startVal != null) {
        return startVal.value;
      } else {
        return 100.0; //we should never come here
      }
    }
  }

  ///-------------------------
  ///
  Trainer _getTrainerFromPossibleList(
      List<TrainerPlanningRank> possibleTrainers,
      {required int rowNr,
      required int groepNr}) {
    possibleTrainers = _removeAlreadyScheduled(possibleTrainers, rowNr: rowNr);
    if (possibleTrainers.length == 1) {
      return possibleTrainers.last.trainer;
    } else if (possibleTrainers.length > 1) {
      possibleTrainers.sort((a, b) => b.rank.compareTo(a.rank));
      double rank = possibleTrainers.first.rank;
      List<TrainerPlanningRank> sortedTrainers =
          possibleTrainers.where((e) => e.rank == rank).toList();
      if (sortedTrainers.length == 1) {
        return sortedTrainers.first.trainer;
      } else {
        int randomNumber = Random().nextInt(sortedTrainers.length);
        return sortedTrainers[randomNumber].trainer;
      }
    } else {
      return Trainer.empty();
    }
  }

  List<TrainerPlanningRank> _removeAlreadyScheduled(
      List<TrainerPlanningRank> possibleTrainers,
      {required int rowNr}) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    List<TrainerPlanningRank> result = [];

    for (TrainerPlanningRank tw in possibleTrainers) {
      if (!_alreadyScheduledThisDay(tw.trainer, sheetRow)) {
        result.add(tw);
      }
    }
    return result;
  }

  bool _alreadyScheduledThisDay(Trainer trainer, SheetRow sheetRow) {
    for (RowCell rowCell in sheetRow.rowCells) {
      if (rowCell.getTrainer() == trainer) {
        return true;
      }
    }
    return false;
  }

  // here we make the rank higher or lower in order to make choice
  void _applyRanks(List<TrainerPlanningRank> trainerPlanRankList,
      {required int rowNr, required String groepName, required int groepNr}) {
    if (!_isSaturday(rowNr) && !_isThursdayAndPR(rowNr, groepName)) {
      _applyOnlyIfNeeded(trainerPlanRankList,
          rowNr: rowNr, groepName: groepName);
      _applyDaysNotAvailable(trainerPlanRankList,
          rowNr: rowNr, groepNr: groepNr);
      _applyAlreadyScheduled(trainerPlanRankList,
          rowNr: rowNr, groupName: groepName);
    }
  }

  void _applyZamoRanks(List<TrainerPlanningRank> trainerPlanRankList,
      {required int rowNr}) {
    int zamoIndex = getGroupIndex(c.zamoGroup, _spreadSheet.rows[rowNr].date);
    _applyDaysNotAvailable(trainerPlanRankList,
        rowNr: rowNr, groepNr: zamoIndex);
    _applyAlreadyZamoScheduled(trainerPlanRankList, rowNr: rowNr);
  }

  // if trainer is not available future days its score goes up
  void _applyOnlyIfNeeded(List<TrainerPlanningRank> trainerPlanRankList,
      {required int rowNr, required String groepName}) {
    for (TrainerPlanningRank tw in trainerPlanRankList) {
      Trainer trainer = tw.trainer;
      if (_isOnlyIfNeeded(trainer, groepName)) {
        tw.rank += AppData.instance.planRankValues.onlyIfNeeded;
      }
    }
  }

  bool _isOnlyIfNeeded(Trainer trainer, String groupName) {
    return trainer.getPrefValue(paramName: groupName) == 2;
  }

  // if trainer is not available future days its score goes up
  void _applyDaysNotAvailable(List<TrainerPlanningRank> trainerPlanRankList,
      {required int rowNr, required int groepNr}) {
    for (TrainerPlanningRank tw in trainerPlanRankList) {
      Trainer trainer = tw.trainer;
      int notAvailCnt =
          _countDaysNotAvalaible(trainer, rowNr: rowNr, groupIndex: groepNr);

      if (notAvailCnt > 0) {
        tw.rank += (notAvailCnt * 10);
      }
    }
  }

// if trainer is already scheduled before its score goes down
  void _applyAlreadyScheduled(List<TrainerPlanningRank> trainerPlanRankList,
      {required int rowNr, required String groupName}) {
    for (TrainerPlanningRank tw in trainerPlanRankList) {
      Trainer trainer = tw.trainer;
      double applyRank = _getRankForAlreadyScheduledDays(trainer,
          rowNr: rowNr, groupName: groupName);
      tw.rank += applyRank;
    }
  }

  void _applyAlreadyZamoScheduled(List<TrainerPlanningRank> trainerPlanRankList,
      {required int rowNr}) {
    for (TrainerPlanningRank tw in trainerPlanRankList) {
      Trainer trainer = tw.trainer;

      double result = 0.0;
      int countDays = 1;
      List<double> values = AppData.instance.planRankValues.alreadyScheduled;

      for (int prevRowNr = rowNr - 1; prevRowNr >= 0; prevRowNr--) {
        for (RowCell rowCell in _spreadSheet.rows[prevRowNr].rowCells) {
          if (_isSaturday(prevRowNr)) {
            Trainer schedTrainer = rowCell.getTrainer();
            if (schedTrainer == trainer) {
              int idx = countDays > values.length - 1 ? 0 : countDays;
              result += values[idx];
            }
          }
        }
        countDays++;
      }

      tw.rank += result;
    }
  }

  // String _getWeekdayStr(int rowNr) {
  //   SheetRow sheetRow = _spreadSheet.rows[rowNr];
  //   return DateFormat.EEEE(c.localNL).format(sheetRow.date);
  // }

  bool _isSaturday(int rowNr) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.saturday;
  }

  bool _isThursdayAndPR(int rowNr, String groupName) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.thursday &&
        groupName.toLowerCase() == 'pr';
  }

  bool _isSaturdayAndZamo(int rowNr, String groupName) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.saturday &&
        groupName == c.zamoGroup;
  }

  // hoe vaak afwezig vanaf dateTime
  int _countDaysNotAvalaible(Trainer trainer,
      {required int rowNr, required int groupIndex}) {
    int result = 0;

    DateTime dateTime = _spreadSheet.rows[rowNr].date;

    for (SheetRow sheetRow in _spreadSheet.rows) {
      if (sheetRow.date.isAfter(dateTime) &&
          sheetRow.date.weekday != DateTime.saturday) {
        if (sheetRow.rowCells.length > groupIndex) {
          List<Trainer> allTrainers =
              sheetRow.rowCells[groupIndex].availableCounts.getAllTrainers();
          if (!allTrainers.contains(trainer)) {
            result++;
          }
        }
      }
    }

    return result;
  }

  // how often scheduled in the days before
  double _getRankForAlreadyScheduledDays(Trainer trainer,
      {required int rowNr, required String groupName}) {
    double result = 0.0;

    if (_isSaturday(rowNr)) {
      return result;
    }

    int countDays = 1;
    List<double> values = AppData.instance.planRankValues.alreadyScheduled;
    for (int prevRowNr = rowNr - 1; prevRowNr >= 0; prevRowNr--) {
      for (RowCell rowCell in _spreadSheet.rows[prevRowNr].rowCells) {
        if (!_isSaturday(prevRowNr) &&
            !_isThursdayAndPR(prevRowNr, groupName)) {
          Trainer schedTrainer = rowCell.getTrainer();
          if (schedTrainer == trainer) {
            int idx = countDays > values.length - 1 ? 0 : countDays;
            double w = values[idx];
            result += w;
          }
        }
      }
      countDays++;
    }

    return result;
  }

  void postProcessSpreadsheet() {
    postProcessZamo();
    postProcessThursdayPR();
  }

  void postProcessZamo() {
    for (SheetRow sheetRow in _spreadSheet.rows) {
      int zamoIndex = getGroupIndex(c.zamoGroup, sheetRow.date);
      if (sheetRow.date.weekday == DateTime.saturday) {
        sheetRow.trainingText = AppData.instance.zamoDefaultTraing;

        String zamoTrainer = sheetRow.rowCells[zamoIndex].text;
        for (int i = 0; i < getGroupNames(sheetRow.date).length; i++) {
          sheetRow.rowCells[i].text = '';
        }
        sheetRow.rowCells[zamoIndex].text = zamoTrainer;
      } else {
        sheetRow.rowCells[zamoIndex].setTrainer(Trainer.empty());
      }
    }
  }

  void postProcessThursdayPR() {
    for (SheetRow sheetRow in _spreadSheet.rows) {
      if (sheetRow.date.weekday == DateTime.thursday) {
        int prIndex = getGroupIndex('pr', sheetRow.date);
        if (prIndex >= 0) {
          sheetRow.rowCells[prIndex].text = '(met R1)';
        }
      }
    }
  }
}

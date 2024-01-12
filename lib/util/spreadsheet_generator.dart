// ignore_for_file: depend_on_referenced_packages

// import 'dart:developer' as dev;
import 'dart:math';

import 'package:collection/collection.dart';
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
  List<Trainer> _getTrainersForGroup(Groep groep) {
    return AppData.instance
        .getAllTrainers()
        .where((trainer) => _availableForGroep(trainer, groep))
        .toList();
  }

  bool _availableForGroep(Trainer trainer, Groep groep) {
    return trainer.getPrefValue(paramName: groep.name) > 0;
  }

  //-------------------------------
  List<Available> generateAvailableTrainersCounts() {
    List<Available> result = [];

    for (int i = 0; i < AppData.instance.getActiveDates().length; i++) {
      DateTime date = AppData.instance.getActiveDates()[i];
      result.add(_genCountProcessDate(i, date));
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
      for (int groepNr = 0; groepNr < Groep.values.length - 1; groepNr++) {
        _findSuitableTrainer(rowNr: rowNr, groepNr: groepNr);
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
  FsSpreadsheet fsSpreadsheetFrom(SpreadSheet spreadSheet) {
    List<FsSpreadsheetRow> fsRows = [];
    for (SheetRow sheetRow in spreadSheet.rows) {
      fsRows.add(_mapFromRow(sheetRow));
    }

    FsSpreadsheet result = FsSpreadsheet(
        year: spreadSheet.year,
        month: spreadSheet.month,
        rows: fsRows,
        isFinal: true);
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

  //---- private --

  //------------- first fill the spreadsheet with available trainer data
  List<SheetRow> _getAvailabilityForSpreadsheet(List<Available> availableList) {
    List<SheetRow> result = [];
    int rowIdx = 0;
    for (Available avail in availableList) {
      SheetRow sheetRow =
          SheetRow(date: avail.date, rowIndex: rowIdx, isExtraRow: false);
      for (int groepNr = 0; groepNr < Groep.values.length; groepNr++) {
        RowCell rowCell = RowCell(rowIndex: rowIdx, colIndex: groepNr);
        rowCell.availableCounts = avail.counts[groepNr];
        sheetRow.rowCells.add(rowCell);
      }
      result.add(sheetRow);

      rowIdx++;
    }

    return result;
  }

  Available _genCountProcessDate(int dateIndex, DateTime date) {
    Available available = Available(date: date);

    for (Groep groep in Groep.values) {
      AvailableCounts availableCounts = AvailableCounts();

      for (Trainer trainer in _getTrainersForGroup(groep)) {
        TrainerSchema schemas = getSchemaFromAllTrainerData(trainer);
        if (schemas.isEmpty()) {
          availableCounts.notEnteredYet.add(trainer);
        } else if (schemas.availableList[dateIndex] == 1) {
          availableCounts.confirmed.add(trainer);
        } else if (schemas.availableList[dateIndex] == 2) {
          availableCounts.ifNeeded.add(trainer);
        }
      }

      available.counts.add(availableCounts);
    }

    return available;
  }

  ///---------------
  void _findSuitableTrainer({required int rowNr, required int groepNr}) {
    AvailableCounts cnts =
        _spreadSheet.rows[rowNr].rowCells[groepNr].availableCounts;

    List<TrainerWeight> possibleTrainerWeights =
        _getPossibleTrainers(cnts, isZamo: false);

    _applyWeights(possibleTrainerWeights, rowNr: rowNr, groepNr: groepNr);

    bool setTrainer = true; //assume
    if (_isThursdayAndPR(rowNr, groepNr) ||
        (_isSaturday(rowNr) && !_isSaturdayAndZamo(rowNr, groepNr))) {
      setTrainer = false;
    }

    if (setTrainer) {
      Trainer trainer = _getTrainerFromPossibleList(possibleTrainerWeights,
          rowNr: rowNr, groepNr: groepNr);
      _spreadSheet.rows[rowNr].rowCells[groepNr].setTrainer(trainer);
    }
  }

  ///---------------
  void _findSuitableZamoTrainer({required int rowNr}) {
    AvailableCounts cnts =
        _spreadSheet.rows[rowNr].rowCells[Groep.zamo.index].availableCounts;

    List<TrainerWeight> possibleTrainerWeights =
        _getPossibleTrainers(cnts, isZamo: true);

    _applyZamoWeights(possibleTrainerWeights, rowNr: rowNr);

    Trainer trainer = _getTrainerFromPossibleList(possibleTrainerWeights,
        rowNr: rowNr, groepNr: Groep.zamo.index);
    _spreadSheet.rows[rowNr].rowCells[Groep.zamo.index].setTrainer(trainer);
  }

//-----------------------
  List<TrainerWeight> _getPossibleTrainers(AvailableCounts cnts,
      {required bool isZamo}) {
    List<TrainerWeight> result = [];

    for (Trainer trainer in cnts.confirmed) {
      double weight = _getStartWeight(trainer: trainer, isZamo: isZamo);
      result.add(TrainerWeight(trainer: trainer, weight: weight));
    }
    for (Trainer trainer in cnts.ifNeeded) {
      double weight = _getStartWeight(trainer: trainer, isZamo: isZamo) +
          AppData.instance.applyWeightValues.onlyIfNeeded;
      result.add(TrainerWeight(trainer: trainer, weight: weight));
    }
    for (Trainer trainer in cnts.notEnteredYet) {
      //todo should we make this optional
      double weight = _getStartWeight(trainer: trainer, isZamo: isZamo);
      result.add(TrainerWeight(trainer: trainer, weight: weight));
    }

    return result;
  }

  double _getStartWeight({required Trainer trainer, required bool isZamo}) {
    ApplyWeightStartValue? startVal = isZamo
        ? AppData.instance.applyWeightValues.startValues
            .firstWhereOrNull((e) => e.trainerPk == trainer.pk)
        : AppData.instance.applyWeightValues.zamoStartValues
            .firstWhereOrNull((e) => e.trainerPk == trainer.pk);

    if (startVal != null) {
      return startVal.value;
    } else {
      ApplyWeightStartValue? startVal = AppData
          .instance.applyWeightValues.startValues
          .firstWhereOrNull((e) => e.trainerPk == '*');
      if (startVal != null) {
        return startVal.value;
      } else {
        return 100.0; //we should never come here
      }
    }
  }

  Trainer _getTrainerFromPossibleList(List<TrainerWeight> possibleTrainers,
      {required int rowNr, required int groepNr}) {
    possibleTrainers = _removeAlreadyScheduled(possibleTrainers, rowNr: rowNr);
    if (possibleTrainers.length == 1) {
      return possibleTrainers.last.trainer;
    } else if (possibleTrainers.length > 1) {
      possibleTrainers.sort((a, b) => b.weight.compareTo(a.weight));
      double weight = possibleTrainers.first.weight;
      List<TrainerWeight> sortedTrainers =
          possibleTrainers.where((e) => e.weight == weight).toList();
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

  List<TrainerWeight> _removeAlreadyScheduled(
      List<TrainerWeight> possibleTrainers,
      {required int rowNr}) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    List<TrainerWeight> result = [];

    for (TrainerWeight tw in possibleTrainers) {
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

  // here we make weight higher or lower in order to make choice
  void _applyWeights(List<TrainerWeight> trainerWeightList,
      {required int rowNr, required int groepNr}) {
    if (!_isSaturday(rowNr) && !_isThursdayAndPR(rowNr, groepNr)) {
      _applyOnlyIfNeeded(trainerWeightList, rowNr: rowNr, groepNr: groepNr);
      _applyDaysNotAvailable(trainerWeightList, rowNr: rowNr, groepNr: groepNr);
      _applyAlreadyScheduled(trainerWeightList, rowNr: rowNr, groepNr: groepNr);
    }
  }

  void _applyZamoWeights(List<TrainerWeight> trainerWeightList,
      {required int rowNr}) {
    _applyDaysNotAvailable(trainerWeightList,
        rowNr: rowNr, groepNr: Groep.zamo.index);
    _applyAlreadyZamoScheduled(trainerWeightList, rowNr: rowNr);
  }

  // if trainer is not available future days its score goes up
  void _applyOnlyIfNeeded(List<TrainerWeight> trainerWeightList,
      {required int rowNr, required int groepNr}) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      if (_isOnlyIfNeeded(trainer, groepNr)) {
        tw.weight += AppData.instance.applyWeightValues.onlyIfNeeded;
      }
    }
  }

  bool _isOnlyIfNeeded(Trainer trainer, int groepNr) {
    return trainer.getPrefValue(paramName: Groep.values[groepNr].name) == 2;
  }

  // if trainer is not available future days its score goes up
  void _applyDaysNotAvailable(List<TrainerWeight> trainerWeightList,
      {required int rowNr, required int groepNr}) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      int notAvailCnt =
          _countDaysNotAvalaible(trainer, rowNr: rowNr, groepNr: groepNr);

      if (notAvailCnt > 0) {
        tw.weight += (notAvailCnt * 10);
      }
    }
  }

// if trainer is already scheduled before its score goes down
  void _applyAlreadyScheduled(List<TrainerWeight> trainerWeightList,
      {required int rowNr, required int groepNr}) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      double applyWeight = _getApplyWeightForAlreadyScheduledDays(trainer,
          rowNr: rowNr, groepNr: groepNr);
      tw.weight += applyWeight;
    }
  }

  void _applyAlreadyZamoScheduled(List<TrainerWeight> trainerWeightList,
      {required int rowNr}) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;

      double result = 0.0;
      int countDays = 1;
      List<double> values = AppData.instance.applyWeightValues.alreadyScheduled;

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

      tw.weight += result;
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

  bool _isThursdayAndPR(int rowNr, int groepNr) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.thursday &&
        groepNr == Groep.pr.index;
  }

  bool _isSaturdayAndZamo(int rowNr, int groepNr) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.saturday &&
        groepNr == Groep.zamo.index;
  }

  // hoe vaak afwezig vanaf dateTime
  int _countDaysNotAvalaible(Trainer trainer,
      {required int rowNr, required int groepNr}) {
    int result = 0;

    DateTime dateTime = _spreadSheet.rows[rowNr].date;

    for (SheetRow sheetRow in _spreadSheet.rows) {
      if (sheetRow.date.isAfter(dateTime) &&
          sheetRow.date.weekday != DateTime.saturday) {
        List<Trainer> allTrainers =
            sheetRow.rowCells[groepNr].availableCounts.getAllTrainers();
        if (!allTrainers.contains(trainer)) {
          result++;
        }
      }
    }

    return result;
  }

  // how often scheduled in the days before
  double _getApplyWeightForAlreadyScheduledDays(Trainer trainer,
      {required int rowNr, required int groepNr}) {
    double result = 0.0;

    if (_isSaturday(rowNr)) {
      return result;
    }

    int countDays = 1;
    List<double> values = AppData.instance.applyWeightValues.alreadyScheduled;
    for (int prevRowNr = rowNr - 1; prevRowNr >= 0; prevRowNr--) {
      for (RowCell rowCell in _spreadSheet.rows[prevRowNr].rowCells) {
        if (!_isSaturday(prevRowNr) && !_isThursdayAndPR(prevRowNr, groepNr)) {
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
      if (sheetRow.date.weekday == DateTime.saturday) {
        sheetRow.trainingText = 'ZaMo';
        String zamoTrainer = sheetRow.rowCells[Groep.zamo.index].text;
        for (int i = 0; i < Groep.values.length; i++) {
          sheetRow.rowCells[i].text = '';
        }
        sheetRow.rowCells[Groep.zamo.index].text = zamoTrainer;
      } else {
        sheetRow.rowCells[Groep.zamo.index].setTrainer(Trainer.empty());
      }
    }
  }

  void postProcessThursdayPR() {
    for (SheetRow sheetRow in _spreadSheet.rows) {
      if (sheetRow.date.weekday == DateTime.thursday) {
        sheetRow.rowCells[Groep.pr.index].text = '(met R1)';
      }
    }
  }
}

// ignore_for_file: depend_on_referenced_packages

// import 'dart:developer' as dev;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';

class SpreadsheetGenerator {
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
    Map<String, dynamic> map = trainer.toMap();
    int avail = map[groep.name];
    return avail > 0;
  }

  //-------------------------------
  List<Available> generateAvailableTrainersCounts() {
    List<Available> result = [];

    for (DateTime dateTime in AppData.instance.getActiveDates()) {
      result.add(_genCountProcessDate(dateTime));
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
    _fillAvailabilityInSpreadsheet(availableList);

    // next find the best trainer
    for (int rowNr = 0; rowNr < _spreadSheet.rows.length; rowNr++) {
      for (int groepNr = 0; groepNr < Groep.values.length; groepNr++) {
        _findSuitableTrainer(rowNr: rowNr, groepNr: groepNr);
      }
    }

    _postProcessSpreadsheet();
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
  void _fillAvailabilityInSpreadsheet(List<Available> availableList) {
    int rowIdx = 0;
    for (Available avail in availableList) {
      SheetRow sheetRow =
          SheetRow(date: avail.date, rowIndex: rowIdx, isExtraRow: false);
      for (int groepNr = 0; groepNr < Groep.values.length; groepNr++) {
        RowCell rowCell = RowCell(rowIndex: rowIdx, colIndex: groepNr);
        rowCell.availableCounts = avail.counts[groepNr];
        sheetRow.rowCells.add(rowCell);
      }
      _spreadSheet.addRow(sheetRow);

      rowIdx++;
    }
  }

  Available _genCountProcessDate(DateTime date) {
    Available available = Available(date: date);
    String mapDateStr = AppHelper.instance.getDateStringForSpreadsheet(date);

    for (Groep groep in Groep.values) {
      AvailableCounts availableCounts = AvailableCounts();

      for (Trainer trainer in _getTrainersForGroup(groep)) {
        TrainerSchema schemas = getSchemaFromAllTrainerData(trainer);
        Map<String, dynamic> schemaMap = schemas.toMap();
        if (schemas.isEmpty()) {
          availableCounts.notEnteredYet.add(trainer);
        } else if (schemaMap[mapDateStr] == 1) {
          availableCounts.confirmed.add(trainer);
        } else if (schemaMap[mapDateStr] == 2) {
          availableCounts.ifNeeded.add(trainer);
        }
      }

      available.counts.add(availableCounts);
    }

    return available;
  }

//---------------
  void _findSuitableTrainer({required int rowNr, required int groepNr}) {
    AvailableCounts cnts =
        _spreadSheet.rows[rowNr].rowCells[groepNr].availableCounts;

    List<TrainerWeight> possibleTrainerWeights = _getPossibleTrainers(cnts);
    _applyWeights(possibleTrainerWeights, rowNr: rowNr, groepNr: groepNr);

    if (!_isThursdayPR(rowNr, groepNr)) {
      Trainer trainer = _getTrainerFromPossibleList(possibleTrainerWeights,
          rowNr: rowNr, groepNr: groepNr);
      _spreadSheet.rows[rowNr].rowCells[groepNr].setTrainer(trainer);
    }
  }

//-----------------------
  List<TrainerWeight> _getPossibleTrainers(AvailableCounts cnts) {
    List<TrainerWeight> result = [];

    for (Trainer trainer in cnts.confirmed) {
      double weight = _getStartWeight(trainer);
      result.add(TrainerWeight(trainer: trainer, weight: weight));
    }
    for (Trainer trainer in cnts.ifNeeded) {
      double weight = _getStartWeight(trainer) +
          AppData.instance.applyWeightValues.onlyIfNeeded;
      result.add(TrainerWeight(trainer: trainer, weight: weight));
    }
    for (Trainer trainer in cnts.notEnteredYet) {
      //todo should we make this optional
      double weight = _getStartWeight(trainer);
      result.add(TrainerWeight(trainer: trainer, weight: weight));
    }

    return result;
  }

  double _getStartWeight(Trainer trainer) {
    ApplyWeightStartValue? startVal = AppData
        .instance.applyWeightValues.startValues
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
    possibleTrainers = _removeAlreadyScheduled(possibleTrainers,
        rowNr: rowNr, groepNr: groepNr);
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
      {required int rowNr,
      required int groepNr}) {
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
    if (!_isSaturday(rowNr) && !_isThursdayPR(rowNr, groepNr)) {
      _applyOnlyIfNeeded(trainerWeightList, rowNr: rowNr, groepNr: groepNr);
      _applyDaysNotAvailable(trainerWeightList, rowNr: rowNr, groepNr: groepNr);
      _applyAlreadyScheduled(trainerWeightList, rowNr: rowNr, groepNr: groepNr);
    }
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
    Map<String, dynamic> map = trainer.toMap();
    int value = map[Groep.values[groepNr].name];
    return value == 2;
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

// if trainer is already sceduled before its score goes down
  void _applyAlreadyScheduled(List<TrainerWeight> trainerWeightList,
      {required int rowNr, required int groepNr}) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      double applyWeight = _getApplyWeightForAlreadyScheduledDays(trainer,
          rowNr: rowNr, groepNr: groepNr);
      tw.weight += applyWeight;
    }
  }

  bool _isSaturday(int rowNr) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.saturday;
  }

  bool _isThursdayPR(int rowNr, int groepNr) {
    SheetRow sheetRow = _spreadSheet.rows[rowNr];
    return sheetRow.date.weekday == DateTime.thursday &&
        groepNr == Groep.pr.index;
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

  // hoe vaak afwezig vanaf dateTime
  double _getApplyWeightForAlreadyScheduledDays(Trainer trainer,
      {required int rowNr, required int groepNr}) {
    double result = 0.0;

    int countDays = 1;
    List<double> values = AppData.instance.applyWeightValues.alreadyScheduled;
    for (int i = rowNr - 1; i >= 0; i--) {
      for (RowCell rowCell in _spreadSheet.rows[i].rowCells) {
        Trainer schedTrainer = rowCell.getTrainer();
        if (schedTrainer == trainer) {
          int idx = countDays > values.length - 1 ? 0 : countDays;
          double w = values[idx];
          result += w;
        }
      }
      countDays++;
    }

    return result;
  }

  void _postProcessSpreadsheet() {
    _postProcessZamo();
    _postProcessThursdayPR();
  }

  void _postProcessZamo() {
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

  void _postProcessThursdayPR() {
    for (SheetRow sheetRow in _spreadSheet.rows) {
      if (sheetRow.date.weekday == DateTime.thursday) {
        sheetRow.rowCells[Groep.pr.index].text = '(met R1)';
      }
    }
  }
}

import 'dart:developer';
import 'dart:math';

import 'package:firestore/data/app_data.dart';
import 'package:firestore/model/app_models.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:firestore/util/data_helper.dart';

class SchemaGenerator {
  SchemaGenerator._();

  static SchemaGenerator instance = SchemaGenerator._();

  //-------------
  //
  TrainerSchema getSchemaFromAllTrainerData(Trainer trainer) {
    TrainerData? trainerData = AppData.instance
        .getAllTrainerData()
        .firstWhereOrNull((e) => e.trainer.pk == trainer.pk);

    if (trainerData != null) {
      return trainerData.trainerSchemas;
    } else {
      return TrainerSchema.empty();
    }
  }

  //-------------
  //
  List<Trainer> getTrainersForGroup(Groep groep) {
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
      _genCountProcessDate(dateTime, result);
    }

    return result;
  }

  //------------------------------------------
  SpreadSheet generateSpreadsheet(
      List<Available> availableList, DateTime date) {
    SpreadSheet spreadSheet = SpreadSheet.init(date);

    for (Available avail in availableList) {
      SheetRow sheetRow = SheetRow.init(date: avail.date);
      spreadSheet.addRow(sheetRow);

      _findMostSuitableTrainer(
          availableList, Groep.pr, avail.date, spreadSheet);
      _findMostSuitableTrainer(
          availableList, Groep.r1, avail.date, spreadSheet);
      _findMostSuitableTrainer(
          availableList, Groep.r2, avail.date, spreadSheet);
      _findMostSuitableTrainer(
          availableList, Groep.r3, avail.date, spreadSheet);
      _findMostSuitableTrainer(
          availableList, Groep.zamo, avail.date, spreadSheet);
    }

    _formatSpreadsheet(spreadSheet);
    return spreadSheet;
  }

  ///---------------
  String generateHtml(SpreadSheet spreadSheet) {
    String maand = AppData.instance.getActiveMonthAsString();
    String html = '''
<h2>Trainingschema $maand</h2><br>
<table border="0.5" >
<tbody>
    ''';

    int row = 0;
    for (SheetRow sheetRow in spreadSheet.rows) {
      row++;
      String style = row == 1 ? '''class="toprow";''' : '';
      html += '<tr $style>\n';
      html += '<td>${sheetRow.date}</td>\n';
      html += '<td>${sheetRow.training}</td>\n';
      html += '<td>${_getHtmlValue(sheetRow, Groep.pr, row)}</td>\n';
      html += '<td>${_getHtmlValue(sheetRow, Groep.r1, row)}</td>\n';
      html += '<td>${_getHtmlValue(sheetRow, Groep.r2, row)}</td>\n';
      html += '<td>${_getHtmlValue(sheetRow, Groep.r3, row)}</td>\n';
      html += '</tr>\n';
    }

    html += '''
</table>
</tbody>
''';

    return html;
  }

  String _getHtmlValue(SheetRow csv, Groep groep, int row) {
    Map<String, dynamic> csvMap = csv.toMap();
    if (row == 1) {
      return groep.name.toUpperCase();
    } else {
      return Trainer.fromMap(csvMap[groep.name]).firstName();
    }
  }

  ///---------------
  List<String> generateCsv(SpreadSheet spreadSheet) {
    List<String> result = [];

    int row = 0;
    for (SheetRow r in spreadSheet.rows) {
      row++;
      String line = (row == 1)
          ? '${r.date};${r.training};PR;R1;R2;R3'
          : '${r.date};${r.training};${r.pr.firstName()};${r.r1.firstName()};${r.r2.firstName()};${r.r3.firstName()}';
      result.add(line);
    }
    return result;
  }

  //---- private --

  void _genCountProcessDate(DateTime date, List<Available> result) {
    Available available = Available.empty();
    available.date = date;

    String mapDateStr = DataHelper.instance.getDateStringForSpreadsheet(date);
    Map<String, dynamic> availMap = available.toMap();

    for (Groep groep in Groep.values) {
      AvailableCounts availableCounts = AvailableCounts.empty();

      for (Trainer trainer in getTrainersForGroup(groep)) {
        TrainerSchema schemas = getSchemaFromAllTrainerData(trainer);
        // log('ts = ${schemas.toMap()}');
        Map<String, dynamic> schemaMap = schemas.toMap();
        if (schemas.isEmpty()) {
          availableCounts.notEnteredYet.add(trainer);
        } else if (schemaMap[mapDateStr] == 1) {
          availableCounts.confirmed.add(trainer);
        } else if (schemaMap[mapDateStr] == 2) {
          availableCounts.ifNeeded.add(trainer);
        }
      }

      availMap[groep.name] = availableCounts.toMap();
    }

    Available a = Available.fromMap(availMap);
    result.add(a);
  }

  void _findMostSuitableTrainer(List<Available> availableList, Groep group,
      DateTime dateTime, SpreadSheet spreadSheet) {
    AvailableCounts cnts =
        DataHelper.instance.getAvailableCounts(availableList, group, dateTime);

    List<TrainerWeight> possibleTrainers = _getPossibleTrainers(cnts);
    _applyWeights(
        possibleTrainers, availableList, group, dateTime, spreadSheet);

    Trainer trainer = _getTrainerFromPossibleList(possibleTrainers);
    spreadSheet.rows.last.setTrainer(trainer, group);
  }

  List<TrainerWeight> _getPossibleTrainers(AvailableCounts cnts) {
    List<TrainerWeight> result = [];
    Map<String, dynamic> map = cnts.toMap();

    var propNames = ['confirmed', 'ifNeeded', 'notEnteredYet'];

    for (var name in propNames) {
      List<Map<String, dynamic>> mapList = map[name];
      for (Map<String, dynamic> map in mapList) {
        Trainer trainer = Trainer.fromMap(map);
        result.add(TrainerWeight(trainer: trainer, weight: 50));
      }
    }

    return result;
  }

  Trainer _getTrainerFromPossibleList(List<TrainerWeight> possibleTrainers) {
    if (possibleTrainers.length == 1) {
      return possibleTrainers.last.trainer;
    } else if (possibleTrainers.length > 1) {
      possibleTrainers.sort((a, b) => b.weight.compareTo(a.weight));
      int weight = possibleTrainers.first.weight;
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

  // here we make weight higher or lower in order to make choice
  void _applyWeights(
      List<TrainerWeight> trainerWeightList,
      List<Available> availableList,
      Groep group,
      DateTime date,
      SpreadSheet spreadSheet) {
    _applyOnlyIfNeeded(trainerWeightList, group);
    _applyDaysNotAvailable(trainerWeightList, availableList, group, date);
    _applyAlreadyScheduled(trainerWeightList, group, spreadSheet);
    _applyAlreadyScheduledOtherGroup(
        trainerWeightList, availableList, spreadSheet, date);
  }

  void _applyOnlyIfNeeded(List<TrainerWeight> trainerWeightList, Groep group) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      if (trainer.toMap()[group.name] == 2) {
        tw.weight = tw.weight - 15;
      }
    }
  }

  void _applyDaysNotAvailable(List<TrainerWeight> trainerWeightList,
      List<Available> availableList, Groep group, DateTime dateTime) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      int notAvailCnt =
          _countDaysNotAvalaible(trainer, availableList, group, dateTime);
      tw.weight = tw.weight + (notAvailCnt * 10);
    }
  }

  void _applyAlreadyScheduled(List<TrainerWeight> trainerWeightList,
      Groep group, SpreadSheet spreadSheet) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      int scheduledCnt =
          _countDaysAlreadyScheduled(trainer, group, spreadSheet);
      tw.weight = tw.weight - (scheduledCnt * 10);
    }
  }

  void _applyAlreadyScheduledOtherGroup(List<TrainerWeight> trainerWeightList,
      List<Available> availableList, SpreadSheet spreadSheet, DateTime date) {
    for (TrainerWeight tw in trainerWeightList) {
      Trainer trainer = tw.trainer;
      int scheduledCnt = _countDaysAlreadyScheduledOtherGroup(
          trainer, availableList, spreadSheet, date);

      if (scheduledCnt > 0) {
        tw.weight = -1; // so trainer can not be selected anymore this day
      }
    }
  }

  // hoe vaak afwezig vanaf dateTime
  int _countDaysNotAvalaible(Trainer trainer, List<Available> availableList,
      Groep group, DateTime dateTime) {
    int result = 0;

    for (Available avail in availableList) {
      if (avail.date.isAfter(dateTime)) {
        Map<String, dynamic> map = avail.toMap()[group.name];
        AvailableCounts availCnts = AvailableCounts.fromMap(map);
        List<Trainer> allTrainers = availCnts.getAllTrainers();
        if (!allTrainers.contains(trainer)) {
          result++;
        }
      }
    }

    return result;
  }

  // hoe vaak afwezig vanaf dateTime
  int _countDaysAlreadyScheduled(
      Trainer trainer, Groep group, SpreadSheet spreadSheet) {
    int result = 0;

    for (SheetRow csvRoster in spreadSheet.rows) {
      Trainer schedTrainer = Trainer.fromMap(csvRoster.toMap()[group.name]);
      if (schedTrainer.pk == trainer.pk) {
        result++;
      }
    }

    return result;
  }

  // hoe vaak afwezig vanaf dateTime
  int _countDaysAlreadyScheduledOtherGroup(Trainer trainer,
      List<Available> availableList, SpreadSheet spreadSheet, DateTime date) {
    int result = 0;

    SheetRow sheetRow = spreadSheet.rows.last;

    for (Groep groep in Groep.values) {
      Trainer schedTrainer = sheetRow.getTrainerByGroup(groep);
      if (schedTrainer.pk == trainer.pk) {
        result++;
      }
    }

    return result;
  }

  void _formatSpreadsheet(SpreadSheet spreadSheet) {
    for (SheetRow sheetRow in spreadSheet.rows) {
      if (sheetRow.date.weekday == DateTime.saturday) {
        sheetRow.pr = Trainer.empty();
        sheetRow.r1 = Trainer.empty();
        sheetRow.r2 = Trainer.empty();
        sheetRow.r3 = Trainer.empty();
        sheetRow.zamo = Trainer.empty().copyWith(fullname: 'Hu/Pa/Ro');
      }
    }
  }
}

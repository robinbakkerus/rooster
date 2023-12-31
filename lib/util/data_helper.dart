// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore/data/app_data.dart';
import 'package:firestore/model/app_models.dart';

class DataHelper {
  DataHelper._();
  static final DataHelper instance = DataHelper._();

  // return something like "Din 9" , which can be used to set label
  String getSimpleDayString(DateTime dateTime) {
    String weekday = _weekDay(dateTime.weekday);
    String day = dateTime.day.toString();
    return '$weekday $day';
  }

  // return something like "din1", hence the first occurence

  String getDateStringForSpreadsheet(DateTime dateTime) {
    int occurence = 0;
    for (DateTime dt in AppData.instance.getActiveDates()) {
      if (dt.weekday == dateTime.weekday) {
        occurence++;
        if (dt.day == dateTime.day) {
          return _weekDay(dt.weekday).toLowerCase() + occurence.toString();
        }
      }
    }
    return '???';
  }

  /// --
  DateTime? parseDateTime(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return (value).toDate();
    } else if (value == null) {
      return null;
    } else {
      return DateTime.now();
    }
  }

  bool isJustModified(TrainerSchema trainerSchema) {
    if (trainerSchema.modified == null) {
      return false;
    } else {
      return DateTime.now().millisecondsSinceEpoch -
              trainerSchema.modified!.millisecondsSinceEpoch <
          5000;
    }
  }

  ///---
  ///
  String buildTrainerSchemaId(Trainer trainer) {
    String result = trainer.pk;
    result += '_${AppData.instance.getActiveYear()}';
    result += '_${AppData.instance.getActiveMonth()}';
    return result;
  }

  /// build list of DaySchema's from single TrainerSchemas object
  List<DaySchema> buildFromTrainerSchemas(TrainerSchema trainerSchemas) {
    if (trainerSchemas.isEmpty()) {
      return [];
    }

    List<DaySchema> daySchemaList = [];
    String id = trainerSchemas.id;
    int year = _getYearFromSchemaId(id);
    int month = _getMonthFromSchemaId(id);

    Map<dynamic, dynamic> map = trainerSchemas.toMap();

    int tueOcc = 1;
    int thuOcc = 1;
    int satOcc = 1;

    for (DateTime dt in AppData.instance.getActiveDates()) {
      if (dt.weekday == DateTime.tuesday &&
          AppData.instance.getTrainer().dinsdag > 0) {
        String mapName = 'din$tueOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        tueOcc++;
      } else if (dt.weekday == DateTime.thursday &&
          AppData.instance.getTrainer().donderdag > 0) {
        String mapName = 'don$thuOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        thuOcc++;
      } else if (dt.weekday == DateTime.saturday &&
          AppData.instance.getTrainer().zaterdag > 0) {
        String mapName = 'zat$satOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        satOcc++;
      }
    }

    return daySchemaList;
  }

  ///---
  TrainerSchema buildFromDaySchemas(List<DaySchema> daySchemas) {
    int tueOcc = 1;
    int thuOcc = 1;
    int satOcc = 1;

    TrainerSchema schema = TrainerSchema.empty();
    Map<String, dynamic> schemaMap = schema.toMap();

    for (DaySchema daySchema in daySchemas) {
      DateTime dt = DateTime(daySchema.year, daySchema.month, daySchema.day);
      if (dt.weekday == DateTime.tuesday) {
        String mapName = 'din$tueOcc';
        tueOcc++;
        schemaMap[mapName] = daySchema.available;
      } else if (dt.weekday == DateTime.thursday) {
        String mapName = 'don$thuOcc';
        thuOcc++;
        schemaMap[mapName] = daySchema.available;
      } else if (dt.weekday == DateTime.saturday) {
        String mapName = 'zat$satOcc';
        satOcc++;
        schemaMap[mapName] = daySchema.available;
      } else {
        log('dit kan niet');
      }
    }

    schemaMap['id'] =
        DataHelper.instance.buildTrainerSchemaId(AppData.instance.getTrainer());
    schemaMap['modified'] = DateTime.now();
    TrainerSchema result = TrainerSchema.fromMap(schemaMap);
    return result;
  }

  ///--
  TrainerSchema buildNewSchemaForTrainer(Trainer trainer) {
    int din = trainer.dinsdag;
    int don = trainer.donderdag;
    int zat = trainer.zaterdag;

    Map<String, dynamic> map = {};
    for (int i = 1; i < 6; i++) {
      map['din$i'] = din;
      map['don$i'] = don;
      map['zat$i'] = zat;
    }

    map['id'] = DataHelper.instance.buildTrainerSchemaId(trainer);
    map['trainerPk'] = trainer.pk;
    map['year'] = AppData.instance.getActiveYear();
    map['month'] = AppData.instance.getActiveMonth();
    map['created'] = DateTime.now();

    TrainerSchema result = TrainerSchema.fromMap(map);
    return result;
  }

  //------------------
  List<DateTime> getDaysInBetween(DateTime startDate) {
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  //------------------
  AvailableCounts getAvailableCounts(Groep group, DateTime dateTime) {
    for (SheetRow sheetRow in AppData.instance.getSpreadsheet().rows) {
      if (DataHelper.instance.isSameDate(sheetRow.date, dateTime)) {
        return sheetRow.rowCells[group.index].availableCounts;
      }
    }

    return AvailableCounts();
  }

  //----- private ---------------------------

  void _handleThisDay(Map<dynamic, dynamic> trainerSchemasMap, String mapName,
      int year, int month, DateTime dt, List<DaySchema> daySchemaList) {
    int available = trainerSchemasMap[mapName];

    DaySchema daySchema = DaySchema(
      year: year,
      month: month,
      day: dt.day,
      available: available,
    );

    daySchemaList.add(daySchema);
  }

  bool isSameDate(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  String getFirstName(Trainer trainer) {
    List<String> tokens = trainer.fullname.split(' ');
    if (tokens.isNotEmpty) {
      return tokens[0];
    } else {
      return trainer.fullname;
    }
  }

  /// -------- private methods --------------------------------

  String _weekDay(int day) {
    if (day == DateTime.sunday) {
      return "zon";
    } else if (day == DateTime.monday)
      return "maa";
    else if (day == DateTime.tuesday)
      return "din";
    else if (day == DateTime.wednesday)
      return "woe";
    else if (day == DateTime.thursday)
      return "don";
    else if (day == DateTime.friday)
      return "vry";
    else
      return "zat";
  }

  int _getYearFromSchemaId(String trainerSchemaId) {
    List<String> tokens = trainerSchemaId.split('_');
    if (tokens.length < 2) {
      log("!! dit kan niet _getYearFromSchemaId $trainerSchemaId");
      return 2024;
    } else {
      return int.parse(tokens[1]);
    }
  }

  int _getMonthFromSchemaId(String trainerSchemaId) {
    List<String> tokens = trainerSchemaId.split('_');
    if (tokens.length < 3) {
      log("!! dit kan niet _getMonthFromSchemaId $trainerSchemaId");
      return 1;
    } else {
      return int.parse(tokens[2]);
    }
  }
}

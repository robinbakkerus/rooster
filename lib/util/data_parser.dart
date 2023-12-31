// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore/controller/app_controler.dart';
import 'package:firestore/data/trainer_data.dart';
import 'package:firestore/model/app_models.dart';

class DataHelper {
  DataHelper._();
  static final DataHelper instance = DataHelper._();

  // return something like "Din 9"
  String parse(DateTime dateTime) {
    String weekday = _weekDay(dateTime.weekday);
    String day = dateTime.day.toString();
    return '$weekday $day';
  }

  DateTime parseDateTime(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return (value).toDate();
    } else {
      return DateTime.now();
    }
  }

  /// build list of DaySchema's from single TrainerSchemas object
  List<DaySchema> buildFromTrainerSchemas(TrainerSchemas trainerSchemas) {
    List<DaySchema> daySchemaList = [];

    String id = trainerSchemas.id;
    int year = _getYearFromSchemaId(id);
    int month = _getMonthFromSchemaId(id);

    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0);

    List<DateTime> dates = _getDaysInBetween(startDate, endDate);
    Map<dynamic, dynamic> map = trainerSchemas.toMap();

    int tueOcc = 1;
    int thuOcc = 1;
    int satOcc = 1;

    for (DateTime dt in dates) {
      if (dt.weekday == DateTime.tuesday &&
          TrainerData.instance.trainer.dinsdag > 0) {
        String mapName = 'din$tueOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        tueOcc++;
      } else if (dt.weekday == DateTime.thursday &&
          TrainerData.instance.trainer.donderdag > 0) {
        String mapName = 'don$thuOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        thuOcc++;
      } else if (dt.weekday == DateTime.saturday &&
          TrainerData.instance.trainer.zaterdag > 0) {
        String mapName = 'zat$satOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        satOcc++;
      }
    }

    return daySchemaList;
  }

  ///---
  TrainerSchemas buildFromDaySchemas(List<DaySchema> daySchemas) {
    int tueOcc = 1;
    int thuOcc = 1;
    int satOcc = 1;

    TrainerSchemas emptySchemas = TrainerSchemas.empty();
    Map<String, dynamic> map = emptySchemas.toMap();

    for (DaySchema daySchema in daySchemas) {
      DateTime dt = DateTime(daySchema.year, daySchema.month, daySchema.day);
      if (dt.weekday == DateTime.tuesday) {
        String mapName = 'din$tueOcc';
        tueOcc++;
        map[mapName] = daySchema.available;
      } else if (dt.weekday == DateTime.thursday) {
        String mapName = 'don$thuOcc';
        thuOcc++;
        map[mapName] = daySchema.available;
      } else if (dt.weekday == DateTime.saturday) {
        String mapName = 'don$satOcc';
        satOcc++;
        map[mapName] = daySchema.available;
      }
    }

    map['id'] = AppController.instance.buildTrainerSchemaId();
    map['modified'] = DateTime.now();
    TrainerSchemas result = TrainerSchemas.fromMap(map);
    return result;
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

  /// -------- private methods --------------------------------

  String _weekDay(int day) {
    if (day == 0) {
      return "Zon";
    } else if (day == 1)
      return "Maa";
    else if (day == 2)
      return "Din";
    else if (day == 3)
      return "Woe";
    else if (day == 5)
      return "Don";
    else if (day == 6)
      return "Vry";
    else
      return "Zat";
  }

  int _getYearFromSchemaId(String trainerSchemaId) {
    List<String> tokens = trainerSchemaId.split('_');
    return int.parse(tokens[1]);
  }

  int _getMonthFromSchemaId(String trainerSchemaId) {
    List<String> tokens = trainerSchemaId.split('_');
    return int.parse(tokens[2]);
  }

  // String _getShortnameFromSchemaId(String trainerSchemaId) {
  //   List<String> tokens = trainerSchemaId.split('_');
  //   return tokens[0];
  // }

  List<DateTime> _getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }
}

//----------

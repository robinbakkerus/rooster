import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';

class AppHelper with AppMixin {
  AppHelper._();
  static final AppHelper instance = AppHelper._();

  ///----------------------------------------
  // return something like "Din 9" , which can be used to set label
  String getSimpleDayString(DateTime dateTime) {
    String weekday = _getShortWeekDay(dateTime);
    String day = dateTime.day.toString();
    return '$weekday $day';
  }

  ///----------------------------------------
  // return something like "din1", hence the first occurence
  String getDateStringForSpreadsheet(DateTime dateTime) {
    int occurence = 0;
    for (DateTime dt in AppData.instance.getActiveDates()) {
      if (dt.weekday == dateTime.weekday) {
        occurence++;
        if (dt.day == dateTime.day) {
          return _getShortWeekDay(dt).toLowerCase() + occurence.toString();
        }
      }
    }
    return '???';
  }

  ///----------------------------------------
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

  ///----------------------------------------
  ///
  String buildTrainerSchemaId(Trainer trainer) {
    String result = trainer.pk;
    result += '_${AppData.instance.getActiveYear()}';
    result += '_${AppData.instance.getActiveMonth()}';
    return result;
  }

  ///----------------------------------------
  /// build list of DaySchema's from single TrainerSchemas object
  List<DaySchema> buildFromTrainerSchemas(TrainerSchema trainerSchema) {
    if (trainerSchema.isEmpty()) {
      return [];
    }

    List<DaySchema> daySchemaList = [];
    String id = trainerSchema.id;
    int year = _getYearFromSchemaId(id);
    int month = _getMonthFromSchemaId(id);

    Map<dynamic, dynamic> map = trainerSchema.toMap();

    int tueOcc = 1;
    int thuOcc = 1;
    int satOcc = 1;

    for (DateTime dt in AppData.instance.getActiveDates()) {
      if (dt.weekday == DateTime.tuesday) {
        String mapName = 'din$tueOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        tueOcc++;
      } else if (dt.weekday == DateTime.thursday) {
        String mapName = 'don$thuOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        thuOcc++;
      } else if (dt.weekday == DateTime.saturday &&
          AppData.instance.isZamoTrainer(trainerSchema.trainerPk)) {
        String mapName = 'zat$satOcc';
        _handleThisDay(map, mapName, year, month, dt, daySchemaList);
        satOcc++;
      }
    }

    return daySchemaList;
  }

  ///----------------------------------------
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
        lp('dit kan niet');
      }
    }

    schemaMap['id'] =
        AppHelper.instance.buildTrainerSchemaId(AppData.instance.getTrainer());
    schemaMap['modified'] = DateTime.now();
    TrainerSchema result = TrainerSchema.fromMap(schemaMap);
    return result;
  }

  ///----------------------------------------
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

    map['id'] = AppHelper.instance.buildTrainerSchemaId(trainer);
    map['trainerPk'] = trainer.pk;
    map['year'] = AppData.instance.getActiveYear();
    map['month'] = AppData.instance.getActiveMonth();
    map['created'] = DateTime.now();

    TrainerSchema result = TrainerSchema.fromMap(map);
    return result;
  }

  ///----------------------------------------//------------------
  List<DateTime> getDaysInBetween(DateTime startDate) {
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  ///----------------------------------------//------------------
  AvailableCounts getAvailableCounts(Groep group, DateTime dateTime) {
    for (SheetRow sheetRow in AppData.instance.getSpreadsheet().rows) {
      if (AppHelper.instance.isSameDate(sheetRow.date, dateTime)) {
        return sheetRow.rowCells[group.index].availableCounts;
      }
    }

    return AvailableCounts();
  }

  ///-----------------
  bool isSameDate(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  ///-----------------
  String getFirstName(Trainer trainer) {
    List<String> tokens = trainer.fullname.split(' ');
    if (tokens.isNotEmpty) {
      return tokens[0];
    } else {
      return trainer.fullname;
    }
  }

  ///-----------------
  String monthAsString(DateTime date) {
    String dayMonth = DateFormat.MMMM('nl_NL').format(date);
    return dayMonth;
  }

  ///-----------------
  /// return something like: 'woensdag'
  String dayAsString(DateTime date) {
    String dag = DateFormat.EEEE('nl_NL').format(date).substring(0, 3);
    dag += ' ${date.day}';
    return dag;
  }

  ///-----------------
  void getDeviceType(BuildContext context) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    lp(allInfo.toString());
  }

  ///--------------------
  TargetPlatform getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return TargetPlatform.android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return TargetPlatform.iOS;
    } else {
      return TargetPlatform.windows;
    }
  }

  ///--------------------
  bool isWindows() {
    TargetPlatform platform = getPlatform();
    return platform == TargetPlatform.windows;
  }

  bool isTablet() {
    if (isWindows()) {
      return false;
    } else {
      return AppData.instance.shortestSide > 600;
    }
  }

  ///--------------------
  int getAvailability(Trainer trainer, DateTime dateTime) {
    TrainerData? trainerData = AppData.instance
        .getAllTrainerData()
        .firstWhereOrNull((e) => e.trainer == trainer);

    String mapName = getDateStringForSpreadsheet(dateTime);
    if (trainerData != null) {
      Map<String, dynamic> map = trainerData.trainerSchemas.toMap();
      if (map[mapName] != null) {
        return map[mapName];
      }
    }
    return 0;
  }

  /// -------- private methods --------------------------------

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

  String _getShortWeekDay(DateTime dateTime) {
    String dag = dayAsString(dateTime);
    return dag.substring(0, 3);
  }

  int _getYearFromSchemaId(String trainerSchemaId) {
    List<String> tokens = trainerSchemaId.split('_');
    if (tokens.length < 2) {
      lp("!! dit kan niet _getYearFromSchemaId $trainerSchemaId");
      return 2024;
    } else {
      return int.parse(tokens[1]);
    }
  }

  int _getMonthFromSchemaId(String trainerSchemaId) {
    List<String> tokens = trainerSchemaId.split('_');
    if (tokens.length < 3) {
      lp("!! dit kan niet _getMonthFromSchemaId $trainerSchemaId");
      return 1;
    } else {
      return int.parse(tokens[2]);
    }
  }
}

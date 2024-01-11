import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_constants.dart';
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

  ///---------------------------------------
  int getActiveDateIndex(DateTime dateTime) {
    for (int i = 0; i < AppData.instance.getActiveDates().length; i++) {
      if (dateTime == AppData.instance.getActiveDates()[i]) {
        return i;
      }
    }
    return -1; //this should not be possible
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
  TrainerSchema buildNewSchemaForTrainer(Trainer trainer) {
    TrainerSchema result = TrainerSchema.ofTrainer(trainer: trainer);

    for (DateTime dateTime in AppData.instance.getActiveDates()) {
      int avail = trainer.getDayPrefValue(weekday: dateTime.weekday);
      result.availableList.add(avail);
    }
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
  /// return something like: 'din 1'
  String weekDayStringFromDate(
      {required DateTime date, required String locale, int length = -1}) {
    String weekdayStr = DateFormat.EEEE(locale).format(date);
    if (length > 0) {
      weekdayStr = weekdayStr.substring(0, length);
    }
    weekdayStr += ' ${date.day}';
    return weekdayStr;
  }

  /// ------------------------
  String weekDayStringFromWeekday(
      {required int weekday, required String locale}) {
    if (locale == AppConstants().localUK) {
      if (weekday == DateTime.monday) {
        return 'monday';
      } else if (weekday == DateTime.tuesday) {
        return 'tuesday';
      } else if (weekday == DateTime.tuesday) {
        return 'tuesday';
      } else if (weekday == DateTime.wednesday) {
        return 'wednesday';
      } else if (weekday == DateTime.thursday) {
        return 'thursday';
      } else if (weekday == DateTime.friday) {
        return 'friday';
      } else if (weekday == DateTime.saturday) {
        return 'saturday';
      } else if (weekday == DateTime.sunday) {
        return 'sunday';
      }
    } else {
      if (weekday == DateTime.monday) {
        return 'maandag';
      } else if (weekday == DateTime.tuesday) {
        return 'dinsdag';
      } else if (weekday == DateTime.tuesday) {
        return 'woensdag';
      } else if (weekday == DateTime.wednesday) {
        return 'woensdag';
      } else if (weekday == DateTime.thursday) {
        return 'donderdag';
      } else if (weekday == DateTime.friday) {
        return 'vrijdag';
      } else if (weekday == DateTime.saturday) {
        return 'zaterdag';
      } else if (weekday == DateTime.sunday) {
        return 'zondag';
      }
    }
    return '???';
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

  String _getShortWeekDay(DateTime dateTime) {
    String dag =
        weekDayStringFromDate(date: dateTime, locale: c.localNL, length: 3);
    return dag.substring(0, 3);
  }
}

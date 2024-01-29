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
import 'package:rooster/util/spreadsheet_generator.dart';

class AppHelper with AppMixin {
  AppHelper._();
  static final AppHelper instance = AppHelper._();

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
  AvailableCounts getAvailableCounts(
      int rowIndex, String groupName, DateTime dateTime) {
    int groupIndex =
        SpreadsheetGenerator.instance.getGroupIndex(groupName, dateTime);
    SpreadSheet spreadsheet = AppData.instance.getSpreadsheet();
    if (rowIndex < spreadsheet.rows.length - 1) {
      SheetRow sheetRow = spreadsheet.rows[rowIndex];
      if (!sheetRow.isExtraRow) {
        return AppData.instance
            .getSpreadsheet()
            .rows[rowIndex]
            .rowCells[groupIndex]
            .availableCounts;
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
  DateTime addMonths(DateTime date, int nMonths) {
    DateTime result = date;
    for (int i = 0; i < nMonths; i++) {
      result = add1Month(result);
    }
    return result;
  }

  DateTime add1Month(DateTime date) {
    if (date.month == 12) {
      return DateTime(date.year + 1, 1, 1);
    } else {
      return DateTime(date.year, date.month + 1, 1);
    }
  }

  // return something like "Din 9" , which can be used to set label
  String getSimpleDayString(DateTime dateTime) {
    String weekday = _getShortWeekDay(dateTime);
    String day = dateTime.day.toString();
    return '$weekday $day';
  }

  /// return something like: 'din 1' or 'vrijdag 1'
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
    DateTime dateTime = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime dt = DateTime(AppData.instance.getActiveYear(),
          AppData.instance.getActiveMonth(), i);
      if (dt.weekday == weekday) {
        dateTime = dt;
        break;
      }
    }

    return DateFormat.EEEE(locale).format(dateTime);
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
  int getAvailability(Trainer trainer, int rowIndex) {
    TrainerData? trainerData = AppData.instance
        .getAllTrainerData()
        .firstWhereOrNull((e) => e.trainer == trainer);

    if (trainerData != null && !trainerData.trainerSchemas.isEmpty()) {
      return trainerData.trainerSchemas.availableList[rowIndex];
    }
    return 0;
  }

  ///---------------------------------------------
  List<Trainer> getAllSupervisors() {
    return AppData.instance
        .getAllTrainers()
        .where((e) => e.isSupervisor())
        .toList();
  }

  ///---------------------------------------------
  Trainer findTrainerByFirstName(String name) {
    Trainer? trainer = AppData.instance.getAllTrainers().firstWhereOrNull(
        (e) => e.firstName().toLowerCase() == name.toLowerCase());

    if (trainer != null) {
      return trainer;
    } else {
      return Trainer.empty();
    }
  }

  ///---------------------------------------------
  String getAuthPassword(Trainer trainer) {
    return 'pwd${trainer.accessCode}!678123';
  }

  /// -------- private methods --------------------------------

  String _getShortWeekDay(DateTime dateTime) {
    String dag =
        weekDayStringFromDate(date: dateTime, locale: c.localNL, length: 3);
    return dag.substring(0, 3);
  }
}

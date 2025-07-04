import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/firestore_helper.dart';
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
  String buildTrainerSchemaId(Trainer trainer) {
    String result = trainer.pk;
    result += '_${AppData.instance.getActiveYear()}';
    result += '_${AppData.instance.getActiveMonth()}';
    return result;
  }

  ///----------------------------------------
  String buildTrainerSchemaIdFromMap(Map<String, dynamic> map) {
    String result = "";
    result += map["trainerPk"];
    result += '_${map["year"]}';
    result += '_${map["month"]}';
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
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 1);
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays - 1; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  ///----------------------------------------//------------------
  DateTime getLastDayOfMonth(DateTime startDate) {
    List<DateTime> days = getDaysInBetween(startDate);
    return days[days.length - 1];
  }

  ///----------------------------------------//------------------
  AvailableCounts getAvailableCounts(
      int rowIndex, String groupName, DateTime dateTime) {
    try {
      int groupIndex =
          SpreadsheetGenerator.instance.getGroupIndex(groupName, dateTime);

      if (groupIndex >= 0) {
        SpreadSheet spreadsheet = AppData.instance.getSpreadsheet();
        if (rowIndex < spreadsheet.rows.length) {
          SheetRow sheetRow = spreadsheet.rows[rowIndex];
          if (!sheetRow.isExtraRow &&
              spreadsheet.rows[rowIndex].rowCells.length > groupIndex) {
            return spreadsheet
                .rows[rowIndex].rowCells[groupIndex].availableCounts;
          }
        }
      }
    } catch (ex, stackTrace) {
      FirestoreHelper.instance.handleError(ex, stackTrace);
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
  /// return something like: 'vrijdag' if locale is nl
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

  /// ------------------------
  /// weekdayFromString('dinsdag', 'nl') -> 2
  int weekdayFromString({required String weekday, required String locale}) {
    for (int i = 0; i < 7; i++) {
      DateTime dt = DateTime(AppData.instance.getActiveYear(),
          AppData.instance.getActiveMonth(), i);

      String weekdayStr = DateFormat.EEEE(locale).format(dt);
      if (weekdayStr == weekday) {
        return dt.weekday;
      }
    }
    return -1; //not possible
  }

  ///------------------------------------
  String formatDate(DateTime dateTime) {
    return dateTime.toIso8601String().substring(0, 10);
  }

  ///-----------------------------------
  bool isDateExcluded(DateTime date) {
    SpecialDay? excludeDay = AppData.instance.specialDays.excludeDays
        .firstWhereOrNull((e) =>
            e.dateTime.day == date.day &&
            e.dateTime.month == date.month &&
            e.dateTime.year == date.year);
    return excludeDay != null ? true : false;
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
    String prefix = c.passwordPrefix;
    String suffix = c.passwordSuffix;
    return '$prefix${trainer.originalAccessCode}$suffix';
  }

  ///---------------------------------------------
  List<Trainer> getAllAdmins() {
    return AppData.instance.getAllTrainers().where((t) => t.isAdmin()).toList();
  }

  ///---------------------------------------------
  List<Trainer> getAllSupervisors() {
    return AppData.instance
        .getAllTrainers()
        .where((t) => t.isSupervisor())
        .toList();
  }

  ///---------------------------------------------
  bool addSchemaEditRow(DateTime date, Trainer trainer) {
    if (date.weekday == DateTime.saturday) {
      int dayPref = trainer.getDayPrefValue(weekday: date.weekday);
      return dayPref > 0;
    } else {
      return true;
    }
  }

  ///---------------------------------------------
  TrainingGroup? getTrainingGroupByName(String groupName) {
    return AppData.instance.trainingGroups.firstWhereOrNull(
        (e) => e.name.toLowerCase() == groupName.toLowerCase());
  }

  /// -------- private methods --------------------------------

  String _getShortWeekDay(DateTime dateTime) {
    String dag =
        weekDayStringFromDate(date: dateTime, locale: c.localNL, length: 3);
    return dag.substring(0, 2);
  }
}

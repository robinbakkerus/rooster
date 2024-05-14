import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/util/app_constants.dart';
import 'package:rooster/util/app_helper.dart';

//------------------ enum ----------------------

enum LogAction {
  saveSchema,
  modifySchema,
  modifySettings,
  saveSpreadsheet,
  finalizeSpreadsheet,
  modifyTrainerField;
}

enum PageEnum {
  splashPage(0),
  askAccessCode(1),
  editSchema(2),
  trainerSettings(3),
  spreadSheet(4),
  progess(5),
  availability(6),
  helpPage(7),
  adminPage(8),
  errorPage(9),
  supervisorPage(10);

  const PageEnum(this.code);
  final int code;
}

enum RunMode {
  prod,
  acc,
  dev;
}

enum SpreadsheetStatus {
  old,
  underConstruction,
  active,
  opened,
  dirty;
}

enum TrainingGroupType {
  regular,
  special; //zamo, summer, starters

  String toMap() {
    return name;
  }

  factory TrainingGroupType.fromMap(String type) {
    switch (type) {
      case 'regular':
        return TrainingGroupType.regular;
      case 'special':
        return TrainingGroupType.special;
      default:
        return TrainingGroupType.regular;
    }
  }
}

///-----------------------------------------
class TrainerPref {
  final String paramName;
  int value;

  TrainerPref({
    required this.paramName,
    required this.value,
  });

  TrainerPref copyWith({
    String? paramName,
    int? value,
  }) {
    return TrainerPref(
      paramName: paramName ?? this.paramName,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paramName': paramName,
      'value': value,
    };
  }

  factory TrainerPref.fromMap(Map<String, dynamic> map) {
    return TrainerPref(
      paramName: map['paramName'],
      value: map['value'],
    );
  }

  @override
  String toString() => 'TrainerPref(paramName: $paramName, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainerPref &&
        other.paramName == paramName &&
        other.value == value;
  }

  @override
  int get hashCode => paramName.hashCode ^ value.hashCode;
}

///------------------------------------------

class Trainer {
  String accessCode;
  final String originalAccessCode;
  final String pk; // this is also the firestore dbs ID
  final String fullname;
  String email;
  String originalEmail;
  List<TrainerPref> prefValues = [];
  final String roles;

  Trainer({
    required this.accessCode,
    required this.originalAccessCode,
    required this.pk,
    required this.fullname,
    required this.email,
    required this.originalEmail,
    required this.prefValues,
    required this.roles,
  });

  Trainer copyWith({
    String? accessCode,
    String? originalAccessCode,
    String? pk,
    String? fullname,
    String? email,
    String? originalEmail,
    List<TrainerPref>? prefValues,
    String? roles,
  }) {
    return Trainer(
      accessCode: accessCode ?? this.accessCode,
      originalAccessCode: originalAccessCode ?? this.originalAccessCode,
      pk: pk ?? this.pk,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      originalEmail: originalEmail ?? this.originalEmail,
      prefValues:
          prefValues ?? this.prefValues.map((e) => e.copyWith()).toList(),
      roles: roles ?? this.roles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessCode': accessCode,
      'originalAccessCode': originalAccessCode,
      'pk': pk,
      'fullname': fullname,
      'email': email,
      'originalEmail': originalEmail,
      'prefValues': prefValues.map((x) => x.toMap()).toList(),
      'roles': roles,
    };
  }

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      accessCode: map['accessCode'],
      originalAccessCode: map['originalAccessCode'],
      pk: map['pk'],
      fullname: map['fullname'],
      email: map['email'],
      originalEmail: map['originalEmail'],
      prefValues: List<TrainerPref>.from(
          map['prefValues']?.map((x) => TrainerPref.fromMap(x))),
      roles: map['roles'],
    );
  }

  String toJson() => json.encode(toMap());
  factory Trainer.fromJson(String source) =>
      Trainer.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Trainer(pk: $pk, fullname: $fullname, accessCode: $accessCode, orgCode: $originalAccessCode email: $email, originalEmail: $originalEmail,prefs: $prefValues, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trainer &&
        other.accessCode == accessCode &&
        other.originalAccessCode == originalAccessCode &&
        other.pk == pk &&
        other.fullname == fullname &&
        other.email == email &&
        other.originalEmail == originalEmail &&
        listEquals(other.prefValues, prefValues) &&
        other.roles == roles;
  }

  @override
  int get hashCode {
    return accessCode.hashCode ^
        originalAccessCode.hashCode ^
        pk.hashCode ^
        fullname.hashCode ^
        email.hashCode ^
        originalEmail.hashCode ^
        prefValues.hashCode ^
        roles.hashCode;
  }

  /// ---- extra methods -------------
  factory Trainer.empty() {
    return Trainer(
        accessCode: '',
        originalAccessCode: '',
        pk: '',
        fullname: '',
        email: '',
        originalEmail: '',
        prefValues: [],
        roles: '');
  }

  //--- not generated
  bool isEmpty() {
    return pk.isEmpty;
  }

  String firstName() {
    List<String> tokens = fullname.split(' ');
    if (tokens.isNotEmpty) {
      return tokens[0];
    } else {
      return fullname;
    }
  }

  bool isSupervisor() {
    return roles.contains(RegExp('S'));
  }

  bool isAdmin() {
    return roles.contains(RegExp('A'));
  }

  int getPrefValue({required String paramName}) {
    for (TrainerPref pref in prefValues) {
      if (pref.paramName.toLowerCase() == paramName.toLowerCase()) {
        return pref.value;
      }
    }
    return -1;
  }

  int getDayPrefValue({required int weekday}) {
    int result = -1;

    for (TrainerPref pref in prefValues) {
      String weekDayStr = AppHelper.instance
          .weekDayStringFromWeekday(
              weekday: weekday, locale: AppConstants().localNL)
          .toLowerCase();
      if (pref.paramName == weekDayStr) {
        return pref.value;
      }
    }
    return result;
  }

  void setPrefValue(String paramName, int value) {
    for (TrainerPref pref in prefValues) {
      if (pref.paramName == paramName) {
        pref.value = value;
        return;
      }
    }
  }
}

/// ----- TrainerSchemas ------------------------------
///

class TrainerSchema {
  final String id;
  final String trainerPk;
  final int year;
  final int month;
  List<int> availableList = [];
  bool? isNew = true;
  DateTime? created;
  DateTime? modified;

  bool isEmpty() {
    return id.isEmpty;
  }

  TrainerSchema({
    required this.id,
    required this.trainerPk,
    required this.year,
    required this.month,
    required this.availableList,
    this.isNew,
    this.created,
    this.modified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainerPk': trainerPk,
      'year': year,
      'month': month,
      'availabilities': availableList,
      'isNew': isNew,
      'created': created?.millisecondsSinceEpoch,
      'modified': modified?.millisecondsSinceEpoch,
    };
  }

  factory TrainerSchema.fromMap(Map<String, dynamic> map) {
    return TrainerSchema(
        id: map['id'],
        trainerPk: map['trainerPk'],
        year: map['year'],
        month: map['month'],
        availableList: List<int>.from(map['availabilities']),
        isNew: map['isNew'],
        created: AppHelper.instance.parseDateTime(map['created']),
        modified: AppHelper.instance.parseDateTime(map['modified']));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainerSchema && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  factory TrainerSchema.empty() {
    return TrainerSchema(
        id: '',
        trainerPk: '',
        year: 2024,
        month: 1,
        availableList: [],
        isNew: true,
        modified: null);
  }

  factory TrainerSchema.ofTrainer({required Trainer trainer}) {
    String id = AppHelper.instance.buildTrainerSchemaId(trainer);
    return TrainerSchema(
        id: id,
        trainerPk: trainer.pk,
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth(),
        availableList: [],
        isNew: true,
        modified: null,
        created: DateTime.now());
  }

  @override
  String toString() {
    return 'TrainerSchema(id: $id, trainerPk: $trainerPk, year: $year, month: $month, isNew: $isNew, created: $created, modified: $modified)';
  }

  String toJson() => json.encode(toMap());
  factory TrainerSchema.fromJson(String source) =>
      TrainerSchema.fromMap(json.decode(source));
}

///----------

class TrainerData {
  Trainer trainer = Trainer.empty();
  TrainerSchema trainerSchemas = TrainerSchema.empty();

  bool isEmpty() {
    return trainer.accessCode.isEmpty;
  }

  factory TrainerData.empty() {
    return TrainerData();
  }

  TrainerData();
}

///---------------------------

class AvailableCounts {
  List<Trainer> available = [];
  List<Trainer> availableBnye = []; //but not yet entered
  List<Trainer> ifNeeded = [];
  List<Trainer> ifNeededBnye = [];
  List<Trainer> notAvailable = [];
  List<Trainer> notAvailableBnye = [];

  List<Trainer> getAllTrainers() {
    List<Trainer> result = [];
    result.addAll(available);
    result.addAll(availableBnye);
    result.addAll(ifNeeded);
    result.addAll(ifNeededBnye);
    return result;
  }

  @override
  String toString() {
    return 'AvailableCounts(available: $available, availableBnye: $availableBnye, ifNeeded: $ifNeeded, ifNeededBnye: $ifNeededBnye, notAvailable: $notAvailable, notAvailableBnye: $notAvailableBnye)';
  }
}

///------------------------------------------
class Available {
  DateTime date;
  List<AvailableCounts> counts = [];

  Available({required this.date, required int groupCount}) {
    for (int i = 0; i < groupCount; i++) {
      List<AvailableCounts> counts = [];
      counts.add(AvailableCounts());
    }
  }

  @override
  String toString() {
    return 'Available(date: $date ';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Available && other.date == date;
  }

  @override
  int get hashCode {
    return date.hashCode;
  }
}

///-------- PlanRankValues

class MetaPlanRankValues {
  List<PlanRankStartValue> startValues = [];
  List<PlanRankStartValue> zamoStartValues = [];
  double onlyIfNeeded = -15;
  // the first [0] value is the default value, the [1] value means 1 training day before etc
  List<double> alreadyScheduled = [];

  MetaPlanRankValues({
    required this.startValues,
    required this.zamoStartValues,
    required this.onlyIfNeeded,
    required this.alreadyScheduled,
  });

  Map<String, dynamic> toMap() {
    return {
      'startValues': startValues.map((x) => x.toMap()).toList(),
      'zamoStartValues': zamoStartValues.map((x) => x.toMap()).toList(),
      'onlyIfNeeded': onlyIfNeeded,
      'alreadyScheduled': alreadyScheduled,
    };
  }

  factory MetaPlanRankValues.fromMap(Map<String, dynamic> map) {
    return MetaPlanRankValues(
      startValues: List<PlanRankStartValue>.from(
          map['startValues']?.map((x) => PlanRankStartValue.fromMap(x))),
      zamoStartValues: List<PlanRankStartValue>.from(
          map['zamoStartValues']?.map((x) => PlanRankStartValue.fromMap(x))),
      onlyIfNeeded: map['onlyIfNeeded'],
      alreadyScheduled: List<double>.from(map['alreadyScheduled']),
    );
  }

  @override
  String toString() {
    return 'PlanRankValues(startValues: $startValues, zamoStartValues: $zamoStartValues, onlyIfNeeded: $onlyIfNeeded, alreadyScheduled: $alreadyScheduled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MetaPlanRankValues &&
        listEquals(other.startValues, startValues) &&
        listEquals(other.zamoStartValues, zamoStartValues) &&
        other.onlyIfNeeded == onlyIfNeeded &&
        listEquals(other.alreadyScheduled, alreadyScheduled);
  }

  @override
  int get hashCode {
    return startValues.hashCode ^
        zamoStartValues.hashCode ^
        onlyIfNeeded.hashCode ^
        alreadyScheduled.hashCode;
  }

  MetaPlanRankValues copyWith({
    List<PlanRankStartValue>? startValues,
    List<PlanRankStartValue>? zamoStartValues,
    double? onlyIfNeeded,
    List<double>? alreadyScheduled,
  }) {
    return MetaPlanRankValues(
      startValues: startValues ?? this.startValues,
      zamoStartValues: zamoStartValues ?? this.zamoStartValues,
      onlyIfNeeded: onlyIfNeeded ?? this.onlyIfNeeded,
      alreadyScheduled: alreadyScheduled ?? this.alreadyScheduled,
    );
  }
}

///------------ PlanRankStartValue
class PlanRankStartValue {
  final String trainerPk;
  final double value;

  PlanRankStartValue({
    required this.trainerPk,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'trainerPk': trainerPk,
      'value': value,
    };
  }

  factory PlanRankStartValue.fromMap(Map<String, dynamic> map) {
    return PlanRankStartValue(
      trainerPk: map['trainerPk'],
      value: map['value'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlanRankStartValue &&
        other.trainerPk == trainerPk &&
        other.value == value;
  }

  @override
  int get hashCode => trainerPk.hashCode ^ value.hashCode;
}

///------- Spreadsheet

class SpreadSheet {
  int year = 2024;
  int month = 1;
  SpreadsheetStatus status = SpreadsheetStatus.underConstruction;
  List<SheetRow> rows = [];

  void addRow(SheetRow row) {
    rows.add(row);
  }

  SpreadSheet({
    required this.year,
    required this.month,
  });

  SpreadSheet clone() {
    SpreadSheet result = SpreadSheet(year: year, month: month);
    result.status = status;
    for (SheetRow row in rows) {
      result.rows.add(row.clone());
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpreadSheet &&
        other.year == year &&
        other.month == month &&
        other.status == status &&
        listEquals(other.rows, rows);
  }

  @override
  int get hashCode {
    return year.hashCode ^ month.hashCode ^ status.hashCode ^ rows.hashCode;
  }

  @override
  String toString() {
    return 'SpreadSheet(year: $year, month: $month, isFinal: $status, rows: $rows)';
  }
}

//----------------------
class SheetRow {
  final int rowIndex;
  final DateTime date;
  String trainingText = '';
  bool isExtraRow = false;
  List<RowCell> rowCells = [];

  SheetRow({
    required this.rowIndex,
    required this.date,
    required this.isExtraRow,
  });

  Trainer getTrainerByGroupIndex(int groupIndex) {
    if (rowCells.isNotEmpty) {
      return rowCells[groupIndex].getTrainer();
    } else {
      return Trainer.empty();
    }
  }

  SheetRow clone() {
    SheetRow result =
        SheetRow(rowIndex: rowIndex, date: date, isExtraRow: isExtraRow);
    result.trainingText = trainingText;
    for (RowCell cell in rowCells) {
      result.rowCells.add(cell.clone());
    }
    return result;
  }

  @override
  String toString() {
    return 'SheetRow(rowIndex: $rowIndex, date: $date, trainingText: $trainingText, isExtraRow: $isExtraRow, rowCells: $rowCells)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SheetRow &&
        other.rowIndex == rowIndex &&
        other.date == date &&
        other.trainingText == trainingText &&
        other.isExtraRow == isExtraRow &&
        listEquals(other.rowCells, rowCells);
  }

  @override
  int get hashCode {
    return rowIndex.hashCode ^
        date.hashCode ^
        trainingText.hashCode ^
        isExtraRow.hashCode ^
        rowCells.hashCode;
  }
}

///------------ RowCell -------

class RowCell {
  final int rowIndex;
  final int colIndex;
  AvailableCounts availableCounts = AvailableCounts();
  List<TrainerPlanningRank> trainerRanks = [];
  Trainer _trainer = Trainer.empty();
  String text = '';

  RowCell({required this.rowIndex, required this.colIndex});

  void setTrainer(Trainer trainer) {
    _trainer = trainer;
    text = trainer.firstName();
  }

  Trainer getTrainer() => _trainer;

  RowCell clone() {
    RowCell result = RowCell(rowIndex: rowIndex, colIndex: colIndex);
    result.setTrainer(getTrainer());
    result.text = text;
    result.availableCounts =
        availableCounts; // we dont need to clone these onea
    result.trainerRanks = trainerRanks; // and this one
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RowCell &&
        other.rowIndex == rowIndex &&
        other.colIndex == colIndex &&
        other.text == text;
  }

  @override
  int get hashCode {
    return rowIndex.hashCode ^ colIndex.hashCode ^ text.hashCode;
  }

  @override
  String toString() {
    return 'RowCell(rowIndex: $rowIndex, colIndex: $colIndex, ranks: $trainerRanks, text: $text)';
  }
}

///----------- LastRosterFinal -----

class LastRosterFinal {
  final DateTime at;
  final String by;
  final int year;
  final int month;
  LastRosterFinal({
    required this.at,
    required this.by,
    required this.year,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'at': at.millisecondsSinceEpoch,
      'by': by,
      'year': year,
      'month': month,
    };
  }

  factory LastRosterFinal.fromMap(Map<String, dynamic> map) {
    return LastRosterFinal(
      at: AppHelper.instance.parseDateTime(map['at'])!,
      by: map['by'],
      year: map['year'],
      month: map['month'],
    );
  }

  @override
  String toString() {
    return 'LastRosterFinal(at: $at, by: $by, year: $year, month: $month)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LastRosterFinal &&
        other.at == at &&
        other.by == by &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    return at.hashCode ^ by.hashCode ^ year.hashCode ^ month.hashCode;
  }
}

//--------------

class TrainerPlanningRank {
  final Trainer trainer;
  double rank = 100.0;
  TrainerPlanningRank({
    required this.trainer,
    required this.rank,
  });

  @override
  String toString() {
    return 'TW( ${trainer.firstName()}=$rank';
  }
}

///-------------------------------

class FsSpreadsheet {
  int year = 2024;
  int month = 1;
  List<FsSpreadsheetRow> rows = [];
  bool isFinal = false;
  FsSpreadsheet({
    required this.year,
    required this.month,
    required this.rows,
    required this.isFinal,
  });

  String getID() {
    return '${year}_$month';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'rows': rows.map((x) => x.toMap()).toList(),
      'isFinal': isFinal,
    };
  }

  factory FsSpreadsheet.fromMap(Map<String, dynamic> map) {
    return FsSpreadsheet(
      year: map['year'] as int,
      month: map['month'] as int,
      rows: List<FsSpreadsheetRow>.from(
        (map['rows'] as List<dynamic>).map<FsSpreadsheetRow>(
          (x) => FsSpreadsheetRow.fromMap(x),
        ),
      ),
      isFinal: map['isFinal'] as bool,
    );
  }

  @override
  String toString() => 'FsSpreadsheet(year: $year, month: $month, rows: $rows)';

  @override
  bool operator ==(covariant FsSpreadsheet other) {
    if (identical(this, other)) return true;

    return other.year == year &&
        other.month == month &&
        listEquals(other.rows, rows);
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ rows.hashCode;
}

//------------------------------------------------
class FsSpreadsheetRow {
  DateTime date = DateTime.now();
  String trainingText = '';
  bool isExtraRow = false;
  List<String> rowCells = [];
  FsSpreadsheetRow({
    required this.date,
    required this.trainingText,
    required this.isExtraRow,
    required this.rowCells,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'trainingText': trainingText,
      'isExtraRow': isExtraRow,
      'rowCells': rowCells,
    };
  }

  factory FsSpreadsheetRow.fromMap(Map<String, dynamic> map) {
    return FsSpreadsheetRow(
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        trainingText: map['trainingText'] as String,
        isExtraRow: map['isExtraRow'] as bool,
        rowCells: List<String>.from(
          (map['rowCells'] as List<dynamic>),
        ));
  }

  @override
  String toString() =>
      'FsSpreadsheetRow(trainingText: $trainingText, isExtraRow: $isExtraRow, rowCells: $rowCells)';

  @override
  bool operator ==(covariant FsSpreadsheetRow other) {
    if (identical(this, other)) return true;

    return other.trainingText == trainingText &&
        other.isExtraRow == isExtraRow &&
        listEquals(other.rowCells, rowCells);
  }

  @override
  int get hashCode =>
      trainingText.hashCode ^ isExtraRow.hashCode ^ rowCells.hashCode;
}

///-----------------------------

class SpreedsheetDiff {
  DateTime date;
  String column;
  String oldValue;
  String newValue;

  SpreedsheetDiff({
    required this.date,
    required this.column,
    required this.oldValue,
    required this.newValue,
  });
}

///-------------------------------

class TrainingGroup {
  final String name;
  final String description;
  final TrainingGroupType type;
  List<int> trainingDays = []; // take into account weekdays
  String defaultTrainingText;
  //-- these are set by AppController
  SpecialPeriod? _summerPeriod;
  DateTime? _startDate;
  DateTime? _endDate;

  TrainingGroup({
    required this.name,
    required this.description,
    required this.type,
    required this.trainingDays,
    required this.defaultTrainingText,
  });

  DateTime getStartDate() {
    return _startDate ?? DateTime(2024, 1, 1);
  }

  void setStartDate(DateTime date) {
    _startDate = date;
  }

  DateTime getEndDate() {
    return _endDate ?? DateTime(2099, 1, 1);
  }

  void setEndDate(DateTime date) {
    _endDate = date;
  }

  SpecialPeriod getSummerPeriod() {
    return _summerPeriod ??
        SpecialPeriod(fromDate: DateTime.now(), toDate: DateTime.now());
  }

  void setSummerPeriod(SpecialPeriod summerPeriod) {
    _summerPeriod = summerPeriod;
  }

  TrainingGroup copyWith({
    String? name,
    String? description,
    TrainingGroupType? type,
    List<int>? trainingDays,
    String? defaultTrainingText,
  }) {
    return TrainingGroup(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      trainingDays: trainingDays ?? this.trainingDays,
      defaultTrainingText: defaultTrainingText ?? this.defaultTrainingText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toMap(),
      'trainingDays': trainingDays,
      'defaultTrainingText': defaultTrainingText,
    };
  }

  factory TrainingGroup.fromMap(Map<String, dynamic> map) {
    return TrainingGroup(
      name: map['name'],
      description: map['description'],
      type: TrainingGroupType.fromMap(map['type']),
      trainingDays: List<int>.from(map['trainingDays']),
      defaultTrainingText: map['defaultTrainingText'],
    );
  }
  String toJson() => json.encode(toMap());
  factory TrainingGroup.fromJson(String source) =>
      TrainingGroup.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TrainingGroup(name: $name, description: $description, startDate: $getStartDate(), endDate: $getEndDate(), type: $type, trainingDays: $trainingDays,  defaultTrainingText: $defaultTrainingText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingGroup &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        listEquals(other.trainingDays, trainingDays) &&
        other.defaultTrainingText == defaultTrainingText;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        type.hashCode ^
        trainingDays.hashCode ^
        defaultTrainingText.hashCode;
  }
}

///-----------------------------
class SpecialPeriod {
  final DateTime fromDate;
  final DateTime toDate;
  SpecialPeriod({
    required this.fromDate,
    required this.toDate,
  });

  bool isValid() {
    return fromDate != toDate;
  }

  SpecialPeriod clone() {
    return SpecialPeriod(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  SpecialPeriod copyWith({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return SpecialPeriod(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromDate': fromDate.millisecondsSinceEpoch,
      'toDate': toDate.millisecondsSinceEpoch,
    };
  }

  factory SpecialPeriod.fromMap(Map<String, dynamic> map) {
    return SpecialPeriod(
      fromDate: AppHelper.instance.parseDateTime(map['fromDate'])!,
      toDate: AppHelper.instance.parseDateTime(map['toDate'])!,
    );
  }

  factory SpecialPeriod.empty() {
    return SpecialPeriod(
        fromDate: DateTime(2024, 1, 1), toDate: DateTime(2024, 1, 1));
  }

  bool isEmpty() {
    return fromDate == toDate;
  }

  @override
  String toString() => 'SummerPeriod(fromDate: $fromDate, toDate: $toDate)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpecialPeriod &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode => fromDate.hashCode ^ toDate.hashCode;
}

///--------------------------------
class SpecialDay {
  final DateTime dateTime;
  final String description;

  SpecialDay({
    required this.dateTime,
    required this.description,
  });
  SpecialDay copyWith({
    DateTime? dateTime,
    String? description,
  }) {
    return SpecialDay(
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
    );
  }

  SpecialDay clone() {
    return SpecialDay(
      dateTime: dateTime,
      description: description,
    );
  }

  factory SpecialDay.empty() {
    return SpecialDay(dateTime: DateTime(2000, 1, 1), description: '');
  }

  bool isValid() {
    return dateTime.year > 2023 && description.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory SpecialDay.fromMap(Map<String, dynamic> map) {
    return SpecialDay(
      dateTime: AppHelper.instance.parseDateTime(map['dateTime'])!,
      description: map['description'],
    );
  }
  String toJson() => json.encode(toMap());
  factory SpecialDay.fromJson(String source) =>
      SpecialDay.fromMap(json.decode(source));
  @override
  String toString() => 'ExcludeDay(data: $dateTime, description: $description)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpecialDay &&
        other.dateTime == dateTime &&
        other.description == description;
  }

  @override
  int get hashCode => dateTime.hashCode ^ description.hashCode;
}

//-----------------------------------------------------
class SpecialDays {
  final List<SpecialDay> excludeDays;
  final SpecialPeriod summerPeriod;
  final SpecialPeriod startersGroup;

  SpecialDays({
    required this.excludeDays,
    required this.summerPeriod,
    required this.startersGroup,
  });

  bool isValid() {
    SpecialDay? invalidSpecialDay =
        excludeDays.firstWhereOrNull((e) => !e.isValid());
    return summerPeriod.isValid() && invalidSpecialDay == null;
  }

  SpecialDays clone() {
    return SpecialDays(
      excludeDays: List.from(excludeDays),
      summerPeriod: summerPeriod.clone(),
      startersGroup: startersGroup.clone(),
    );
  }

  SpecialDays copyWith({
    List<SpecialDay>? excludeDays,
    SpecialPeriod? summerPeriod,
    SpecialPeriod? startersGroup,
  }) {
    return SpecialDays(
      excludeDays: excludeDays ?? this.excludeDays,
      summerPeriod: summerPeriod ?? this.summerPeriod,
      startersGroup: startersGroup ?? this.startersGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'excludeDays': excludeDays.map((x) => x.toMap()).toList(),
      'summerPeriod': summerPeriod.toMap(),
      'startersGroup': startersGroup.toMap(),
    };
  }

  factory SpecialDays.fromMap(Map<String, dynamic> map) {
    return SpecialDays(
      excludeDays: List<SpecialDay>.from(
          map['excludeDays']?.map((x) => SpecialDay.fromMap(x))),
      summerPeriod: SpecialPeriod.fromMap(map['summerPeriod']),
      startersGroup: SpecialPeriod.fromMap(map['startersGroup']),
    );
  }
  String toJson() => json.encode(toMap());
  factory SpecialDays.fromJson(String source) =>
      SpecialDays.fromMap(json.decode(source));
  @override
  String toString() =>
      'SpecialDays(excludeDays: $excludeDays, summerPeriod: $summerPeriod, startersGroup: $startersGroup)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpecialDays &&
        listEquals(other.excludeDays, excludeDays) &&
        other.summerPeriod == summerPeriod &&
        other.startersGroup == startersGroup;
  }

  @override
  int get hashCode =>
      excludeDays.hashCode ^ summerPeriod.hashCode ^ startersGroup.hashCode;
}

///--------------------------------
class ActiveTrainingGroup {
  final List<String> groupNames;
  final DateTime startDate;
  DateTime? endDate;
  ActiveTrainingGroup({
    required this.groupNames,
    required this.startDate,
  });
}

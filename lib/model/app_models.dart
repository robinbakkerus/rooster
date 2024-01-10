// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:rooster/data/app_data.dart';

import 'package:rooster/util/app_helper.dart';

//------------------ enum ----------------------
enum Groep {
  pr,
  r1,
  r2,
  r3,
  zamo;
}

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
  helpPage(5),
  adminPage(6);

  const PageEnum(this.code);
  final int code;
}

///------------------------------------------

class Trainer {
  final String accessCode;
  final String pk; // this is also the firestore dbs ID
  final String fullname;
  String email;
  final int dinsdag;
  final int donderdag;
  final int zaterdag;
  final int pr;
  final int r1;
  final int r2;
  final int r3;
  final int zamo;
  final String roles;

  Trainer({
    required this.accessCode,
    required this.pk,
    required this.fullname,
    required this.email,
    required this.dinsdag,
    required this.donderdag,
    required this.zaterdag,
    required this.pr,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.zamo,
    required this.roles,
  });

  Trainer copyWith({
    String? accessCode,
    String? pk,
    String? fullname,
    String? email,
    int? dinsdag,
    int? donderdag,
    int? zaterdag,
    int? pr,
    int? r1,
    int? r2,
    int? r3,
    int? zamo,
    String? roles,
  }) {
    return Trainer(
      accessCode: accessCode ?? this.accessCode,
      pk: pk ?? this.pk,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      dinsdag: dinsdag ?? this.dinsdag,
      donderdag: donderdag ?? this.donderdag,
      zaterdag: zaterdag ?? this.zaterdag,
      pr: pr ?? this.pr,
      r1: r1 ?? this.r1,
      r2: r2 ?? this.r2,
      r3: r3 ?? this.r3,
      zamo: zamo ?? this.zamo,
      roles: roles ?? this.roles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessCode': accessCode,
      'pk': pk,
      'fullname': fullname,
      'email': email,
      'dinsdag': dinsdag,
      'donderdag': donderdag,
      'zaterdag': zaterdag,
      'pr': pr,
      'r1': r1,
      'r2': r2,
      'r3': r3,
      'zamo': zamo,
      'roles': roles,
    };
  }

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      accessCode: map['accessCode'],
      pk: map['pk'],
      fullname: map['fullname'],
      email: map['email'],
      dinsdag: map['dinsdag'],
      donderdag: map['donderdag'],
      zaterdag: map['zaterdag'],
      pr: map['pr'],
      r1: map['r1'],
      r2: map['r2'],
      r3: map['r3'],
      zamo: map['zamo'],
      roles: map['roles'],
    );
  }

  @override
  String toString() {
    return 'Trainer(accessCode: $accessCode, pk: $pk, fullname: $fullname, email: $email, dinsdag: $dinsdag, donderdag: $donderdag, zaterdag: $zaterdag, pr: $pr, r1: $r1, r2: $r2, r3: $r3, zamo: $zamo, roles: $roles)';
  }

  @override
  bool operator ==(covariant Trainer other) {
    if (identical(this, other)) return true;

    return other.accessCode == accessCode &&
        other.pk == pk &&
        other.fullname == fullname &&
        other.email == email &&
        other.dinsdag == dinsdag &&
        other.donderdag == donderdag &&
        other.zaterdag == zaterdag &&
        other.pr == pr &&
        other.r1 == r1 &&
        other.r2 == r2 &&
        other.r3 == r3 &&
        other.zamo == zamo &&
        other.roles == roles;
  }

  @override
  int get hashCode {
    return accessCode.hashCode ^
        pk.hashCode ^
        fullname.hashCode ^
        email.hashCode ^
        dinsdag.hashCode ^
        donderdag.hashCode ^
        zaterdag.hashCode ^
        pr.hashCode ^
        r1.hashCode ^
        r2.hashCode ^
        r3.hashCode ^
        zamo.hashCode ^
        roles.hashCode;
  }

  factory Trainer.empty() {
    return Trainer(
        accessCode: '',
        pk: '',
        fullname: '',
        dinsdag: 0,
        donderdag: 0,
        zaterdag: 0,
        email: '',
        pr: 0,
        r1: 0,
        r2: 0,
        r3: 0,
        zamo: 0,
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
  List<Trainer> confirmed = [];
  List<Trainer> ifNeeded = [];
  List<Trainer> notEnteredYet = [];

  @override
  String toString() =>
      'AvailableCounts(confirmed: $confirmed, ifNeeded: $ifNeeded, notEnteredYet: $notEnteredYet)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AvailableCounts &&
        listEquals(other.confirmed, confirmed) &&
        listEquals(other.ifNeeded, ifNeeded) &&
        listEquals(other.notEnteredYet, notEnteredYet);
  }

  @override
  int get hashCode =>
      confirmed.hashCode ^ ifNeeded.hashCode ^ notEnteredYet.hashCode;

  List<Trainer> getAllTrainers() {
    List<Trainer> result = [];
    result.addAll(confirmed);
    result.addAll(ifNeeded);
    result.addAll(notEnteredYet);
    return result;
  }
}

///---------------------------------------------------------------------------
///
class Available {
  DateTime date;
  List<AvailableCounts> counts = [];

  Available({required this.date}) {
    for (int i = 0; i < Groep.values.length; i++) {
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

///-------- ApplyWeight

class ApplyWeightValues {
  List<ApplyWeightStartValue> startValues = [];
  double onlyIfNeeded = -15;
  // the first [0] value is the default value, the [1] value means 1 training day before etc
  List<double> alreadyScheduled = [];

  ApplyWeightValues({
    required this.startValues,
    required this.onlyIfNeeded,
    required this.alreadyScheduled,
  });

  Map<String, dynamic> toMap() {
    return {
      'startValues': startValues.map((x) => x.toMap()).toList(),
      'onlyIfNeeded': onlyIfNeeded,
      'alreadyScheduled': alreadyScheduled,
    };
  }

  factory ApplyWeightValues.fromMap(Map<String, dynamic> map) {
    return ApplyWeightValues(
      startValues: List<ApplyWeightStartValue>.from(
          map['startValues']?.map((x) => ApplyWeightStartValue.fromMap(x))),
      onlyIfNeeded: map['onlyIfNeeded'],
      alreadyScheduled: List<double>.from(map['alreadyScheduled']),
    );
  }

  @override
  String toString() =>
      'ApplyWeightValues(startValues: $startValues, onlyIfNeeded: $onlyIfNeeded, alreadyScheduled: $alreadyScheduled)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApplyWeightValues &&
        listEquals(other.startValues, startValues) &&
        other.onlyIfNeeded == onlyIfNeeded &&
        listEquals(other.alreadyScheduled, alreadyScheduled);
  }

  @override
  int get hashCode =>
      startValues.hashCode ^ onlyIfNeeded.hashCode ^ alreadyScheduled.hashCode;
}

///------------ ApplyWeightStartValue
class ApplyWeightStartValue {
  final String trainerPk;
  final double value;

  ApplyWeightStartValue({
    required this.trainerPk,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'trainerPk': trainerPk,
      'value': value,
    };
  }

  factory ApplyWeightStartValue.fromMap(Map<String, dynamic> map) {
    return ApplyWeightStartValue(
      trainerPk: map['trainerPk'],
      value: map['value'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApplyWeightStartValue &&
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
  List<String> header = ['Dag', 'Training', 'PR', 'R1', 'R2', 'R3', 'ZaMo'];
  List<SheetRow> rows = [];

  void addRow(SheetRow row) {
    rows.add(row);
  }

  SpreadSheet({
    required this.year,
    required this.month,
  });
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

  Trainer getTrainerByGroup(Groep group) {
    if (rowCells.isNotEmpty) {
      return rowCells[group.index].getTrainer();
    } else {
      return Trainer.empty();
    }
  }

  String dateStr() {
    return AppHelper.instance.getDateStringForSpreadsheet(date);
  }

  @override
  String toString() {
    return '$rowIndex, \t $date}';
  }
}

///------------ RowCell -------

class RowCell {
  final int rowIndex;
  final int colIndex;
  AvailableCounts availableCounts = AvailableCounts();
  List<TrainerWeight> trainerWeights = [];
  Trainer _trainer = Trainer.empty();
  String text = '';

  RowCell({required this.rowIndex, required this.colIndex});

  void setTrainer(Trainer trainer) {
    _trainer = trainer;
    text = trainer.firstName();
  }

  Trainer getTrainer() => _trainer;
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
      at: DateTime.fromMillisecondsSinceEpoch(map['at']),
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

class TrainerWeight {
  final Trainer trainer;
  double weight = 100.0;
  TrainerWeight({
    required this.trainer,
    required this.weight,
  });

  @override
  String toString() {
    return 'TW( ${trainer.firstName()}=$weight';
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
        (map['rows'] as List<int>).map<FsSpreadsheetRow>(
          (x) => FsSpreadsheetRow.fromMap(x as Map<String, dynamic>),
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
          (map['rowCells'] as List<String>),
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

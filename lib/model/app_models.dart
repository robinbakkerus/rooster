// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:rooster/util/app_helper.dart';

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

  String toJson() => json.encode(toMap());
  factory Trainer.fromJson(String source) =>
      Trainer.fromMap(json.decode(source));
}

//----------- DaySchema -------------

class DaySchema {
  final int year;
  final int month;
  final int day;
  int available = 1;

  DaySchema({
    required this.year,
    required this.month,
    required this.day,
    required this.available,
  });

  DaySchema copyWith({
    int? year,
    int? month,
    int? day,
    int? available,
  }) {
    return DaySchema(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      available: available ?? this.available,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'available': available,
    };
  }

  factory DaySchema.fromMap(Map<String, dynamic> map) {
    return DaySchema(
      year: map['year'],
      month: map['month'],
      day: map['day'],
      available: map['available'],
    );
  }

  String toJson() => json.encode(toMap());
  factory DaySchema.fromJson(String source) =>
      DaySchema.fromMap(json.decode(source));
  @override
  String toString() {
    return 'DS(y: $year, m: $month, d: $day, avail: $available)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DaySchema &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.available == available;
  }

  @override
  int get hashCode {
    return year.hashCode ^ month.hashCode ^ day.hashCode ^ available.hashCode;
  }
}

// ----------- TrainerAccess ---------------

class TrainerAccess {
  final Trainer trainer;
  DateTime datetime = DateTime(2024, 1, 1);

  TrainerAccess({
    required this.trainer,
  });
  TrainerAccess copyWith({
    Trainer? trainer,
  }) {
    return TrainerAccess(
      trainer: trainer ?? this.trainer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainer': trainer.toMap(),
    };
  }

  factory TrainerAccess.fromMap(Map<String, dynamic> map) {
    return TrainerAccess(
      trainer: Trainer.fromMap(map['trainer']),
    );
  }
  String toJson() => json.encode(toMap());
  factory TrainerAccess.fromJson(String source) =>
      TrainerAccess.fromMap(json.decode(source));
  @override
  String toString() => 'TrainerAccess(trainer: $trainer)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainerAccess && other.trainer == trainer;
  }

  @override
  int get hashCode => trainer.hashCode;
}

/// ----- TrainerSchemas ------------------------------
///

class TrainerSchema {
  final String id;
  final String trainerPk;
  final int year;
  final int month;
  final int din1;
  final int din2;
  final int din3;
  final int din4;
  final int din5;
  final int don1;
  final int don2;
  final int don3;
  final int don4;
  final int don5;
  final int zat1;
  final int zat2;
  final int zat3;
  final int zat4;
  final int zat5;
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
    required this.din1,
    required this.din2,
    required this.din3,
    required this.din4,
    required this.din5,
    required this.don1,
    required this.don2,
    required this.don3,
    required this.don4,
    required this.don5,
    required this.zat1,
    required this.zat2,
    required this.zat3,
    required this.zat4,
    required this.zat5,
    this.isNew,
    this.created,
    this.modified,
  });
  TrainerSchema copyWith({
    String? id,
    String? trainerPk,
    int? year,
    int? month,
    int? din1,
    int? din2,
    int? din3,
    int? din4,
    int? din5,
    int? don1,
    int? don2,
    int? don3,
    int? don4,
    int? don5,
    int? zat1,
    int? zat2,
    int? zat3,
    int? zat4,
    int? zat5,
    bool? isNew,
    DateTime? created,
    DateTime? modified,
  }) {
    return TrainerSchema(
      id: id ?? this.id,
      trainerPk: trainerPk ?? this.trainerPk,
      year: year ?? this.year,
      month: month ?? this.month,
      din1: din1 ?? this.din1,
      din2: din2 ?? this.din2,
      din3: din3 ?? this.din3,
      din4: din4 ?? this.din4,
      din5: din5 ?? this.din5,
      don1: don1 ?? this.don1,
      don2: don2 ?? this.don2,
      don3: don3 ?? this.don3,
      don4: don4 ?? this.don4,
      don5: don5 ?? this.don5,
      zat1: zat1 ?? this.zat1,
      zat2: zat2 ?? this.zat2,
      zat3: zat3 ?? this.zat3,
      zat4: zat4 ?? this.zat4,
      zat5: zat5 ?? this.zat5,
      isNew: isNew ?? this.isNew,
      created: created ?? this.created,
      modified: modified ?? this.modified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainerPk': trainerPk,
      'year': year,
      'month': month,
      'din1': din1,
      'din2': din2,
      'din3': din3,
      'din4': din4,
      'din5': din5,
      'don1': don1,
      'don2': don2,
      'don3': don3,
      'don4': don4,
      'don5': don5,
      'zat1': zat1,
      'zat2': zat2,
      'zat3': zat3,
      'zat4': zat4,
      'zat5': zat5,
      'isNew': isNew,
      'created': created,
      'modified': modified,
    };
  }

  factory TrainerSchema.fromMap(Map<String, dynamic> map) {
    return TrainerSchema(
        id: map['id'],
        trainerPk: map['trainerPk'],
        year: map['year'],
        month: map['month'],
        din1: map['din1'],
        din2: map['din2'],
        din3: map['din3'],
        din4: map['din4'],
        din5: map['din5'],
        don1: map['don1'],
        don2: map['don2'],
        don3: map['don3'],
        don4: map['don4'],
        don5: map['don5'],
        zat1: map['zat1'],
        zat2: map['zat2'],
        zat3: map['zat3'],
        zat4: map['zat4'],
        zat5: map['zat5'],
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
        din1: 1,
        din2: 1,
        din3: 1,
        din4: 1,
        din5: 1,
        don1: 1,
        don2: 1,
        don3: 1,
        don4: 1,
        don5: 1,
        zat1: 1,
        zat2: 1,
        zat3: 1,
        zat4: 1,
        zat5: 1,
        isNew: true,
        modified: null);
  }
}

///----------

class TrainerData {
  Trainer trainer = Trainer.empty();
  TrainerSchema trainerSchemas = TrainerSchema.empty();
  List<DaySchema> oldSchemas = [];
  List<DaySchema> newSchemas = [];

  bool isEmpty() {
    return trainer.accessCode.isEmpty;
  }

  factory TrainerData.empty() {
    return TrainerData();
  }

  TrainerData();
}

//------------------
enum Groep {
  pr,
  r1,
  r2,
  r3,
  zamo;
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
  int weight = 50;
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
  FsSpreadsheet({
    required this.year,
    required this.month,
    required this.rows,
  });

  String getID() {
    return '${year}_$month';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'rows': rows.map((x) => x.toMap()).toList(),
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

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firestore/util/data_parser.dart';

class Trainer {
  final String id;
  final String fullname;
  final String shortname;
  final String email;
  final int dinsdag;
  final int donderdag;
  final int zaterdag;
  final int pr;
  final int r1;
  final int r2;
  final int r3;
  final String roles;

  Trainer({
    required this.id,
    required this.fullname,
    required this.shortname,
    required this.email,
    required this.dinsdag,
    required this.donderdag,
    required this.zaterdag,
    required this.pr,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.roles,
  });

  Trainer copyWith({
    String? id,
    String? fullname,
    String? shortname,
    String? email,
    int? dinsdag,
    int? donderdag,
    int? zaterdag,
    int? pr,
    int? r1,
    int? r2,
    int? r3,
    String? roles,
  }) {
    return Trainer(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      shortname: shortname ?? this.shortname,
      email: email ?? this.email,
      dinsdag: dinsdag ?? this.dinsdag,
      donderdag: donderdag ?? this.donderdag,
      zaterdag: zaterdag ?? this.zaterdag,
      pr: pr ?? this.pr,
      r1: r1 ?? this.r1,
      r2: r2 ?? this.r2,
      r3: r3 ?? this.r3,
      roles: roles ?? this.roles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'shortname': shortname,
      'email': email,
      'dinsdag': dinsdag,
      'donderdag': donderdag,
      'zaterdag': zaterdag,
      'pr': pr,
      'r1': r1,
      'r2': r2,
      'r3': r3,
      'roles': roles,
    };
  }

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      id: map['id'],
      fullname: map['fullname'],
      shortname: map['shortname'],
      email: map['email'],
      dinsdag: map['dinsdag'],
      donderdag: map['donderdag'],
      zaterdag: map['zaterdag'],
      pr: map['pr'],
      r1: map['r1'],
      r2: map['r2'],
      r3: map['r3'],
      roles: map['roles'],
    );
  }

  factory Trainer.unknown() {
    return Trainer(
        id: '???',
        fullname: '',
        shortname: '',
        dinsdag: 0,
        donderdag: 0,
        zaterdag: 0,
        email: '',
        pr: 0,
        r1: 0,
        r2: 0,
        r3: 0,
        roles: '');
  }

  String toJson() => json.encode(toMap());
  factory Trainer.fromJson(String source) =>
      Trainer.fromMap(json.decode(source));
  @override
  String toString() {
    return 'Trainer(id: $id, fullname: $fullname, shortname: $shortname, email: $email, dinsdag: $dinsdag, donderdag: $donderdag, zaterdag: $zaterdag, pr: $pr, r1: $r1, r2: $r2, r3: $r3, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trainer &&
        other.id == id &&
        other.fullname == fullname &&
        other.shortname == shortname &&
        other.email == email &&
        other.dinsdag == dinsdag &&
        other.donderdag == donderdag &&
        other.zaterdag == zaterdag &&
        other.pr == pr &&
        other.r1 == r1 &&
        other.r2 == r2 &&
        other.r3 == r3 &&
        other.roles == roles;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullname.hashCode ^
        shortname.hashCode ^
        email.hashCode ^
        dinsdag.hashCode ^
        donderdag.hashCode ^
        zaterdag.hashCode ^
        pr.hashCode ^
        r1.hashCode ^
        r2.hashCode ^
        r3.hashCode ^
        roles.hashCode;
  }
}

//----------- DaySchema -------------

class DaySchema {
  final int year;
  final int month;
  final int day;
  int available = 1;
  final DateTime modified;

  DaySchema({
    required this.year,
    required this.month,
    required this.day,
    required this.available,
    required this.modified,
  });

  DaySchema copyWith({
    int? year,
    int? month,
    int? day,
    int? available,
    DateTime? modified,
  }) {
    return DaySchema(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      available: available ?? this.available,
      modified: modified ?? this.modified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'available': available,
      'modified': modified.millisecondsSinceEpoch,
    };
  }

  factory DaySchema.fromMap(Map<String, dynamic> map) {
    return DaySchema(
      year: map['year'],
      month: map['month'],
      day: map['day'],
      available: map['available'],
      modified: DateTime.fromMillisecondsSinceEpoch(map['modified']),
    );
  }

  String toJson() => json.encode(toMap());
  factory DaySchema.fromJson(String source) =>
      DaySchema.fromMap(json.decode(source));
  @override
  String toString() {
    return 'DaySchema(year: $year, month: $month, day: $day, available: $available, modified: $modified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DaySchema &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.available == available &&
        other.modified == modified;
  }

  @override
  int get hashCode {
    return year.hashCode ^
        month.hashCode ^
        day.hashCode ^
        available.hashCode ^
        modified.hashCode;
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

class TrainerSchemas {
  final String id;
  final int din1;
  final int din2;
  final int din3;
  final int din4;
  final int din5;
  final int don1;
  final int don2;
  final int don3;
  final int don4;
  final int zat1;
  final int zat2;
  final int zat3;
  final int zat4;
  final DateTime modified;

  TrainerSchemas({
    required this.id,
    required this.din1,
    required this.din2,
    required this.din3,
    required this.din4,
    required this.din5,
    required this.don1,
    required this.don2,
    required this.don3,
    required this.don4,
    required this.zat1,
    required this.zat2,
    required this.zat3,
    required this.zat4,
    required this.modified,
  });
  TrainerSchemas copyWith({
    String? id,
    int? din1,
    int? din2,
    int? din3,
    int? din4,
    int? din5,
    int? don1,
    int? don2,
    int? don3,
    int? don4,
    int? zat1,
    int? zat2,
    int? zat3,
    int? zat4,
    DateTime? modified,
  }) {
    return TrainerSchemas(
      id: id ?? this.id,
      din1: din1 ?? this.din1,
      din2: din2 ?? this.din2,
      din3: din3 ?? this.din3,
      din4: din4 ?? this.din4,
      din5: din5 ?? this.din5,
      don1: don1 ?? this.don1,
      don2: don2 ?? this.don2,
      don3: don3 ?? this.don3,
      don4: don4 ?? this.don4,
      zat1: zat1 ?? this.zat1,
      zat2: zat2 ?? this.zat2,
      zat3: zat3 ?? this.zat3,
      zat4: zat4 ?? this.zat4,
      modified: modified ?? this.modified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'din1': din1,
      'din2': din2,
      'din3': din3,
      'din4': din4,
      'din5': din5,
      'don1': don1,
      'don2': don2,
      'don3': don3,
      'don4': don4,
      'zat1': zat1,
      'zat2': zat2,
      'zat3': zat3,
      'zat4': zat4,
      'modified': modified.millisecondsSinceEpoch,
    };
  }

  factory TrainerSchemas.fromMap(Map<String, dynamic> map) {
    return TrainerSchemas(
        id: map['id'],
        din1: map['din1'],
        din2: map['din2'],
        din3: map['din3'],
        din4: map['din4'],
        din5: map['din5'],
        don1: map['don1'],
        don2: map['don2'],
        don3: map['don3'],
        don4: map['don4'],
        zat1: map['zat1'],
        zat2: map['zat2'],
        zat3: map['zat3'],
        zat4: map['zat4'],
        modified: DateParser.parseDateTime(map['modified']));
  }
  String toJson() => json.encode(toMap());
  factory TrainerSchemas.fromJson(String source) =>
      TrainerSchemas.fromMap(json.decode(source));
  @override
  String toString() {
    return 'TrainerSchemas(id: $id, din1: $din1, din2: $din2, din3: $din3, din4: $din4, din5: $din5, don1: $don1, don2: $don2, don3: $don3, don4: $don4, zat1: $zat1, zat2: $zat2, zat3: $zat3, zat4: $zat4, modified: $modified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainerSchemas &&
        other.id == id &&
        other.din1 == din1 &&
        other.din2 == din2 &&
        other.din3 == din3 &&
        other.din4 == din4 &&
        other.din5 == din5 &&
        other.don1 == don1 &&
        other.don2 == don2 &&
        other.don3 == don3 &&
        other.don4 == don4 &&
        other.zat1 == zat1 &&
        other.zat2 == zat2 &&
        other.zat3 == zat3 &&
        other.zat4 == zat4 &&
        other.modified == modified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        din1.hashCode ^
        din2.hashCode ^
        din3.hashCode ^
        din4.hashCode ^
        din5.hashCode ^
        don1.hashCode ^
        don2.hashCode ^
        don3.hashCode ^
        don4.hashCode ^
        zat1.hashCode ^
        zat2.hashCode ^
        zat3.hashCode ^
        zat4.hashCode ^
        modified.hashCode;
  }

  factory TrainerSchemas.empty() {
    return TrainerSchemas(
        id: '',
        din1: 0,
        din2: 0,
        din3: 0,
        din4: 0,
        din5: 0,
        don1: 0,
        don2: 0,
        don3: 0,
        don4: 0,
        zat1: 0,
        zat2: 0,
        zat3: 0,
        zat4: 0,
        modified: DateTime.now());
  }
}

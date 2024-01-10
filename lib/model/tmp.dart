import 'dart:convert';

import 'package:flutter/foundation.dart';

class TrainerSchemaX {
  final String id;
  final String trainerPk;
  final int year;
  final int month;
  final List<int> availabilities;
  bool? isNew = true;
  DateTime? created;
  DateTime? modified;

  bool isEmpty() {
    return id.isEmpty;
  }

  TrainerSchemaX({
    required this.id,
    required this.trainerPk,
    required this.year,
    required this.month,
    required this.availabilities,
    this.isNew,
    this.created,
    this.modified,
  });

  TrainerSchemaX copyWith({
    String? id,
    String? trainerPk,
    int? year,
    int? month,
    List<int>? availabilities,
    bool? isNew,
    DateTime? created,
    DateTime? modified,
  }) {
    return TrainerSchemaX(
      id: id ?? this.id,
      trainerPk: trainerPk ?? this.trainerPk,
      year: year ?? this.year,
      month: month ?? this.month,
      availabilities: availabilities ?? this.availabilities,
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
      'availabilities': availabilities,
      'isNew': isNew,
      'created': created?.millisecondsSinceEpoch,
      'modified': modified?.millisecondsSinceEpoch,
    };
  }

  factory TrainerSchemaX.fromMap(Map<String, dynamic> map) {
    return TrainerSchemaX(
      id: map['id'],
      trainerPk: map['trainerPk'],
      year: map['year'],
      month: map['month'],
      availabilities: List<int>.from(map['availabilities']),
      isNew: map['isNew'],
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      modified: DateTime.fromMillisecondsSinceEpoch(map['modified']),
    );
  }

  @override
  String toString() {
    return 'TrainerSchema(id: $id, trainerPk: $trainerPk, year: $year, month: $month, availabilities: $availabilities, isNew: $isNew, created: $created, modified: $modified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainerSchemaX &&
        other.id == id &&
        other.trainerPk == trainerPk &&
        other.year == year &&
        other.month == month &&
        listEquals(other.availabilities, availabilities) &&
        other.isNew == isNew &&
        other.created == created &&
        other.modified == modified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        trainerPk.hashCode ^
        year.hashCode ^
        month.hashCode ^
        availabilities.hashCode ^
        isNew.hashCode ^
        created.hashCode ^
        modified.hashCode;
  }

  String toJson() => json.encode(toMap());
  factory TrainerSchemaX.fromJson(String source) =>
      TrainerSchemaX.fromMap(json.decode(source));
}

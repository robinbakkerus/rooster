import 'package:firestore/model/app_models.dart';

Trainer trainerRobin = Trainer(
    id: 'Robin1234',
    fullname: 'Robin Bakkerus',
    shortname: 'RB',
    email: 'robin.bakkerus@gmail.com',
    dinsdag: 1,
    donderdag: 1,
    zaterdag: 0,
    pr: 0,
    r1: 1,
    r2: 2,
    r3: 2,
    roles: 'A,S,T');

DaySchema ds1 = DaySchema(
    year: 2024, month: 1, day: 2, available: 1, modified: DateTime(2024, 1, 1));
DaySchema ds2 = DaySchema(
    year: 2024, month: 1, day: 4, available: 1, modified: DateTime(2024, 1, 1));
DaySchema ds3 = DaySchema(
    year: 2024, month: 1, day: 9, available: 1, modified: DateTime(2024, 1, 1));
DaySchema ds4 = DaySchema(
    year: 2024,
    month: 1,
    day: 11,
    available: 1,
    modified: DateTime(2024, 1, 1));
DaySchema ds5 = DaySchema(
    year: 2024,
    month: 1,
    day: 16,
    available: 1,
    modified: DateTime(2024, 1, 1));
DaySchema ds6 = DaySchema(
    year: 2024,
    month: 1,
    day: 18,
    available: 1,
    modified: DateTime(2024, 1, 1));
DaySchema ds7 = DaySchema(
    year: 2024,
    month: 1,
    day: 23,
    available: 1,
    modified: DateTime(2024, 1, 1));

int nextValue = 0;

// String _nextId() {
//   nextValue++;
//   final now = DateTime.now();
//   return now.microsecondsSinceEpoch.toString() + nextValue.toString();
// }

TrainerSchemas trainerSchemas1 = TrainerSchemas(
    id: 'Robin_2024_1',
    din1: 1,
    din2: 1,
    din3: 1,
    din4: 1,
    din5: 1,
    don1: 1,
    don2: 1,
    don3: 1,
    don4: 1,
    zat1: 0,
    zat2: 0,
    zat3: 0,
    zat4: 0,
    modified: DateTime.now());

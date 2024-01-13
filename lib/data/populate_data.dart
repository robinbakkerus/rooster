import 'dart:developer';

import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';

Trainer trainerRobin = _buildTrainer(
    'RB', 'Robin Bakkerus', 'ROMA', 'robin.bakkerus@gmail.com', 0, 1, 2, 0, 0,
    roles: 'T,A,S');
Trainer trainerPaula = _buildTrainer(
    'PvA', 'Paula van Agt', 'PACO', 'paulavanagt8@gmail.com', 0, 0, 1, 1, 0);
Trainer trainerOlav = _buildTrainer(
    'OB', 'Olav Boiten', 'OSLO', 'olav.boiten@gmail.com', 1, 0, 0, 0, 0);
Trainer trainerFried = _buildTrainer(
    'FvH', 'Fried van Hoek', 'FARO', 'hoek1947@kpnmail.nl', 0, 2, 1, 1, 0);
Trainer trainerMaria = _buildTrainer(
    'MvH', 'Maria van Hout', 'METS', 'maria.vanhout@onsnet.nu', 0, 0, 1, 1, 0);
Trainer trainerJeroen = _buildTrainer('JL', 'Jeroen Lathouwers', 'JENA',
    'jeroen.lathouwers@upcmail.nl', 2, 1, 0, 0, 0,
    roles: 'T,S');
Trainer trainerJanneke = _buildTrainer('JK', 'Janneke Kemkers', 'JAVA',
    'janneke.kempers85@gmail.com', 0, 0, 0, 0, 0);
Trainer trainerPauline = _buildTrainer(
    'PG', 'Pauline Geenen', 'PILA', 'g.geenen@on.nl', 0, 0, 1, 1, 1);
Trainer trainerHuib = _buildTrainer('HC', 'Huib van Chapelle', 'HACO',
    'huiblachapelle@icloud.com', 0, 0, 1, 1, 1);
Trainer trainerRonald = _buildTrainer(
    'RV', 'Ronald Vissers', 'ROME', 'rc.vissers@gmail.com', 2, 1, 2, 0, 2);
Trainer trainerAnne = _buildTrainer(
    'AJ', 'Anne Joustra', 'AKEN', 'a.joustra595242@kpnmail.nl', 0, 0, 1, 1, 0);
Trainer trainerCyriel = _buildTrainer(
    'CD', 'Cyriel Douven', 'CALI', 'cyrieldouven@gmail.com', 0, 0, 2, 2, 0);

// _buildTRainer
Trainer _buildTrainer(String pk, String fullname, String accesscode,
    String email, int pr, int r1, int r2, int r3, int zaterdag,
    {String roles = 'T'}) {
  int zamo = (zaterdag > 0) ? 1 : 0;

  email = 'robin.bakkerus@gmail.com'; // todo

  return Trainer(
      accessCode: accesscode,
      pk: pk,
      fullname: fullname,
      email: email,
      prefValues: [
        TrainerPref(paramName: DayPrefEnum.tuesday.name, value: 1),
        TrainerPref(paramName: DayPrefEnum.thursday.name, value: 1),
        TrainerPref(paramName: DayPrefEnum.saturday.name, value: zamo),
        TrainerPref(paramName: Groep.pr.name, value: pr),
        TrainerPref(paramName: Groep.r1.name, value: r1),
        TrainerPref(paramName: Groep.r2.name, value: r2),
        TrainerPref(paramName: Groep.r3.name, value: r3),
        TrainerPref(paramName: Groep.zamo.name, value: zamo)
      ],
      roles: roles);
}

List<TrainerSchema> allSchemas = [
  trainerSchemasRobin,
  trainerSchemasPaula,
  trainerSchemasOlav,
  trainerSchemasFried,
];

TrainerSchema trainerSchemasRobin = _buildTrainerSchema(trainerRobin);
TrainerSchema trainerSchemasPaula = _buildTrainerSchema(trainerPaula);
TrainerSchema trainerSchemasOlav = _buildTrainerSchema(trainerOlav);
TrainerSchema trainerSchemasFried = _buildTrainerSchema(trainerFried);
TrainerSchema trainerSchemasRonald = _buildTrainerSchema(trainerRonald);
TrainerSchema trainerSchemasMaria = _buildTrainerSchema(trainerMaria);
TrainerSchema trainerSchemasJanneke = _buildTrainerSchema(trainerJanneke);
TrainerSchema trainerSchemasAnne = _buildTrainerSchema(trainerAnne);
TrainerSchema trainerSchemasPauline = _buildTrainerSchema(trainerPauline);
TrainerSchema trainerSchemasHuib = _buildTrainerSchema(trainerHuib);
TrainerSchema trainerSchemasCyriel = _buildTrainerSchema(trainerCyriel);
TrainerSchema trainerSchemasJeroen = _buildTrainerSchema(trainerJeroen);

// build schema's for februari
TrainerSchema _buildTrainerSchema(Trainer trainer) {
  TrainerSchema result = TrainerSchema.empty();
  AppData.instance.setActiveDate(DateTime(2024, 2, 1));

  Map<String, dynamic> map = result.toMap();
  map['id'] = '${trainer.pk}_2024_2'; //todo
  map['year'] = DateTime.now().year;
  map['month'] = DateTime.now().month;
  map['trainerPk'] = trainer.pk;

  result = TrainerSchema.fromMap(map);

  int availTuesday = trainer.getDayPrefValue(weekday: DateTime.tuesday);
  int availThursday = trainer.getDayPrefValue(weekday: DateTime.thursday);
  int availSaturday = trainer.getDayPrefValue(weekday: DateTime.saturday);

  List<DateTime> dates = AppData.instance.getActiveDates();
  for (DateTime dt in dates) {
    log('${dt.day} ${dt.weekday}');
  }

  for (DateTime date in AppData.instance.getActiveDates()) {
    if (date.weekday == DateTime.tuesday) {
      result.availableList.add(availTuesday);
    } else if (date.weekday == DateTime.thursday) {
      result.availableList.add(availThursday);
    } else if (date.weekday == DateTime.saturday) {
      result.availableList.add(availSaturday);
    }
  }

  result.created = DateTime.now();
  return result;
}

// ApplyWeightValues
ApplyWeightValues getApplyWeightValues() {
  List<ApplyWeightStartValue> startValues = [];
  startValues.add(ApplyWeightStartValue(trainerPk: '*', value: 100.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'OB', value: 110.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'FvH', value: 110.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'RV', value: 110.0));
  List<ApplyWeightStartValue> zamoStartValues = [];
  startValues.add(ApplyWeightStartValue(trainerPk: '*', value: 0.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'HC', value: 141.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'PG', value: 131.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'RV', value: 100.0));
  List<double> alreadyScheduled = [-10.0, -13.0, -12.0, -11.0];
  ApplyWeightValues weightValues = ApplyWeightValues(
      startValues: startValues,
      zamoStartValues: zamoStartValues,
      onlyIfNeeded: -25,
      alreadyScheduled: alreadyScheduled);
  return weightValues;
}

// ApplyWeightValues
List<String> getTrainerItems() {
  return [
    'Herstelduurloop',
    'Duurloop D1',
    'Tempo Duurloop D2',
    'Climaxduurloop D1/D2',
    'Fartlek',
    'Interval korte afstand',
    'Intervalduurloop D1/D2',
    'Bosloop',
    'Gulbergen',
    'Pyramideloop'
  ];
}

//---------------- spreadsheets
FsSpreadsheet spreadSheetJanuari() {
  return FsSpreadsheet(
      year: 2024, month: 1, rows: _januariRows(), isFinal: true);
}

FsSpreadsheet spreadSheetFebruari() {
  return FsSpreadsheet(
      year: 2024, month: 2, rows: _februariRows(), isFinal: true);
}

List<FsSpreadsheetRow> _januariRows() {
  List<FsSpreadsheetRow> rows = [];
  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 2),
      trainingText: 'Kerstvakantie training',
      isExtraRow: false,
      rowCells: ['Olav', 'Robin', 'Fried', 'Paula', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 4),
      trainingText: 'Kerstvakantie training',
      isExtraRow: false,
      rowCells: ['(met R1)', 'Ronald', '(met R3)', 'Anne', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 6),
      trainingText: 'ZAMO',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 9),
      trainingText: 'korte training + NY borrel',
      isExtraRow: false,
      rowCells: ['Olav', 'Jeroen', 'Maria', 'Anne', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 11),
      trainingText: 'Tempo duurloop D2',
      isExtraRow: false,
      rowCells: ['(met R1)', 'Ronald', 'Fried', 'Pauline', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 13),
      trainingText: 'ZAMO',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 16),
      trainingText: 'Fartlek',
      isExtraRow: false,
      rowCells: ['Janneke', 'Robin', 'Ronald', 'Huib', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 18),
      trainingText: 'Duurloop D1',
      isExtraRow: false,
      rowCells: ['(met R1)', 'Jeroen', 'Cyriel', 'Fried', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 20),
      trainingText: 'ZAMO',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 23),
      trainingText: 'Herstelduurloop',
      isExtraRow: false,
      rowCells: ['Olav', 'Janneke', 'Maria', 'Huib', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 25),
      trainingText: 'Climaxduurloop D1/D2',
      isExtraRow: false,
      rowCells: ['(met R1)', 'Jeroen', 'Cyriel', 'Pauline', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 27),
      trainingText: 'ZAMO',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 30),
      trainingText: 'Interval korte afstand',
      isExtraRow: false,
      rowCells: ['Janneke', 'Robin', 'Maria', 'Paula', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 1, 21),
      trainingText: 'Houffalize ultra trail	',
      isExtraRow: true,
      rowCells: []));

  return rows;
}

List<FsSpreadsheetRow> _februariRows() {
  List<FsSpreadsheetRow> rows = [];
  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 1),
      trainingText: 'Intervalduurloop D1/D2',
      isExtraRow: false,
      rowCells: ['(Met R1)', 'Ronald', 'Fried', 'Anne', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 3),
      trainingText: 'ZAMO',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 6),
      trainingText: '30′ Training + ALV',
      isExtraRow: false,
      rowCells: ['Olav', 'Jeroen', 'Maria', 'Paula', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 8),
      trainingText: 'Fartlek',
      isExtraRow: false,
      rowCells: ['(Met R1)', 'Robin', 'Fried', 'Huib', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 10),
      trainingText: 'ZAMO',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 13),
      trainingText: 'Geen training: Carnaval',
      isExtraRow: false,
      rowCells: ['', '', '', '', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 15),
      trainingText: 'Voorjaarsvakantie training',
      isExtraRow: false,
      rowCells: ['(Met R1)', 'Robin', '(Met R3)', 'Pauline', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 17),
      trainingText: 'ZaMo',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 20),
      trainingText: 'Duurloop D1',
      isExtraRow: false,
      rowCells: ['Janneke', 'Robin', 'Maria', 'Paula', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 22),
      trainingText: 'Interval lange afstand',
      isExtraRow: false,
      rowCells: ['(Met R1)', 'Jeroen', 'Cyriel', 'Pauline', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 24),
      trainingText: 'ZaMo',
      isExtraRow: false,
      rowCells: ['', '', '', '', 'Hu/Pa/Ro']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 27),
      trainingText: 'Tempoduurloop D2',
      isExtraRow: false,
      rowCells: ['Olav', 'Janneke', 'Ronald', 'Huib', '']));

  rows.add(FsSpreadsheetRow(
      date: DateTime(2024, 2, 29),
      trainingText: 'Interval korte afstand',
      isExtraRow: false,
      rowCells: ['(Met R1)', 'Jeroen', 'Fried', 'Anne', '']));

  return rows;
}

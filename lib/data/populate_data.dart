// ignore_for_file: constant_identifier_names

import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_constants.dart';

DateTime summerStart = DateTime(2024, 7, 6);
DateTime summerEnd = DateTime(2024, 8, 18);
List<ExcludeDay> excludeDays = [
  ExcludeDay(dateTime: DateTime(2024, 5, 30), description: 'Mei vakantie')
];

List<Trainer> allTrainers = [
  trainerAnne,
  trainerPaula,
  trainerRobin,
  trainerFried,
  trainerHuib,
  trainerJanneke,
  trainerJeroen,
  trainerMaria,
  trainerOlav,
  trainerPauline,
  trainerRonald,
  trainerCyriel,
];
Trainer trainerRobin = _buildTrainer('RB', 'Robin Bakkerus', 'ROMA',
    'robin.bakkerus@gmail.com', 0, 1, 2, 0, 1, 1, 0,
    roles: 'T,A,S');
Trainer trainerPaula = _buildTrainer('PvA', 'Paula van Agt', 'PACO',
    'paulavanagt8@gmail.com', 0, 0, 1, 1, 0, 0, 0);
Trainer trainerOlav = _buildTrainer(
    'OB', 'Olav Boiten', 'OSLO', 'olav.boiten@gmail.com', 1, 0, 0, 0, 0, 0, 0);
Trainer trainerFried = _buildTrainer('FvH', 'Fried van Hoek', 'FARO',
    'hoek1947@kpnmail.nl', 0, 2, 1, 1, 1, 1, 0);
Trainer trainerMaria = _buildTrainer('MvH', 'Maria van Hout', 'METS',
    'maria.vanhout@onsnet.nu', 0, 0, 1, 0, 0, 1, 0);
Trainer trainerJeroen = _buildTrainer('JL', 'Jeroen Lathouwers', 'JENA',
    'jeroen.lathouwers@upcmail.nl', 2, 1, 0, 0, 1, 0, 0,
    roles: 'T,S');
Trainer trainerJanneke = _buildTrainer('JK', 'Janneke Kemkers', 'JAVA',
    'janneke.kempers85@gmail.com', 0, 0, 0, 0, 0, 0, 0);
Trainer trainerPauline = _buildTrainer(
    'PG', 'Pauline Geenen', 'PILA', 'g.geenen@on.nl', 0, 0, 0, 1, 1, 0, 1);
Trainer trainerHuib = _buildTrainer('HC', 'Huib van Chapelle', 'HACO',
    'huiblachapelle@icloud.com', 0, 0, 2, 1, 1, 1, 1);
Trainer trainerRonald = _buildTrainer('RV', 'Ronald Vissers', 'ROME',
    'rc.vissers@gmail.com', 0, 1, 2, 0, 1, 1, 1);
Trainer trainerAnne = _buildTrainer('AJ', 'Anne Joustra', 'AKEN',
    'a.joustra595242@kpnmail.nl', 0, 0, 0, 1, 1, 0, 0);
Trainer trainerCyriel = _buildTrainer('CD', 'Cyriel Douven', 'CALI',
    'cyrieldouven@gmail.com', 0, 0, 1, 2, 0, 0, 0);

// _buildTRainer
Trainer _buildTrainer(
    String pk,
    String fullname,
    String accesscode,
    String email,
    int pr,
    int r1,
    int r2,
    int r3,
    int sg,
    int zomer,
    int zaterdag,
    {String roles = 'T'}) {
  int zamo = (zaterdag > 0) ? 1 : 0;

  return Trainer(
      accessCode: accesscode,
      originalAccessCode: accesscode,
      pk: pk,
      fullname: fullname,
      email: email,
      originalEmail: email,
      prefValues: [
        TrainerPref(paramName: 'dinsdag', value: 1),
        TrainerPref(paramName: 'donderdag', value: 1),
        TrainerPref(paramName: 'zaterdag', value: zamo),
        TrainerPref(paramName: Groep.pr.name, value: pr),
        TrainerPref(paramName: Groep.r1.name, value: r1),
        TrainerPref(paramName: Groep.r2.name, value: r2),
        TrainerPref(paramName: Groep.r3.name, value: r3),
        TrainerPref(paramName: Groep.zamo.name, value: zamo),
        TrainerPref(paramName: Groep.sg.name, value: sg),
        TrainerPref(paramName: Groep.zomer.name, value: zomer),
      ],
      roles: roles);
}

List<TrainerSchema> allSchemas = [
  trainerSchemasRobin,
  trainerSchemasPaula,
  trainerSchemasOlav,
  trainerSchemasFried,
  trainerSchemasAnne,
  trainerSchemasMaria,
  trainerSchemasCyriel,
  trainerSchemasJanneke,
  trainerSchemasJeroen
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
  AppData.instance.setActiveDate(DateTime(2024, 1, 1));

  Map<String, dynamic> map = result.toMap();
  map['id'] = '${trainer.pk}_2024_1'; //todo
  map['year'] = DateTime.now().year;
  map['month'] = DateTime.now().month;
  map['trainerPk'] = trainer.pk;

  result = TrainerSchema.fromMap(map);

  int availTuesday = trainer.getDayPrefValue(weekday: DateTime.tuesday);
  int availThursday = trainer.getDayPrefValue(weekday: DateTime.thursday);
  int availSaturday = trainer.getDayPrefValue(weekday: DateTime.saturday);

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
MetaPlanRankValues getPlanRankValues() {
  List<PlanRankStartValue> startValues = [];
  startValues.add(PlanRankStartValue(trainerPk: '*', value: 100.0));
  startValues.add(PlanRankStartValue(trainerPk: 'OB', value: 110.0));
  startValues.add(PlanRankStartValue(trainerPk: 'FvH', value: 110.0));
  startValues.add(PlanRankStartValue(trainerPk: 'RV', value: 110.0));
  List<PlanRankStartValue> zamoStartValues = [];
  startValues.add(PlanRankStartValue(trainerPk: '*', value: 0.0));
  startValues.add(PlanRankStartValue(trainerPk: 'HC', value: 141.0));
  startValues.add(PlanRankStartValue(trainerPk: 'PG', value: 131.0));
  startValues.add(PlanRankStartValue(trainerPk: 'RV', value: 100.0));
  List<double> alreadyScheduled = [-10.0, -13.0, -12.0, -11.0];
  MetaPlanRankValues weightValues = MetaPlanRankValues(
      startValues: startValues,
      zamoStartValues: zamoStartValues,
      onlyIfNeeded: -25,
      alreadyScheduled: alreadyScheduled);
  return weightValues;
}

// ApplyWeightValues
List<String> getTrainerItems() {
  return [
    'Duurloop - D1',
    'Duurloop - Tempo D2',
    'Duurloop - Interval D1/D2',
    'Duurloop - Climax D1/D2',
    'Duurloop - Herstel',
    'Interval - Korte afstand',
    'Interval - Lange afstand',
    'Interval - Pyramide',
    'Interval - Fartlek',
    'Bostraining of Gulbergen',
    'Kilometerloop',
    'Minutenloop',
    'Locatie ... / Start 09:00u',
    'Korte training 30 / ...',
    'Bosloop / ...',
    'Evenement / ...',
    'Geen training / ...',
  ];
}

//---------------- spreadsheets
List<FsSpreadsheet> allFsSpreadsheets = [
  _spreadSheetJanuari(),
  _spreadSheetFebruari(),
  _spreadSheetMarch()
];

FsSpreadsheet _spreadSheetJanuari() {
  return FsSpreadsheet(
      year: 2024, month: 1, rows: _januariRows(), isFinal: true);
}

FsSpreadsheet _spreadSheetFebruari() {
  return FsSpreadsheet(
      year: 2024, month: 2, rows: _februariRows(), isFinal: true);
}

FsSpreadsheet _spreadSheetMarch() {
  return FsSpreadsheet(year: 2024, month: 3, rows: _maartRows(), isFinal: true);
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

List<FsSpreadsheetRow> _maartRows() {
  List<FsSpreadsheetRow> result = [];

  DateTime start = DateTime(2024, 3, 1);
  DateTime end = DateTime(2024, 3, 31);
  int days = end.difference(start).inDays;
  for (int i = 0; i < days; i++) {
    DateTime date = start.add(Duration(days: i));
    if (date.weekday == DateTime.tuesday || date.weekday == DateTime.thursday) {
      result.add(FsSpreadsheetRow(
          date: date,
          trainingText: 'Duurloop',
          isExtraRow: false,
          rowCells: ['Olav', 'Janneke', 'Ronald', 'Huib', '']));
    } else if (date.weekday == DateTime.saturday) {
      result.add(FsSpreadsheetRow(
          date: date,
          trainingText: 'ZamO',
          isExtraRow: false,
          rowCells: ['', '', '', '', 'Hu/Pa/Ro']));
    }
  }

  return result;
}

List<TrainingGroup> allTrainingGroups() {
  List<TrainingGroup> result = [];

  result.add(_buildTrainingGroup('pr', 'PR group 60 min'));
  result.add(_buildTrainingGroup('r1', 'R1 group 60 min'));
  result.add(_buildTrainingGroup('r2', 'R2 group 60 min'));
  result.add(_buildTrainingGroup('r3', 'P3 group 50 min'));
  result.add(_buildSummerTrainingGroup(Groep.zomer.name, 'Zomer training'));
  result.add(_buildStartersGroup(Groep.sg.name, 'Starters groep'));
  result.add(_buildZamoTrainingGroup(Groep.zamo.name, 'ZaMo groep'));

  return result;
}

TrainingGroup _buildTrainingGroup(String name, String descr) {
  List<ExcludePeriod> excludePeriods = [];
  excludePeriods.add(ExcludePeriod(fromDate: summerStart, toDate: summerEnd));

  return TrainingGroup(
      name: name,
      description: descr,
      type: TrainingGroupType.regular,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2099, 1, 1),
      excludePeriods: excludePeriods,
      trainingDays: [DateTime.tuesday, DateTime.thursday],
      defaultTrainingText: '*');
}

TrainingGroup _buildZamoTrainingGroup(String name, String descr) {
  return TrainingGroup(
      name: name,
      description: descr,
      type: TrainingGroupType.special,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2099, 1, 1),
      excludePeriods: [],
      trainingDays: [DateTime.saturday],
      defaultTrainingText: 'ZaMo start 9 uur Donkervoort');
}

TrainingGroup _buildSummerTrainingGroup(String name, String descr) {
  return TrainingGroup(
    name: name,
    description: descr,
    type: TrainingGroupType.special,
    startDate: summerStart,
    endDate: summerEnd,
    excludePeriods: [],
    trainingDays: [DateTime.tuesday, DateTime.thursday],
    defaultTrainingText: 'Zomertraining',
  );
}

TrainingGroup _buildStartersGroup(String name, String descr) {
  DateTime startDate = DateTime(2024, 3, 1);
  DateTime endDate = DateTime(2024, 5, 31);

  return TrainingGroup(
      name: name,
      description: descr,
      type: TrainingGroupType.special,
      startDate: startDate,
      endDate: endDate,
      excludePeriods: [],
      trainingDays: [DateTime.tuesday],
      defaultTrainingText: '*');
}

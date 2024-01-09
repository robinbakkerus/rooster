import 'package:rooster/model/app_models.dart';

Trainer trainerRobin = Trainer(
    accessCode: 'ROMA',
    pk: 'RB',
    fullname: 'Robin Bakkerus',
    email: 'robin.bakkerus@gmail.com',
    dinsdag: 1,
    donderdag: 1,
    zaterdag: 0,
    pr: 0,
    r1: 1,
    r2: 2,
    r3: 2,
    zamo: 0,
    roles: 'A,S,T');

Trainer trainerPaula = _buildTrainer(
    'PvA', 'Paula van Agt', 'PACO', 'paulavanagt8@gmail.com', 0, 0, 1, 1, 0);
Trainer trainerOlav = _buildTrainer(
    'OB', 'Olav Boiten', 'OSLO', 'olav.boiten@gmail.com', 1, 0, 0, 0, 0);
Trainer trainerFried = _buildTrainer(
    'FvH', 'Fried van Hoek', 'FARO', 'hoek1947@kpnmail.nl', 0, 2, 1, 1, 0);
Trainer trainerMaria = _buildTrainer(
    'MvH', 'Maria van Hout', 'METS', 'maria.vanhout@onsnet.nu', 0, 0, 1, 1, 0);
Trainer trainerJeroen = _buildTrainer('JL', 'Jeroen Lathouwers', 'JENA',
    'jeroen.lathouwers@upcmail.nl', 2, 1, 0, 0, 0);
Trainer trainerJanneke = _buildTrainer('JK', 'Janneke Kemkers', 'JAVA',
        'janneke.kempers85@gmail.com', 0, 0, 0, 0, 0)
    .copyWith(dinsdag: 0, donderdag: 0);
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
    String email, int pr, int r1, int r2, int r3, int zaterdag) {
  int zamo = (zaterdag > 0) ? 1 : 0;
  return Trainer(
      accessCode: accesscode,
      pk: pk,
      fullname: fullname,
      email: email,
      dinsdag: 1,
      donderdag: 1,
      zaterdag: zaterdag,
      pr: pr,
      r1: r1,
      r2: r2,
      r3: r3,
      zamo: zamo,
      roles: 'T');
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

TrainerSchema _buildTrainerSchema(Trainer trainer) {
  TrainerSchema result = TrainerSchema.empty();
  Map<String, dynamic> map = result.toMap();
  map['id'] = '${trainer.pk}_2024_1';

  map['trainerPk'] = trainer.pk;
  for (int i = 1; i < 6; i++) {
    String elem = 'din$i';
    map[elem] = trainer.dinsdag;
  }
  for (int i = 1; i < 6; i++) {
    String elem = 'don$i';
    map[elem] = trainer.donderdag;
  }
  for (int i = 1; i < 6; i++) {
    String elem = 'zat$i';
    map[elem] = trainer.zaterdag;
  }

  result = TrainerSchema.fromMap(map);
  return result;
}

// ApplyWeightValues
ApplyWeightValues getApplyWeightValues() {
  List<ApplyWeightStartValue> startValues = [];
  startValues.add(ApplyWeightStartValue(trainerPk: '*', value: 100.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'OB', value: 110.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'FvH', value: 110.0));
  startValues.add(ApplyWeightStartValue(trainerPk: 'RV', value: 110.0));
  List<double> alreadyScheduled = [-10.0, -13.0, -12.0, -11.0];
  ApplyWeightValues weightValues = ApplyWeightValues(
      startValues: startValues,
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

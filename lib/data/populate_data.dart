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

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

Trainer trainerPaula =
    _buildTrainer('PvA', 'Paula van Agt', 'PACO', 0, 0, 1, 1, 0);
Trainer trainerOlav = _buildTrainer('OB', 'Olav Boiten', 'OSLO', 1, 0, 0, 0, 0);
Trainer trainerFried =
    _buildTrainer('FvH', 'Fried van Hoek', 'FARO', 0, 2, 1, 1, 0);
Trainer trainerMaria =
    _buildTrainer('MvH', 'Maria van Hout', 'METS', 0, 1, 1, 2, 0);
Trainer trainerJeroen =
    _buildTrainer('JL', 'Jeroen Lathouwers', 'JENA', 2, 1, 0, 0, 0);
Trainer trainerJanneke =
    _buildTrainer('JK', 'Janneke Kemkers', 'JAVA', 1, 1, 0, 0, 0);
Trainer trainerPauline =
    _buildTrainer('PG', 'Pauline Geenen', 'PILA', 0, 0, 1, 1, 1);
Trainer trainerHuib =
    _buildTrainer('HC', 'Huib van Chapelle', 'HACO', 0, 0, 1, 1, 1);
Trainer trainerRonald =
    _buildTrainer('RV', 'Ronald Vissers', 'ROME', 2, 1, 2, 0, 2);

// _buildTRainer
Trainer _buildTrainer(String pk, String fullname, String accesscode, int pr,
    int r1, int r2, int r3, int zaterdag) {
  int zamo = (zaterdag > 0) ? 1 : 0;
  return Trainer(
      accessCode: accesscode,
      pk: pk,
      fullname: fullname,
      email: '',
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

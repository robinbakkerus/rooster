import 'package:rooster/data/app_data.dart';
import 'package:rooster/data/populate_data.dart' as p;
import 'package:rooster/model/app_models.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rooster/service/dbs.dart';
import 'package:rooster/util/app_mixin.dart';

class Simulator with AppMixin implements Dbs {
  Simulator._();
  static final Simulator instance = Simulator._();

  @override
  Future<Trainer> createOrUpdateTrainer(trainer) async {
    return trainer;
  }

  @override
  Future<bool> createOrUpdateTrainerSchemas(TrainerSchema trainerSchemas,
      {required bool updateSchema}) async {
    return true;
  }

  @override
  Future<Trainer> findTrainerByAccessCode(String accessCode) async {
    Trainer? trainer =
        p.allTrainers.firstWhereOrNull((e) => e.accessCode == accessCode);
    return trainer ?? Trainer.empty();
  }

  @override
  Future<List<Trainer>> getAllTrainers() async {
    return p.allTrainers;
  }

  @override
  Future<MetaPlanRankValues> getApplyWeightValues() async {
    return p.getPlanRankValues();
  }

  @override
  Future<LastRosterFinal?> getLastRosterFinal() async {
    return LastRosterFinal(at: DateTime.now(), year: 2024, month: 1, by: 'RB');
  }

  @override
  Future<Trainer?> getTrainerById(String trainerPk) async {
    Trainer? trainer = p.allTrainers.firstWhereOrNull((e) => e.pk == trainerPk);
    return trainer ?? Trainer.empty();
  }

  @override
  Future<TrainerSchema> getTrainerSchema(String trainerSchemaId) async {
    return p.trainerSchemasRobin; //todo
  }

  @override
  Future<List<String>> getTrainingItems() async {
    return p.getTrainerItems();
  }

  @override
  Future<List<String>> getZamoTrainers() async {
    return ['HC', 'PG', 'RV'];
  }

  @override
  Future<String> getZamoTrainingDefault() async {
    return 'Zamo start ';
  }

  @override
  Future<FsSpreadsheet?> retrieveSpreadsheet(
      {required int year, required int month}) async {
    FsSpreadsheet? fsSpreadsheet = p.allFsSpreadsheets
        .firstWhereOrNull((e) => e.month == month && e.year == year);
    return fsSpreadsheet ??
        FsSpreadsheet(
            year: AppData.instance.getActiveYear(),
            month: AppData.instance.getActiveMonth(),
            rows: [],
            isFinal: false);
  }

  @override
  Future<void> saveFsSpreadsheet(FsSpreadsheet fsSpreadsheet) async {
    return;
  }

  @override
  Future<LastRosterFinal> saveLastRosterFinal() async {
    return LastRosterFinal(
        at: DateTime.now(),
        by: AppData.instance.getTrainer().pk,
        year: AppData.instance.getActiveYear(),
        month: AppData.instance.getActiveMonth());
  }

  @override
  Future<bool> sendEmail(
      {required List<Trainer> toList,
      required List<Trainer> ccList,
      required String subject,
      required String html}) async {
    return true;
  }

  @override
  Future<void> saveTrainingGroups(List<TrainingGroup> trainingGroups) async {}

  @override
  Future<List<TrainingGroup>> getTrainingGroups() async {
    return p.allTrainingGroups();
  }
}

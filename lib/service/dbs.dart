import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/repo/dbs_simulator.dart';
import 'package:rooster/repo/firestore_helper.dart';

abstract class Dbs {
  static Dbs instance = (AppData.instance.runMode == RunMode.dev)
      ? Simulator.instance as Dbs
      : FirestoreHelper.instance;

  Future<Trainer> findTrainerByAccessCode(String accessCode);
  Future<Trainer?> getTrainerByPk(String trainerPk);
  Future<TrainerSchema> getTrainerSchema(String trainerSchemaId);
  Future<bool> createOrUpdateTrainerSchemas(TrainerSchema trainerSchemas,
      {required bool updateSchema});
  Future<List<Trainer>> getAllTrainers();
  Future<Trainer> createOrUpdateTrainer(trainer);
  Future<List<String>> getTrainingItems();
  Future<MetaPlanRankValues> getApplyPlanRankValues();
  Future<LastRosterFinal> saveLastRosterFinal();
  Future<LastRosterFinal?> getLastRosterFinal();
  Future<void> saveFsSpreadsheet(FsSpreadsheet fsSpreadsheet);
  Future<FsSpreadsheet?> retrieveSpreadsheet(
      {required int year, required int month});
  Future<bool> sendEmail(
      {required List<Trainer> toList,
      required List<Trainer> ccList,
      required String subject,
      required String html});
  Future<void> saveTrainingGroups(List<TrainingGroup> trainingGroups);
  Future<List<TrainingGroup>> getTrainingGroups();
  Future<void> savePlanRankValues(MetaPlanRankValues planRankValues);
  Future<void> saveExcludeDays(List<ExcludeDay> excludeDays);
  Future<List<ExcludeDay>> getExcludeDays();
}

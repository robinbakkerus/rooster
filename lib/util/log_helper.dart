import 'dart:developer' as dev;

import 'package:rooster/model/app_models.dart';

class LogHelper {
  static final LogHelper _instance = LogHelper._internal();

  factory LogHelper() => _instance;
  final bool isDebug = false;

  LogHelper._internal();

  //-----------------------------
  void doLog(String message) {
    if (isDebug) {
      dev.log(message);
    }
  }

  ///-----------------------------
  void logTrainerRanks(
      {required List<TrainerPlanningRank> ranks,
      required String groupName,
      required DateTime date,
      required bool voor}) {
    if (!isDebug) return;

    String voorNa = voor ? 'voor' : 'na';
    if (groupName != "") {
      doLog('-------- $voorNa, groupName: $groupName, day : ${date.day}');
      for (TrainerPlanningRank trainerPlanRank in ranks) {
        if (logTrainers.contains(trainerPlanRank.trainer.firstName())) {
          logTrainerRank(trainerPlanRank);
        }
      }
    }
  }

  void logTrainerRank(TrainerPlanningRank trainerPlanRank) {
    doLog(
        'Trainer: ${trainerPlanRank.trainer.firstName()}, rank: ${trainerPlanRank.rank}');
  }

  void logAdjustPlanRank(
      TrainerPlanningRank trainerPlanRank, int adjustValue, String reason) {
    if (!isDebug) return;
    if (logTrainers.contains(trainerPlanRank.trainer.firstName()) || true) {
      doLog(
          'ADJUST $reason ${trainerPlanRank.trainer.firstName()}, rank: ${trainerPlanRank.rank}, adjust: $adjustValue ');
    }
  }

  void logStartRank(TrainerPlanningRank trainerPlanRank, String reason,
      DateTime date, String groupName) {
    if (!isDebug) return;
    if (groupName != "") {
      doLog(
          'day: ${date.day} ${trainerPlanRank.trainer.firstName()}, rank: ${trainerPlanRank.rank}  $reason $groupName');
    }
  }

  final logTrainers = [
    'Huib',
    'Paula',
    'Ronald',
    'Fried',
    'Monique',
    // 'Selma',
    'Pauline',
    // 'Jeroen',
  ];
}

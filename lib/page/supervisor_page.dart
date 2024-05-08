import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/page/exclude_days.dart';
import 'package:rooster/page/sync_trainer_data.dart';
import 'package:rooster/util/app_mixin.dart';

class SupervisorPage extends StatefulWidget {
  const SupervisorPage({super.key});

  @override
  State<SupervisorPage> createState() => _SupervisorPageState();
}

class _SupervisorPageState extends State<SupervisorPage> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          OutlinedButton(
              onPressed: _updateSpreadsheet,
              child: const Text('Update spreadsheet')),
          OutlinedButton(
              onPressed: _manageExcludeDays,
              child: const Text('Beheer vakantiedagen/periodes')),
          OutlinedButton(
              onPressed: _syncTrainerDataProd,
              child: const Text('PROD: Synchronize Trainer data, download')),
          OutlinedButton(
              onPressed: _syncTrainerDataAcc,
              child: const Text('ACC: Synchronize Trainer data upload')),
        ],
      ),
    );
  }

  //------------------ private -------------------------

  void _updateSpreadsheet() async {
    await AppController.instance.regenerateSpreadsheet();
    AppEvents.fireShowPage(PageEnum.spreadSheet);
  }

  //-----------------------------
  void _manageExcludeDays() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          child: ExcludeDaysPage(),
        );
      },
    );
  }

  //-----------------------------
  void _syncTrainerDataProd() async {
    _syncTrainerData(RunMode.prod);
  }

  //-----------------------------
  void _syncTrainerDataAcc() async {
    _syncTrainerData(RunMode.acc);
  }

  //-----------------------------
  void _syncTrainerData(RunMode runMode) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SyncTrainerData(
            runModus: runMode,
          ),
        );
      },
    );
  }
}

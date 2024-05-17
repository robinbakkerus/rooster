import 'package:flutter/material.dart';
import 'package:rooster/admin_pages/manage_trainers.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/admin_pages/manage_special_days.dart';
import 'package:rooster/admin_pages/sync_trainer_data.dart';
import 'package:rooster/util/app_mixin.dart';

class SupervisorPage extends StatefulWidget {
  const SupervisorPage({super.key});

  @override
  State<SupervisorPage> createState() => _SupervisorPageState();
}

class _SupervisorPageState extends State<SupervisorPage> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wh.adminPageAppBar(context, 'Admin page'),
      body: Center(
        child: Column(
          children: [
            wh.verSpace(10),
            OutlinedButton(
                onPressed: _updateSpreadsheet,
                child: const Text('Update spreadsheet')),
            OutlinedButton(
                onPressed: _manageSpecialDays,
                child: const Text('Beheer vakantiedagen/periodes')),
            OutlinedButton(
                onPressed: _manageTrainers,
                child: const Text('Beheer trainers')),
            OutlinedButton(
                onPressed: _syncTrainerDataProd,
                child: const Text('PROD: Synchronize Trainer data, download')),
            OutlinedButton(
                onPressed: _syncTrainerDataAcc,
                child: const Text('ACC: Synchronize Trainer data upload')),
            wh.verSpace(10),
            wh.verSpace(10),
            wh.popPageButton(context),
          ],
        ),
      ),
    );
  }

  //------------------ private -------------------------
  void _updateSpreadsheet() async {
    await AppController.instance.regenerateSpreadsheet();
    AppEvents.fireShowPage(PageEnum.spreadSheet);
  }

  //-----------------------------
  void _manageSpecialDays() async {
    wh.pushPage(context, const ManageSpecialDaysPage());
  }

  //-----------------------------
  void _manageTrainers() async {
    wh.pushPage(context, const ManageTrainers());
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
  void _syncTrainerData(RunMode runMode) {
    wh.pushPage(context, SyncTrainerData(runModus: runMode));
  }
}

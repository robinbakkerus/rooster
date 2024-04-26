import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
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
        ],
      ),
    );
  }

  void _updateSpreadsheet() async {
    await AppController.instance.regenerateSpreadsheet();
    AppEvents.fireShowPage(PageEnum.spreadSheet);
  }

  //------------------ private -------------------------
}

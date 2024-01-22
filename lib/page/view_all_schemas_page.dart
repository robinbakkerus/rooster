import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/page/overall_availability_page.dart';
import 'package:rooster/page/spreadsheet_page.dart';
import 'package:rooster/page/trainer_progress_page.dart';
import 'package:rooster/util/app_mixin.dart';

class ViewAllSchemasPage extends StatefulWidget {
  const ViewAllSchemasPage({super.key});

  @override
  State<ViewAllSchemasPage> createState() => _ViewAllSchemasPageState();
}

class _ViewAllSchemasPageState extends State<ViewAllSchemasPage> with AppMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 1,
          bottom: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            onTap: _onTap,
            tabs: [
              _tab1(),
              _tab2(),
              _tab3(),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SpreadsheetPage(),
            TrainerProgressPage(),
            OverallAvailabilityPage(),
          ],
        ),
      ),
    );
  }

  void _onTap(value) {
    if (AppData.instance.spreadSheetStatus == SpreadsheetStatus.active &&
        value == 3) {
      wh.showSnackbar(
          'Schema is al definitief: er kunnen geen wijzigingen worden aangebracht',
          color: Colors.orange);
    }
  }

  //-- widgets for tabs

  Tab _tab1() {
    return Tab(
        child: Row(children: [
      SizedBox(
        width: c.w2,
        child: const Text(
          'Schema',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]));
  }

  Tab _tab2() {
    return Tab(
        child: Row(children: [
      SizedBox(
        width: c.w2,
        child: const Text(
          'Voortgang',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]));
  }

  Tab _tab3() {
    return Tab(
        child: Row(children: [
      SizedBox(
        width: c.w2,
        child: const Text(
          'Beschikbaarheid',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]));
  }
}

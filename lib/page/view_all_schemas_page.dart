import 'package:rooster/page/all_entered_schemas.dart';
import 'package:rooster/page/availability_page.dart';
import 'package:rooster/page/spreadsheet_page.dart';
import 'package:rooster/page/trainer_progress_page.dart';
import 'package:flutter/material.dart';
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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 1,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              _tab1(),
              _tab2(),
              _tab3(),
              _tab4(),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TrainerProgressPage(),
            AllEnteredSchemas(),
            AvailabilityPage(),
            SpreadsheetPage(),
          ],
        ),
      ),
    );
  }

  //-- widgets for tabs

  Tab _tab1() {
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

  Tab _tab2() {
    return Tab(
        child: Row(children: [
      SizedBox(
        width: c.w2,
        child: const Text(
          'Ingevulde schemas',
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

  Tab _tab4() {
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

  // widget for the content
}

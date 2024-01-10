import 'package:rooster/data/app_data.dart';
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
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            onTap: _onTap,
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
            SpreadsheetPage(),
            TrainerProgressPage(),
            AllEnteredSchemas(),
            AvailabilityPage(),
          ],
        ),
      ),
    );
  }

  void _onTap(value) {
    if (AppData.instance.schemaIsFinal() && value == 3) {
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
          'Ingevulde schemas',
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
          'Beschikbaarheid',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]));
  }

  // widget for the content
}

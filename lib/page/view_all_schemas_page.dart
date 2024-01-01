import 'package:rooster/page/availability_page.dart';
import 'package:rooster/page/spreadsheet_page.dart';
import 'package:rooster/page/trainer_progress_page.dart';
import 'package:flutter/material.dart';

class ViewAllSchemasPage extends StatefulWidget {
  const ViewAllSchemasPage({super.key});

  @override
  State<ViewAllSchemasPage> createState() => _ViewAllSchemasPageState();
}

class _ViewAllSchemasPageState extends State<ViewAllSchemasPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            bottom: TabBar(
              tabs: [
                _tab1(),
                _tab2(),
                _tab3(),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              TrainerProgressPage(),
              AvailabilityPage(),
              RosterPage(),
            ],
          ),
        ),
      ),
    );
  }

  //-- widgets for tabs

  Tab _tab1() {
    return const Tab(
        child: Row(children: [
      Text('Voortgang'),
    ]));
  }

  Tab _tab2() {
    return const Tab(
        child: Row(children: [
      Text('Beschikbaarheid'),
    ]));
  }

  Tab _tab3() {
    return const Tab(
        child: Row(children: [
      Text('Schema'),
    ]));
  }

  // widget for the content
}

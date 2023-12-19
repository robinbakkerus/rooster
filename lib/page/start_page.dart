import 'package:firestore/data/trainer_data.dart';
import 'package:firestore/event/app_events.dart';
import 'package:firestore/page/ask_trainerid_page.dart';
import 'package:firestore/page/schema_edit_page.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  String _barTitle = '???';
  int _stackIndex = 0;

  _StartPageState() {
    AppEvents.onTrainerDataReadyEvent(_onReady);
  }

  void _onReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _stackIndex = 1;
        _barTitle = '${TrainerData.instance.getFirstname()} : Januari 2024';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: IndexedStack(
        index: _stackIndex,
        children: [const AskTrainerIdPage(), SchemaEditPage()],
      ),
    );
  }

  PreferredSizeWidget? _appBar() {
    return AppBar(
      title: Text(_barTitle),
      actions: [
        _action1(),
        _action2(),
        _action3(),
        _action4(),
        _action5(),
        _action6()
      ],
    );
  }

  Widget _action1() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Show Snackbar',
      onPressed: () {},
    );
  }

  Widget _action2() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward),
      tooltip: 'Show Snackbar',
      onPressed: () {},
    );
  }

  Widget _action3() {
    return IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Show Snackbar',
      onPressed: () {},
    );
  }

  Widget _action4() {
    return IconButton(
      icon: const Icon(Icons.dataset),
      tooltip: 'Show Snackbar',
      onPressed: () {},
    );
  }

  Widget _action5() {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Show Snackbar',
      onPressed: () {},
    );
  }

  Widget _action6() {
    return IconButton(
      icon: const Icon(Icons.help),
      tooltip: 'Show Snackbar',
      onPressed: () {},
    );
  }
}

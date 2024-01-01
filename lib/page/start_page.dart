import 'dart:async';
import 'dart:html';

import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/page/admin_page.dart';
import 'package:rooster/page/ask_accesscode_page.dart';
import 'package:rooster/page/help_page.dart';
import 'package:rooster/page/schema_edit_page.dart';
import 'package:rooster/page/splash_page.dart';
import 'package:rooster/page/trainer_settings_page.dart';
import 'package:rooster/page/view_all_schemas_page.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // varbs
  String _barTitle = '???';
  int _stackIndex = 0;
  String _accessCode = '';

  // This corresponds with action button next right arrow action (these are handled seperately)
  List<bool> _actionEnabled = [false, true, true, true];
  bool _nextMonthEnabled = true;
  bool _prevMonthEnabled = true;

  _StartPageState();

  @override
  void initState() {
    _checkCookie();
    _getTrainerDataIfNeeded();
    AppEvents.onTrainerDataReadyEvent(_onTrainerDataReady);
    AppEvents.onDatesReadyEvent(_onDatesReady);

    Timer(const Duration(seconds: 2), () {
      if (_accessCode.length == 4) {
        _findTrainer(_accessCode);
      } else {
        setState(() {
          _stackIndex = 1; //ask accessCode
        });
      }
    });
    super.initState();
  }

  void _findTrainer(String accessCode) async {
    bool okay = await AppController.instance.findTrainer(accessCode);
    if (!okay) {
      setState(() {
        _stackIndex = 1;
      });
    }
  }

  void _getTrainerDataIfNeeded() {
    Trainer activeTrainer = AppData.instance.getTrainer();
    if (!activeTrainer.isEmpty() &&
        AppData.instance.getTrainerData().isEmpty()) {
      AppController.instance.getTrainerData(trainer: activeTrainer);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTrainerDataReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        _stackIndex = 2;
        _barTitle = _buildBarTitle();

        _prevMonthEnabled =
            AppData.instance.getActiveDate().millisecondsSinceEpoch >
                AppData.instance.firstMonth.millisecondsSinceEpoch;

        _nextMonthEnabled =
            AppData.instance.getActiveDate().millisecondsSinceEpoch <
                AppData.instance.lastMonth.millisecondsSinceEpoch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showTabBar() ? _appBar() : null,
      body: IndexedStack(
        index: _stackIndex,
        children: const [
          SplashPage(), //0
          AskAccessCodePage(), //1
          SchemaEditPage(), //2
          TrainerSettingsPage(), //3
          ViewAllSchemasPage(), //4
          HelpPage(), //5
          AdminPage(), //6
        ],
      ),
    );
  }

  bool _showTabBar() {
    return _stackIndex > 1;
  }

  PreferredSizeWidget? _appBar() {
    return AppBar(
      title: Text(_barTitle),
      actions: [
        _actionPrevMonth(),
        _actionNextMonth(),
        _buildPopMenu(),
      ],
    );
  }

  String _buildBarTitle() {
    String result = '${AppData.instance.getTrainer().firstName()}: ';

    if (_stackIndex == 2 || _stackIndex == 4) {
      result += AppData.instance.getActiveMonthAsString();
    } else if (_stackIndex == 3) {
      result += '${AppData.instance.getTrainer().firstName()} : Instellingen';
    } else if (_stackIndex == 5) {
      return 'Help pagina';
    } else if (_stackIndex == 6) {
      return 'Admin pagina';
    }

    return result;
  }

  Widget _buildPopMenu() {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == '2') {
          _gotoEditSchemas();
        } else if (value == '3') {
          _gotoTrainerSettings();
        } else if (value == '4') {
          _gotoViewAllSchemas();
        } else if (value == '5') {
          _gotoHelpPage();
        } else if (value == '6') {
          _gotoAdminPage();
        }
      },
      itemBuilder: (BuildContext bc) {
        return [
          const PopupMenuItem(
            value: '2',
            child: Text("Wijzig trainer schema"),
          ),
          const PopupMenuItem(
            value: '3',
            child: Text("Wijzig trainer settings"),
          ),
          const PopupMenuItem(
            value: '0',
            child: Text("-----"),
          ),
          const PopupMenuItem(
            value: '4',
            child: Text("Bekijk voortgang en alle schemas"),
          ),
          const PopupMenuItem(
            value: '5',
            child: Text("Help pagina"),
          ),
          _adminPopup(),
        ];
      },
    );
  }

  PopupMenuItem _adminPopup() {
    // bool isAdmin = AppData.instance.getTrainer().isAdmin();
    if (1 == 1) {
      //if (isAdmin) {
      return const PopupMenuItem(
        value: '6',
        child: Text("Admin pagina"),
      );
    } else {
      return const PopupMenuItem(
        value: '0',
        child: Text(""),
      );
    }
  }

  Widget _actionPrevMonth() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Ga naar de vorige maand',
      onPressed: _prevMonthEnabled ? _gotoPrevMonth : null,
    );
  }

  Widget _actionNextMonth() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward),
      tooltip: 'Ga naar de volgende maand',
      onPressed: _nextMonthEnabled ? _gotoNextMonth : null,
    );
  }

  // onPressed actions --
  void _gotoPrevMonth() {
    if (AppData.instance.getActiveMonth() == 1) {
      int year = AppData.instance.getActiveYear() - 1;
      int month = 12;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    } else {
      int year = AppData.instance.getActiveYear();
      int month = AppData.instance.getActiveMonth() - 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    }

    AppController.instance
        .getTrainerData(trainer: AppData.instance.getTrainer());
  }

  void _gotoNextMonth() {
    if (AppData.instance.getActiveMonth() == 12) {
      int year = AppData.instance.getActiveYear() + 1;
      int month = 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    } else {
      int month = AppData.instance.getActiveMonth() + 1;
      int year = AppData.instance.getActiveYear();
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    }

    AppController.instance
        .getTrainerData(trainer: AppData.instance.getTrainer());
  }

  void _gotoEditSchemas() {
    setState(() {
      _stackIndex = 2;
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(2);
    });
  }

  void _gotoViewAllSchemas() {
    AppController.instance.generateSpreadsheet();
    setState(() {
      _stackIndex = 4;
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(4);
    });
  }

  void _gotoTrainerSettings() {
    setState(() {
      _stackIndex = 3;
      _barTitle = _buildBarTitle();
      AppEvents.fireSchemaUpdated();
      _toggleActionEnabled(3);
    });
  }

  void _gotoHelpPage() {
    setState(() {
      _stackIndex = 5;
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(5);
    });
  }

  void _gotoAdminPage() {
    setState(() {
      _stackIndex = 6;
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(6);
    });
  }

  void _toggleActionEnabled(int index) {
    _actionEnabled = [true, true, true, true, true, true, true];
    _actionEnabled[index] = false;
  }

  void _onDatesReady(DatesReadyEvent event) {
    if (mounted) {
      setState(() {
        _barTitle = _buildBarTitle();
      });
    }
  }

  void _checkCookie() {
    final cookie = document.cookie!;
    if (cookie.isNotEmpty) {
      List<String> tokens = cookie.split('=');
      if (tokens.isNotEmpty) {
        _accessCode = tokens[1];
      }
    }
  }
}

enum Action {
  editSchema(2),
  trainerSettings(3),
  viewAllSchemas(4),
  helpPage(5),
  adminPage(6);

  const Action(this.code);
  final int code;
}

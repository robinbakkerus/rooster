import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/page/admin_page.dart';
import 'package:rooster/page/ask_accesscode_page.dart';
import 'package:rooster/page/error_page.dart';
import 'package:rooster/page/help_page.dart';
import 'package:rooster/page/overall_availability_page.dart';
import 'package:rooster/page/schema_edit_page.dart';
import 'package:rooster/page/splash_page.dart';
import 'package:rooster/page/spreadsheet_page.dart';
import 'package:rooster/page/trainer_prefs_page.dart';
import 'package:rooster/page/trainer_progress_page.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/widget/busy_indicator.dart';
import 'package:universal_html/html.dart' as html;

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // varbs
  String _barTitle = '???';
  String _accessCode = '';

  // This corresponds with action button next right arrow action (these are handled seperately)
  List<bool> _actionEnabled = [false, true, true, true];
  bool _nextMonthEnabled = true;
  bool _prevMonthEnabled = true;

  _StartPageState();

  @override
  void initState() {
    _getMetaData();
    _accessCode = _checkCookie(); // this may be empty
    AppEvents.onTrainerReadyEvent(_onTrainerReady);
    AppEvents.onTrainerDataReadyEvent(_onTrainerDataReady);
    AppEvents.onDatesReadyEvent(_onDatesReady);
    AppEvents.onErrorEvent(_onErrorEvent);
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);
    AppEvents.onShowPage(_onShowPage);

    Timer(const Duration(milliseconds: 2900), () {
      if (_accessCode.length == 4) {
        _findTrainer(_accessCode);
      } else {
        setState(() {
          _setStackIndex(PageEnum.askAccessCode.code); //ask accessCode
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showTabBar() ? _appBar() : null,
      body: IndexedStack(
        index: _getStackIndex(),
        children: [
          SplashPage(), //0
          const AskAccessCodePage(), //1
          const SchemaEditPage(), //2
          const TrainerPrefsPage(), //3
          const SpreadsheetPage(), //4
          const TrainerProgressPage(), //5
          const OverallAvailabilityPage(), //6
          HelpPage(), //7
          const AdminPage(), //8
          const AppErrorPage(), //9
        ],
      ),
    );
  }

  Color _runModeColor() {
    if (AppData.instance.runMode == RunMode.prod) {
      return Colors.white;
    } else {
      return AppData.instance.runMode == RunMode.dev
          ? Colors.lightGreen
          : Colors.yellow;
    }
  }

  bool _showTabBar() {
    return _getStackIndex() > 1;
  }

  PreferredSizeWidget? _appBar() {
    return AppBar(
      backgroundColor: _runModeColor(),
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

    if (_getStackIndex() == PageEnum.editSchema.code) {
      result += AppData.instance.getActiveMonthAsString();
      if (AppHelper.instance.isWindows() || AppHelper.instance.isTablet()) {
        result += ' ${AppData.instance.getActiveYear()}';
      }
    } else if (_getStackIndex() == PageEnum.trainerSettings.code) {
      result += ' Instellingen';
    } else if (_getStackIndex() == PageEnum.spreadSheet.code) {
      String s = AppHelper.instance.isWindows() ? 'Schema' : 'S';
      result = '$s ${AppData.instance.getActiveMonthAsString()}';
      result += _getSpreadstatus();
    } else if (_getStackIndex() == PageEnum.helpPage.code) {
      return 'Help pagina';
    } else if (_getStackIndex() == PageEnum.adminPage.code) {
      return 'Admin pagina';
    }

    return result;
  }

  String _getSpreadstatus() {
    String result = ' : ';
    DateTime useDate = AppData.instance.getSpreadsheetDate().copyWith(day: 2);
    if (useDate.isBefore(DateTime.now().copyWith(day: 1))) {
      result += '(verlopen)';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.active) {
      result += '(actief)';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.initial) {
      result += '(nieuw)';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.opened) {
      result += '(geopend)';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.dirty) {
      result += '(aangepast)';
    }

    return result;
  }

  void _findTrainer(String accessCode) async {
    bool okay = await AppController.instance.findTrainer(accessCode);
    if (!okay) {
      setState(() {
        _setStackIndex(1);
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

  void _getMetaData() async {
    await AppController.instance.getTrainerGroups();
    await AppController.instance.getTrainingItems();
    await AppController.instance.getPlanRankValues();
    await AppController.instance.getExcludeDays();
  }

  void _onTrainerReady(TrainerReadyEvent event) async {
    if (mounted) {
      _getTrainerDataIfNeeded();
    }
  }

  void _onTrainerDataReady(TrainerDataReadyEvent event) {
    if (mounted) {
      setState(() {
        if (_getStackIndex() != PageEnum.spreadSheet.code) {
          _setStackIndex(2);
        }

        _barTitle = _buildBarTitle();

        // we go back 1 month and check if date is after the first spreadsheet date
        _prevMonthEnabled = AppData.instance
            .getActiveDate()
            .add(const Duration(days: -30))
            .isAfter(AppData.instance.firstSpreadDate);

        _nextMonthEnabled = AppData.instance
            .getActiveDate()
            .isBefore(AppData.instance.lastMonth);
      });
    }
  }

  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    LoadingIndicatorDialog().dismiss();
    if (mounted) {
      setState(() {
        _barTitle = _buildBarTitle();
      });
    }
  }

  void _onShowPage(ShowPageEvent event) {
    if (mounted) {
      setState(() {
        _setStackIndex(event.page.code);
      });
    }
  }

  void _onDatesReady(DatesReadyEvent event) {
    if (mounted) {
      setState(() {
        _barTitle = _buildBarTitle();
      });
    }
  }

  void _onErrorEvent(ErrorEvent event) {
    setState(() {
      AppData.instance.stackIndex = PageEnum.errorPage.code;
    });
  }

  Widget _buildPopMenu() {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == PageEnum.editSchema.code.toString()) {
          _gotoEditSchemas();
        } else if (value == PageEnum.trainerSettings.code.toString()) {
          _gotoTrainerSettings();
        } else if (value == PageEnum.spreadSheet.code.toString()) {
          _gotoSpreadsheet();
        } else if (value == PageEnum.helpPage.code.toString()) {
          _gotoHelpPage();
        } else if (value == PageEnum.adminPage.code.toString()) {
          _gotoAdminPage();
        }
      },
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            value: PageEnum.editSchema.code.toString(),
            child: const Text("Trainer verhinderingen"),
          ),
          PopupMenuItem(
            value: PageEnum.trainerSettings.code.toString(),
            child: const Text("Trainer settings"),
          ),
          PopupMenuItem(
            value: PageEnum.splashPage.code.toString(),
            child: const Text("-----"),
          ),
          PopupMenuItem(
            value: PageEnum.spreadSheet.code.toString(),
            child: const Text("Spreadsheet & voortgang"),
          ),
          PopupMenuItem(
            value: PageEnum.helpPage.code.toString(),
            child: const Text("Help"),
          ),
          _adminPopup(),
        ];
      },
    );
  }

  PopupMenuItem _adminPopup() {
    if (AppData.instance.getTrainer().isAdmin()) {
      return PopupMenuItem(
        value: PageEnum.adminPage.code.toString(),
        child: const Text("Admin pagina"),
      );
    } else {
      return const PopupMenuItem(
        height: 1,
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

    if (_getStackIndex() == PageEnum.spreadSheet.code) {
      _gotoSpreadsheet();
    }
  }

  void _gotoNextMonth() {
    if (AppData.instance.getActiveMonth() == 12) {
      int year = AppData.instance.getActiveYear() + 1;
      int month = 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    } else {
      int year = AppData.instance.getActiveYear();
      int month = AppData.instance.getActiveMonth() + 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    }

    AppController.instance
        .getTrainerData(trainer: AppData.instance.getTrainer());

    if (_getStackIndex() == PageEnum.spreadSheet.code) {
      _gotoSpreadsheet();
    }
  }

  void _gotoEditSchemas() {
    setState(() {
      _setStackIndex(PageEnum.editSchema.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.editSchema.code);
    });
  }

  void _gotoSpreadsheet() async {
    await AppController.instance.generateOrRetrieveSpreadsheet();
    setState(() {
      _setStackIndex(PageEnum.spreadSheet.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.spreadSheet.code);
    });
  }

  void _gotoTrainerSettings() {
    setState(() {
      _setStackIndex(PageEnum.trainerSettings.code);
      _barTitle = _buildBarTitle();
      AppEvents.fireSchemaUpdated();
      _toggleActionEnabled(PageEnum.trainerSettings.code);
    });
  }

  void _gotoHelpPage() {
    setState(() {
      _setStackIndex(PageEnum.helpPage.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.helpPage.code);
    });
  }

  void _gotoAdminPage() {
    setState(() {
      _setStackIndex(PageEnum.adminPage.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.adminPage.code);
    });
  }

  void _toggleActionEnabled(int index) {
    _actionEnabled = [true, true, true, true, true, true, true, true, true];
    _actionEnabled[index] = false;
  }

  String _checkCookie() {
    final cookie = html.document.cookie!;
    if (cookie.isNotEmpty) {
      List<String> tokens = cookie.split('=');
      if (tokens.isNotEmpty) {
        return tokens[1];
      }
    }
    return '';
  }

  int _getStackIndex() => AppData.instance.stackIndex;
  void _setStackIndex(int value) {
    AppData.instance.stackIndex = value;
  }
}

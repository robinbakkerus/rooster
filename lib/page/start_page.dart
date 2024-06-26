import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/admin_pages/admin_page.dart';
import 'package:rooster/page/ask_accesscode_page.dart';
import 'package:rooster/admin_pages/error_page.dart';
import 'package:rooster/admin_pages/help_page.dart';
import 'package:rooster/page/overall_availability_page.dart';
import 'package:rooster/page/schema_edit_page.dart';
import 'package:rooster/page/splash_page.dart';
import 'package:rooster/page/spreadsheet_page.dart';
import 'package:rooster/admin_pages/supervisor_page.dart';
import 'package:rooster/page/trainer_prefs_page.dart';
import 'package:rooster/page/trainer_progress_page.dart';
import 'package:rooster/util/app_constants.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/spreadsheet_status_help.dart' as status_help;
import 'package:rooster/widget/busy_indicator.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // varbs
  Widget _barTitle = Container();
  String _accessCode = '';

  // This corresponds with action button next right arrow action (these are handled seperately)
  List<bool> _actionEnabled = [false, true, true, true];
  bool _nextMonthEnabled = true;
  bool _prevMonthEnabled = true;

  bool _informSpreadsheetFirstTime = true;

  _StartPageState();

  @override
  void initState() {
    _getMetaData();
    _checkAccessCodePref(); // this may be empty
    AppEvents.onTrainerReadyEvent(_onTrainerReady);
    AppEvents.onTrainerDataReadyEvent(_onTrainerDataReady);
    AppEvents.onDatesReadyEvent(_onDatesReady);
    AppEvents.onErrorEvent(_onErrorEvent);
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);
    AppEvents.onShowPage(_onShowPage);

    Timer(const Duration(milliseconds: 2900), () {
      WidgetHelper.instance.playWhooshSound();
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
          const AppErrorPage(), //8
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
      title: _barTitle,
      actions: [
        _actionSpreadsheetStatusInfo(),
        _actionPrevMonth(),
        _actionNextMonth(),
        _buildPopMenu(),
      ],
    );
  }

  Widget _buildBarTitle() {
    String title = _getBarTitle();
    if (_getStackIndex() == PageEnum.spreadSheet.code) {
      return _buildSpreadsheetStatusBarTitle(title);
    } else {
      return SizedBox(
          width: AppConstants().w1 * 5,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          ));
    }
  }

  String _getBarTitle() {
    String firstName = '${AppData.instance.getTrainer().firstName()} ';
    String result = '';

    if (_getStackIndex() == PageEnum.editSchema.code) {
      result = _getBarTitleForSchemaEditPage();
    } else if (_getStackIndex() == PageEnum.trainerSettings.code) {
      result = 'Voorkeuren $firstName';
    } else if (_getStackIndex() == PageEnum.spreadSheet.code) {
      result = _getBarTitleForSpreadhsheetPage();
    }
    return result;
  }

  String _getBarTitleForSpreadhsheetPage() {
    String result = '';
    if (_isLargeScreen()) {
      result = 'Schema ${AppData.instance.getActiveMonthAsString()}';
    } else {
      result = AppData.instance.getActiveMonthAsString().substring(0, 3);
    }
    result += ' (${_getSpreadstatus()})';
    return result;
  }

  String _getBarTitleForSchemaEditPage() {
    String firstName = '${AppData.instance.getTrainer().firstName()} ';
    String result = '';
    if (_isLargeScreen()) {
      result =
          'Verhinderingen $firstName${AppData.instance.getActiveMonthAsString()}';
      result += ' ${AppData.instance.getActiveYear()}';
    } else {
      result =
          '$firstName ${AppData.instance.getActiveMonthAsString()} Verhinderingen';
    }

    if (_isLargeScreen()) {}
    return result;
  }

  Widget _buildSpreadsheetStatusBarTitle(String title) {
    return TextButton(
      onPressed: () => _showStatusHelpDialog(),
      child: SizedBox(
          width: AppConstants().w1 * 5,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontSize: 24),
          )),
    );
  }

  String _getSpreadstatus() {
    String result = '';
    DateTime useDate = AppData.instance.getSpreadsheetDate().copyWith(day: 2);
    if (useDate.isBefore(DateTime.now().copyWith(day: 1))) {
      result = 'verlopen';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.active) {
      result = 'actief';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.underConstruction) {
      result = 'onderhanden';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.opened) {
      result = 'geopend';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.dirty) {
      result = 'aangepast';
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
    await AppController.instance.getSpecialDays();
    await AppController.instance.getTrainingItems();
    await AppController.instance.getPlanRankValues();
    await AppController.instance.getTrainerGroups();
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
    WidgetHelper.instance.pushPage(context, const AppErrorPage());
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
        } else if (value == PageEnum.supervisorPage.code.toString()) {
          _gotoSupervisorPage();
        }
      },
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            value: PageEnum.trainerSettings.code.toString(),
            child: const Text("Trainer voorkeuren"),
          ),
          PopupMenuItem(
            value: PageEnum.editSchema.code.toString(),
            child: const Text("Trainer verhinderingen"),
          ),
          PopupMenuItem(
            value: PageEnum.spreadSheet.code.toString(),
            child: const Text("Schema & rooster"),
          ),
          PopupMenuItem(
            value: PageEnum.helpPage.code.toString(),
            child: const Text("Help"),
          ),
          _supervisorPopup(),
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

  PopupMenuItem _supervisorPopup() {
    if (AppData.instance.getTrainer().isSupervisor()) {
      return PopupMenuItem(
        value: PageEnum.supervisorPage.code.toString(),
        child: const Text("Hoofdtrainer pagina"),
      );
    } else {
      return const PopupMenuItem(
        height: 1,
        value: '0',
        child: Text(""),
      );
    }
  }

  Widget _actionSpreadsheetStatusInfo() {
    if (_getStackIndex() == PageEnum.spreadSheet.code) {
      return IconButton(
        icon: const Icon(Icons.info_outline),
        tooltip: 'Status info',
        onPressed: () => _showStatusHelpDialog(),
      );
    } else {
      return Container();
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

    if (_showInformTrainerMsg()) {
      _showInformTrainerDialog();
    }
  }

  void _showInformTrainerDialog() {
    _informSpreadsheetFirstTime = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Let op"),
          content: Text(AppConstants().informTrainerSpreadsheetMayChangeText),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Ik snap het"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
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
    WidgetHelper.instance.pushPage(context, HelpPage());
  }

  void _gotoAdminPage() {
    WidgetHelper.instance.pushPage(context, const AdminPage());
  }

  void _gotoSupervisorPage() {
    WidgetHelper.instance.pushPage(context, const SupervisorPage());
  }

  void _toggleActionEnabled(int index) {
    _actionEnabled = [
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
    ];
    _actionEnabled[index] = false;
  }

  void _checkAccessCodePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ac = prefs.getString('ac');
    if (ac != null) {
      _accessCode = ac;
    }
  }

  int _getStackIndex() => AppData.instance.stackIndex;
  void _setStackIndex(int value) {
    AppData.instance.stackIndex = value;
  }

  void _showStatusHelpDialog() {
    String title = _getBarTitleForSpreadhsheetPage();
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(status_help.helpText()),
      actions: [
        closeButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // ------------------------------
  bool _showInformTrainerMsg() {
    // return !AppData.instance.getTrainer().isSupervisor() &&
    return !AppData.instance.getTrainer().isSupervisor() &&
        _informSpreadsheetFirstTime &&
        AppData.instance.getSpreadsheet().status ==
            SpreadsheetStatus.underConstruction;
  }

  //--------------------
  bool _isLargeScreen() {
    return (AppHelper.instance.isWindows() || AppHelper.instance.isTablet());
  }
}

import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';

class ExcludeDaysPage extends StatefulWidget {
  const ExcludeDaysPage({super.key});

  @override
  State<ExcludeDaysPage> createState() => _ExcludeDaysPageState();
}

enum TextCtrl {
  excDayDate,
  excDayDescr,
  excPerFrom,
  excPerTo,
}

//----------------------------------------------------
class _ExcludeDaysPageState extends State<ExcludeDaysPage> with AppMixin {
  final AppHelper ah = AppHelper.instance;
  final List<TextEditingController> _textCtrls = [];
  ExcludeDay? _excludeDay;
  ExcludePeriod? _excludePeriod;
  List<ExcludeDay> _excludeDaysList = [];
  List<ExcludePeriod> _excludePeriodsList = [];

  @override
  void initState() {
    super.initState();
    _excludeDaysList = AppData.instance.excludeDays;
    _excludePeriodsList = AppData.instance.excludePeriods;
    for (int i = 0; i < TextCtrl.values.length; i++) {
      _textCtrls.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('Vakantiedagen'),
          _buildDataTable(context, _buildHeaderExcDays, _buildDataRowsExcDays),
          _buildAddRowExcDays(),
          wh.verSpace(30),
          _header('Zomer vakantie'),
          _buildDataTable(
              context, _buildHeaderExcPeriods, _buildDataRowsExcPeriods),
          _buildAddRowExcPeriod(),
          wh.verSpace(30),
          _buildCloseButtons(context),
        ],
      ),
    );
  }

  //-----------------------------------------------
  Widget _header(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    );
  }

  //---------------------------------------------
  Widget _buildCloseButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Close", style: TextStyle(color: Colors.blue))),
        wh.horSpace(10),
      ],
    );
  }

  //----------------------------------------------
  Widget _buildDataTable(
      BuildContext context, Function() buildHeader, Function() buildRows) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: MaterialStateColor.resolveWith((states) => c.lonuBlauw),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: buildHeader(),
      rows: buildRows(),
    );
  }

  //-------------------------------------------
  Widget _buildAddRowExcDays() {
    bool showAddButton = _excludeDay != null;
    TextEditingController ctrl1 = _textCtrls[TextCtrl.excDayDate.index];
    TextEditingController ctrl2 = _textCtrls[TextCtrl.excDayDescr.index];
    bool enableSaveButton =
        showAddButton && ctrl1.text.isNotEmpty && ctrl2.text.isNotEmpty;
    return Row(
      children: [
        _datePickerIfNeeded(showAddButton, TextCtrl.excDayDate, 'datum'),
        wh.horSpace(5),
        _descrFieldNeeded(showAddButton, TextCtrl.excDayDescr),
        wh.horSpace(5),
        _addOrSaveButton(enableSaveButton, _handleAddExcDay),
      ],
    );
  }

//-------------------------------------------
  Widget _buildAddRowExcPeriod() {
    bool showAddButton = _excludePeriod != null;
    TextEditingController ctrl1 = _textCtrls[TextCtrl.excPerFrom.index];
    TextEditingController ctrl2 = _textCtrls[TextCtrl.excPerTo.index];
    bool enableSaveButton =
        showAddButton && ctrl1.text.isNotEmpty && ctrl2.text.isNotEmpty;
    return Row(
      children: [
        _datePickerIfNeeded(showAddButton, TextCtrl.excPerFrom, 'Van'),
        wh.horSpace(5),
        _datePickerIfNeeded(showAddButton, TextCtrl.excPerTo, 'Tot'),
        _addOrSaveButton(enableSaveButton, _handleAddExcPeriods),
      ],
    );
  }

  //----------------------------------------
  Widget _datePickerIfNeeded(bool flag, TextCtrl textCtrlEnum, String label) {
    return flag
        ? SizedBox(
            width: 200,
            child: _datePicker(_textCtrls[textCtrlEnum.index], label),
          )
        : Container();
  }

  //----------------------------------------
  Widget _descrFieldNeeded(bool flag, TextCtrl textCtrlEnum) {
    return flag
        ? SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => setState(() {}),
              controller: _textCtrls[textCtrlEnum.index],
            ),
          )
        : Container();
  }

  //---------------------------------------------
  Widget _addOrSaveButton(bool flag, Function() handleSave) {
    Color color = flag ? Colors.green : Colors.blue;
    String txt = flag ? 'Save' : '+';
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => color)),
      onPressed: handleSave,
      child: Text(txt, style: const TextStyle(color: Colors.white)),
    );
  }

  //------------------------------------------
  List<DataColumn> _buildHeaderExcDays() {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('Datum', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Omschrijving',
            style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Aktie', style: TextStyle(fontStyle: FontStyle.italic))));

    return result;
  }

  //------------------------------------------
  List<DataColumn> _buildHeaderExcPeriods() {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('Van', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Tot', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Aktie', style: TextStyle(fontStyle: FontStyle.italic))));

    return result;
  }

  //---------------------------------------
  List<DataRow> _buildDataRowsExcDays() {
    List<DataRow> result = [];

    for (ExcludeDay excDay in _excludeDaysList) {
      List<DataCell> datacells = [];
      datacells.add(DataCell(Text(ah.formatDate(excDay.dateTime))));
      datacells.add(DataCell(Text(excDay.description)));
      datacells
          .add(DataCell(_deleteButton(_handleDeleteExcDay, excDay.dateTime)));
      result.add(DataRow(cells: datacells));
    }
    return result;
  }

  //---------------------------------------
  List<DataRow> _buildDataRowsExcPeriods() {
    List<DataRow> result = [];

    for (ExcludePeriod excPeriod in _excludePeriodsList) {
      List<DataCell> datacells = [];
      datacells.add(DataCell(Text(ah.formatDate(excPeriod.fromDate))));
      datacells.add(DataCell(Text(ah.formatDate(excPeriod.toDate))));
      datacells.add(
          DataCell(_deleteButton(_handleDeleteExcPeriod, excPeriod.fromDate)));

      result.add(DataRow(cells: datacells));
    }
    return result;
  }

  //-----------------------------------------
  void _handleAddExcDay() async {
    if (_excludeDay == null) {
      setState(() {
        _excludeDay = ExcludeDay(dateTime: DateTime.now(), description: "");
      });
    } else {
      _handleSaveExcDay();
    }
  }

  //-------------------------------------------
  void _handleSaveExcDay() async {
    TextEditingController ctrl1 = _textCtrls[TextCtrl.excDayDate.index];
    TextEditingController ctrl2 = _textCtrls[TextCtrl.excDayDescr.index];
    _excludeDay = ExcludeDay(
        dateTime: DateTime.parse(ctrl1.text), description: ctrl2.text);

    _excludeDaysList = await AppController.instance.addExcludeDay(_excludeDay!);
    setState(() {
      _excludeDay = null;
    });
  }

  //-----------------------------------------
  void _handleDeleteExcDay(DateTime dateTime) async {
    _excludeDaysList =
        await AppController.instance.deleteExcludeDay(date: dateTime);
    setState(() {
      _excludeDay = null;
    });
  }

  //-------------------------------------------
  void _handleAddExcPeriods() {
    if (_excludePeriod == null) {
      setState(() {
        _excludePeriod =
            ExcludePeriod(fromDate: DateTime.now(), toDate: DateTime.now());
      });
    } else {
      _handleSaveExcPeriod();
    }
  }

  //-------------------------------------------
  void _handleSaveExcPeriod() async {
    TextEditingController ctrl1 = _textCtrls[TextCtrl.excPerFrom.index];
    TextEditingController ctrl2 = _textCtrls[TextCtrl.excPerTo.index];
    _excludePeriod = ExcludePeriod(
        fromDate: DateTime.parse(ctrl1.text),
        toDate: DateTime.parse(ctrl2.text));

    _excludePeriodsList =
        await AppController.instance.addExcludePeriod(_excludePeriod!);
    setState(() {
      _excludePeriod = null;
    });
  }

  //-----------------------------------------
  void _handleDeleteExcPeriod(DateTime dateTime) async {
    _excludePeriodsList =
        await AppController.instance.deleteExcludePeriod(date: dateTime);
    setState(() {
      _excludePeriod = null;
    });
  }

  //-------------------------------------------
  Widget _datePicker(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          filled: true,
          prefixIcon: const Icon(Icons.calendar_today),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          )),
      readOnly: true,
      onTap: () => _selectDate(context, controller),
    );
  }

//--------------------------------------------
  Widget _deleteButton(Function(DateTime) function, DateTime dateTime) {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.delete,
        color: Colors.black45,
        size: 20.0,
      ),
      label: const Text(''),
      onPressed: () {
        function(dateTime);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  //------------------------------------------
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2024, 1),
        lastDate: DateTime(2025, 12));
    if (picked != null) {
      setState(() {
        controller.text = ah.formatDate(picked);
      });
    }
  }
}

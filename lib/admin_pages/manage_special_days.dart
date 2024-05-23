import 'package:flutter/material.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';

class ManageSpecialDaysPage extends StatefulWidget {
  const ManageSpecialDaysPage({super.key});

  @override
  State<ManageSpecialDaysPage> createState() => _ManageSpecialDaysPageState();
}

enum TextCtrl {
  summerFromDate,
  summerToDate,
  startgroupFromDate,
  startgroupToDate,
  specialDayDate,
  specialDayDescr,
}

//----------------------------------------------------
class _ManageSpecialDaysPageState extends State<ManageSpecialDaysPage>
    with AppMixin {
  final AppHelper ah = AppHelper.instance;
  final List<TextEditingController> _textCtrls = [];
  bool _addSpecialDay = false;
  SpecialDays? _specialDays;

  @override
  void initState() {
    super.initState();
    _specialDays = AppData.instance.specialDays.clone();
    for (int i = 0; i < TextCtrl.values.length; i++) {
      _textCtrls.add(TextEditingController());
    }
    _textCtrls[TextCtrl.startgroupFromDate.index].text =
        ah.formatDate(_specialDays!.startersGroup.fromDate);
    _textCtrls[TextCtrl.startgroupToDate.index].text =
        ah.formatDate(_specialDays!.startersGroup.toDate);
    _textCtrls[TextCtrl.summerFromDate.index].text =
        ah.formatDate(_specialDays!.summerPeriod.fromDate);
    _textCtrls[TextCtrl.summerToDate.index].text =
        ah.formatDate(_specialDays!.summerPeriod.toDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wh.adminPageAppBar(context, 'Beheer van speciale dagen'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wh.verSpace(10),
            _subHeader('Vakantiedagen'),
            _buildDataTable(context, _buildHeaderForSpecialDays,
                _buildDataRowsForSpecialDays),
            _buildAddRowForSpecialDays(),
            wh.verSpace(20),
            _subHeader('Zomer vakantie'),
            _buildSummerPeriod(),
            wh.verSpace(20),
            _subHeader('Starters groep'),
            _buildStartgroupPeriod(),
            wh.verSpace(30),
            _buildCloseAndSaveButtons(context),
            wh.verSpace(10),
          ],
        ),
      ),
    );
  }

  //-----------------------------------------------
  Widget _subHeader(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    );
  }

  //---------------------------------------------
  Widget _buildCloseAndSaveButtons(BuildContext context) {
    bool flag = _isDirty() && _isValid();
    Color saveColor = flag ? Colors.green : Colors.blue[200]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: flag ? _onSaveClicked : null,
            child: Text("Save", style: TextStyle(color: saveColor))),
        wh.popPageButton(context),
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
      headingRowColor: WidgetStateColor.resolveWith((states) => c.lonuBlauw),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: buildHeader(),
      rows: buildRows(),
    );
  }

  //-------------------------------------------
  Widget _buildAddRowForSpecialDays() {
    if (!_addSpecialDay) {
      return ElevatedButton(
          onPressed: _onAddSpecialDayClicked, child: const Text('+'));
    } else {
      return Row(
        children: [
          _datePicker(TextCtrl.specialDayDate, 'datum'),
          wh.horSpace(5),
          _descrFieldNeeded(TextCtrl.specialDayDescr),
        ],
      );
    }
  }

  //-------------------------------------------------
  void _onAddSpecialDayClicked() {
    setState(() {
      _addSpecialDay = true;
      _textCtrls[TextCtrl.specialDayDate.index].text = '';
      _textCtrls[TextCtrl.specialDayDescr.index].text = '';
    });
  }

  //---------------------------------------
  List<DataRow> _buildDataRowsForSpecialDays() {
    List<DataRow> result = [];

    for (SpecialDay specialDay in _specialDays!.excludeDays) {
      List<DataCell> datacells = [];
      datacells.add(DataCell(Text(ah.formatDate(specialDay.dateTime))));
      datacells.add(DataCell(Text(specialDay.description)));
      datacells.add(DataCell(_deleteSpecialDayButton(specialDay.dateTime)));

      result.add(DataRow(cells: datacells));
    }
    return result;
  }

//-------------------------------------------
  Widget _buildSummerPeriod() {
    return Row(
      children: [
        _datePicker(TextCtrl.summerFromDate, 'Van'),
        wh.horSpace(5),
        _datePicker(TextCtrl.summerToDate, 'Tot'),
      ],
    );
  }

//-------------------------------------------
  Widget _buildStartgroupPeriod() {
    return Row(
      children: [
        _datePicker(TextCtrl.startgroupFromDate, 'Van'),
        wh.horSpace(5),
        _datePicker(TextCtrl.startgroupToDate, 'Tot'),
      ],
    );
  }

  //----------------------------------------
  Widget _descrFieldNeeded(TextCtrl textCtrlEnum) {
    return SizedBox(
      width: 300,
      child: TextField(
        onChanged: (value) => setState(() {}),
        controller: _textCtrls[textCtrlEnum.index],
      ),
    );
  }

  //------------------------------------------
  List<DataColumn> _buildHeaderForSpecialDays() {
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

  //-------------------------------------------
  Widget _datePicker(TextCtrl textCtrl, String label) {
    TextEditingController controller = _textCtrls[textCtrl.index];
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            filled: true,
            prefixIcon: const Icon(Icons.calendar_today),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            )),
        readOnly: true,
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

//--------------------------------------------
  Widget _deleteSpecialDayButton(DateTime dateTime) {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.delete,
        color: Colors.black45,
        size: 20.0,
      ),
      label: const Text(''),
      onPressed: () {
        _handleDeleteSpecialDay(dateTime);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  //-----------------------------------------
  void _handleDeleteSpecialDay(DateTime dateTime) async {
    setState(() {
      _specialDays!.excludeDays
          .removeWhere((e) => ah.isSameDate(e.dateTime, dateTime));
    });
  }

  //------------------------------------------
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime firstDate = DateTime(DateTime.now().year, 1, 1);
    final DateTime lastDate = DateTime.now().copyWith(year: firstDate.year + 1);
    String text = controller.text;
    final DateTime initDate =
        text.isEmpty ? DateTime.now() : DateTime.parse(text);

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: firstDate,
        lastDate: lastDate);

    if (picked != null) {
      setState(() {
        controller.text = ah.formatDate(picked);
        _specialDays = _updateSpecialDaysObject();
      });
    }
  }

  //--------------------------------------
  SpecialDays _updateSpecialDaysObject() {
    List<DateTime> dates =
        List.generate(4, (index) => DateTime.parse(_textCtrls[index].text));

    SpecialPeriod summerPeriod =
        SpecialPeriod(fromDate: dates[0], toDate: dates[1]);
    SpecialPeriod startersGroup =
        SpecialPeriod(fromDate: dates[2], toDate: dates[3]);
    SpecialDays result = SpecialDays(
        excludeDays: [],
        summerPeriod: summerPeriod,
        startersGroup: startersGroup);

    result.excludeDays.addAll(_specialDays!.excludeDays);
    return result;
  }

  //-------------------------------------
  bool _isDirty() {
    bool b =
        AppData.instance.specialDays == _specialDays && _addSpecialDay == false;
    return !b;
  }

  //----------------------------------------
  bool _isValid() {
    bool b = _addSpecialDay == false ||
        (_textCtrls[TextCtrl.specialDayDate.index].text.isNotEmpty &&
            _textCtrls[TextCtrl.specialDayDescr.index].text.isNotEmpty);
    return _specialDays != null && _specialDays!.isValid() && b;
  }

  //----------------------------------
  void _onSaveClicked() async {
    if (_addSpecialDay) {
      _specialDays!.excludeDays.add(SpecialDay(
          dateTime:
              DateTime.parse(_textCtrls[TextCtrl.specialDayDate.index].text),
          description: _textCtrls[TextCtrl.specialDayDescr.index].text));
    }

    _specialDays = _updateSpecialDaysObject();
    await AppController.instance.saveSpecialDays(_specialDays!);
    await AppController.instance.getSpecialDays();
    await AppController.instance.getTrainerGroups();
    await AppController.instance.generateOrRetrieveSpreadsheet();
    wh.showSnackbar(color: Colors.green, "Met succes opgeslagen");
    setState(() {
      _specialDays = AppData.instance.specialDays.clone();
      _addSpecialDay = false;
    });
  }
}

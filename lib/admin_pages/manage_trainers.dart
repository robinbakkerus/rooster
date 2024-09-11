import 'package:flutter/material.dart';
import 'package:rooster/admin_pages/trainer_detail_page.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_constants.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';

class ManageTrainers extends StatefulWidget {
  const ManageTrainers({super.key});

  @override
  State<ManageTrainers> createState() => _ManageTrainersState();
}

class _ManageTrainersState extends State<ManageTrainers> with AppMixin {
  List<Trainer> _trainerList = [];
  Widget? _dataTable;

  @override
  void initState() {
    _getTrainers();
    AppEvents.onTrainerDataReadyEvent(_onTrainerDataReady);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wh.adminPageAppBar(context, 'Beheer van trainers'),
      body: _buildBody(),
    );
  }

  //----------------------------------------
  void _getTrainers() async {
    await AppController.instance.getAllTrainerData();
    AppEvents.fireTrainerDataReady();
  }

  //-------------------------------------------------
  void _onTrainerDataReady(TrainerDataReadyEvent event) async {
    _trainerList = AppData.instance.getAllTrainers();
    if (mounted) {
      setState(() {
        _dataTable = _buildDataTable(context, _buildHeaderRow, _buildDataRows);
      });
    }
  }

  //--------------------------------------------------
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wh.verSpace(10),
          _dataTable ?? Container(),
          wh.verSpace(10),
          _buildAddTrainerButton(),
          wh.verSpace(5),
          wh.popPageButton(context),
        ],
      ),
    );
  }

  //----------------------------------------------
  Widget _buildDataTable(
      BuildContext context, Function() buildHeader, Function() buildDataRows) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: WidgetStateColor.resolveWith((states) => c.lonuBlauw),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      showCheckboxColumn: false,
      columns: buildHeader(),
      rows: buildDataRows(),
    );
  }

  //------------------------------------------
  List<DataColumn> _buildHeaderRow() {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('PK', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Naam', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Email', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Access code',
            style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label: Text('Akties', style: TextStyle(fontStyle: FontStyle.italic))));
    return result;
  }

//---------------------------------------
  List<DataRow> _buildDataRows() {
    return _trainerList
        .map((e) => DataRow(
              cells: _buildDataCells(e),
            ))
        .toList();
  }

  //-----------------------------------------------------
  List<DataCell> _buildDataCells(Trainer trainer) {
    List<DataCell> list = [];
    list.add(DataCell(Text(trainer.pk)));
    list.add(DataCell(Text(trainer.fullname)));
    list.add(DataCell(Text(trainer.email)));
    list.add(DataCell(Text(trainer.accessCode)));
    list.add(DataCell(
      _buildActionButtons(trainer),
      onTap: () {},
    ));
    return list;
  }

  //-----------------------------------------------------
  Widget _buildActionButtons(Trainer trainer) {
    return Row(
      children: [
        _buildActionButton(
            onPressed: () => _viewTrainer(trainer), iconData: Icons.info),
        _buildActionButton(
            onPressed: () => _editTrainer(trainer), iconData: Icons.edit),
        _buildActionButton(
            onPressed: () => _deleteTrainer(trainer), iconData: Icons.delete),
      ],
    );
  }

  //----------------------------------------------
  void _viewTrainer(Trainer trainer) {
    _showTrainerDetailPageDialog(trainer: trainer, viewOnly: true);
  }

  //-----------------------------------------------------
  void _editTrainer(Trainer trainer) {
    _showTrainerDetailPageDialog(trainer: trainer, viewOnly: false);
  }

  //------------------------------------------------
  void _deleteTrainer(Trainer trainer) {
    String content = '''
Weet je zeker dat je ${trainer.fullname} wilt verwijderen?
''';
    wh.showConfirmDialog(context,
        title: 'Delete Trainer ${trainer.fullname}',
        content: content,
        yesFunction: () => _doDeleteTrainer(trainer));
  }

  void _doDeleteTrainer(Trainer trainer) {
    AppController.instance.deleteTrainer(trainer);
  }

  //--------------------------------------------------

  //-------------------------------------------
  Widget _buildAddTrainerButton() {
    return ElevatedButton(
        onPressed: _onAddTrainerClicked, child: const Text('+'));
  }

  //--------------------------------------------------
  void _onAddTrainerClicked() {
    Trainer newTrainer = Trainer.empty();
    newTrainer.prefValues.addAll(_buildNewPrefValues());
    _showTrainerDetailPageDialog(trainer: newTrainer, viewOnly: false);
  }

  //--------------------------------
  void _showTrainerDetailPageDialog(
      {required Trainer trainer, bool viewOnly = false}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: TrainerDetailPage(
          trainer: trainer,
          viewOnly: viewOnly,
        ));
      },
    );

    await AppController.instance.getAllTrainerData();
    setState(() {});
  }

  //----------------------------------------
  Widget _buildActionButton(
      {required Function() onPressed, required IconData iconData}) {
    return IconButton(
      onPressed: () => onPressed(),
      icon: Icon(iconData),
    );
  }

  //-----------------------------------------------
  List<TrainerPref> _buildNewPrefValues() {
    return [
      TrainerPref(paramName: 'dinsdag', value: 0),
      TrainerPref(paramName: 'donderdag', value: 0),
      TrainerPref(paramName: 'zaterdag', value: 0),
      TrainerPref(paramName: Groep.pr.name, value: 0),
      TrainerPref(paramName: Groep.r1.name, value: 0),
      TrainerPref(paramName: Groep.r2.name, value: 0),
      TrainerPref(paramName: Groep.r3.name, value: 0),
      TrainerPref(paramName: Groep.zamo.name, value: 0),
      TrainerPref(paramName: Groep.sg.name, value: 0),
      TrainerPref(paramName: Groep.zomer.name, value: 0),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:rooster/admin_pages/trainer_detail_page.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/util/app_mixin.dart';

class ManageTrainers extends StatefulWidget {
  const ManageTrainers({super.key});

  @override
  State<ManageTrainers> createState() => _ManageTrainersState();
}

class _ManageTrainersState extends State<ManageTrainers> with AppMixin {
  List<Trainer> _trainerList = [];

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
  void _onTrainerDataReady(TrainerDataReadyEvent event) {
    setState(() {
      _trainerList = AppData.instance.getAllTrainers();
    });
  }

  //--------------------------------------------------
  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wh.verSpace(10),
        _buildDataTable(context, _buildHeaderRow, _buildDataRows),
        wh.verSpace(10),
        _buildAddTrainerButton(),
      ],
    );
  }

  //----------------------------------------------
  Widget _buildDataTable(
      BuildContext context, Function() buildHeader, Function() buildDataRows) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: MaterialStateColor.resolveWith((states) => c.lonuBlauw),
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
    lp('delete ${trainer.fullname}');
  }

  //--------------------------------------------------

  //-------------------------------------------
  Widget _buildAddTrainerButton() {
    return ElevatedButton(
        onPressed: _onAddTrainerClicked, child: const Text('+'));
  }

  //--------------------------------------------------
  void _onAddTrainerClicked() {
    _showTrainerDetailPageDialog(trainer: Trainer.empty(), viewOnly: false);
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

    // if (dialogResult == true && yesFunction != null) {
    //   yesFunction();
    // } else if (dialogResult == false && noFunction != null) {
    //   noFunction();
    // }
  }

  //----------------------------------------
  Widget _buildActionButton(
      {required Function() onPressed, required IconData iconData}) {
    return IconButton(
      onPressed: () => onPressed(),
      icon: Icon(iconData),
    );
  }
}

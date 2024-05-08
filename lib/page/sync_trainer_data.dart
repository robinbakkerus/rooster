import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';

class SyncTrainerData extends StatefulWidget {
  const SyncTrainerData({super.key, required this.runModus});
  final RunMode runModus;
  @override
  State<SyncTrainerData> createState() => _SyncTrainerDataState();
}

//----------------------------------------------------------------
class _SyncTrainerDataState extends State<SyncTrainerData> with AppMixin {
  String _clipboardText = '';
  String _importStatusMsg = '';
  bool _validJson = false;

  @override
  Widget build(BuildContext context) {
    return widget.runModus == RunMode.prod
        ? _buildDownloadDataDialog()
        : _buildUploadDataDialog();
  }

  //----------- triggered in prod
  Widget _buildDownloadDataDialog() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Download data uit Prod omgeving'),
          _downloadButton(),
          wh.verSpace(10),
          _textField(),
          wh.verSpace(10),
          _clipboardText.isEmpty
              ? Container()
              : const Text(
                  'Data is naar clipboard gekopieerd!',
                  style: TextStyle(color: Colors.green, fontSize: 20),
                ),
          _buildCloseButton(context),
        ],
      ),
    );
  }

//----------- triggered in acc
  Widget _buildUploadDataDialog() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload data in Acc omgeving'),
          _pasteFromClipboardButton(),
          wh.verSpace(10),
          _textField(),
          wh.verSpace(10),
          _clipboardText.isEmpty
              ? Container()
              : _importStatusMsg.isEmpty
                  ? _importToAccButton()
                  : Text(
                      _importStatusMsg,
                      style: const TextStyle(color: Colors.green, fontSize: 20),
                    ),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  //-----------------------------
  Widget _downloadButton() {
    return ElevatedButton.icon(
        onPressed: _downLoadData,
        icon: const Icon(Icons.download),
        label: const Text('Download'));
  }

  //-----------------------------
  Widget _pasteFromClipboardButton() {
    return ElevatedButton.icon(
        onPressed: _pasteFromClipboard,
        icon: const Icon(Icons.paste),
        label: const Text('Paste from clipboard'));
  }

//-----------------------------
  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    setState(() {
      _clipboardText = data!.text!;
      _validJson =
          (_clipboardText.startsWith('{') && _clipboardText.endsWith('}'));
    });

    if (!_validJson) {
      wh.showSnackbar('Ongeldige json', color: Colors.red);
    }
  }

  //-----------------------------
  Widget _importToAccButton() {
    return ElevatedButton.icon(
        onPressed: _validJson ? _importTrainerData : null,
        icon: const Icon(Icons.import_contacts),
        label: const Text('Import into ACC'));
  }

  //----------------------------------------
  void _downLoadData() async {
    _clipboardText = await _getSchemasAsJson();
    _copyToClipboard();
    setState(() {});
  }

  //----------------------------------------
  Future<String> _getSchemasAsJson() async {
    DateTime nextMonth =
        DateTime.now().copyWith(month: DateTime.now().month + 1);
    AppController.instance.setActiveDate(nextMonth);

    List<TrainerData> trainerData =
        await AppController.instance.getAllTrainerData();

    String jsonT = _getJsonForTrainers(trainerData);
    String jsonS = _getJsonForSchemas(trainerData);

    String json = '''{"trainers": <T>, \r"schemas": <S>}''';
    json = json.replaceAll("<T>", jsonT);
    json = json.replaceAll("<S>", jsonS);
    return json;
  }

  //------------------------------------------
  String _getJsonForSchemas(List<TrainerData> trainerData) {
    String jsonS = "[";
    for (TrainerData td in trainerData) {
      TrainerSchema schema = td.trainerSchemas;
      jsonS = '$jsonS\r${schema.toJson()},';
    }

    //remove last comma
    jsonS = jsonS.substring(0, jsonS.length - 1);
    //- add ']'
    jsonS = '$jsonS\r]';
    return jsonS;
  }

//------------------------------------------
  String _getJsonForTrainers(List<TrainerData> trainerData) {
    String jsonT = "[";
    for (TrainerData td in trainerData) {
      Trainer trainer = td.trainer;
      jsonT = '$jsonT\r${trainer.toJson()},';
    }

    //remove last comma
    jsonT = jsonT.substring(0, jsonT.length - 1);
    //- add ']'
    jsonT = '$jsonT\r]';
    return jsonT;
  }

  //----------------------------------------
  void _importTrainerData() async {
    bool importOkay =
        await AppController.instance.importTrainerData(_clipboardText);
    if (importOkay) {
      setState(() {
        _importStatusMsg = 'Met succes trainer data geimporteerd';
      });
    } else {
      setState(() {
        _importStatusMsg = 'Fout tijdens importeren van trainer data';
      });
    }
  }

  //-----------------------------------------
  Widget _textField() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            _clipboardText,
            style: const TextStyle(fontSize: 8),
          )),
    );
  }

  //--------------------------------
  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _clipboardText));
  }

  //---------------------------------------------
  Widget _buildCloseButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Close", style: TextStyle(color: Colors.blue))),
      ],
    );
  }
}

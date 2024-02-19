import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:rooster/widget/send_accesscode_widget.dart';

class AskAccessCodePage extends StatefulWidget {
  const AskAccessCodePage({super.key});

  @override
  State<AskAccessCodePage> createState() => _AskAccessCodePageState();
}

class _AskAccessCodePageState extends State<AskAccessCodePage> with AppMixin {
  final List<TextEditingController> _textCtrls = [];
  final List<FocusNode> _focusNodes = [];
  final _blankChar = '\u200B';
  bool _findTriggered = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    for (int i = 0; i < 4; i++) {
      _textCtrls.add(TextEditingController(text: _blankChar));
      _textCtrls[i].addListener(() => _onTextFieldChanged(i));
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      _textCtrls[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = _buildScaffold();
    return scaffold;
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: AppData.instance.screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Vul je toegangscode in'),
                Container(
                  height: 20,
                ),
                SizedBox(
                  width: 500,
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTextField(0),
                      _buildTextField(1),
                      _buildTextField(2),
                      _buildTextField(3),
                    ],
                  ),
                ),
                wh.verSpace(10),
                TextButton(
                    onPressed: _onSendAccessCode,
                    child: const Text(
                      'Toegangscode vergeten ?',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(int index) {
    bool autoFocus = index == 0;
    TextEditingController ctrl = _textCtrls[index];
    return SizedBox(
      width: 60,
      height: 60,
      child: Center(
        child: TextField(
          autofocus: autoFocus,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.top,
          focusNode: _focusNodes[index],
          controller: _textCtrls[index],
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            String useValue = value.replaceAll(_blankChar, '').toUpperCase();
            if (ctrl.text != useValue) {
              ctrl.text = useValue;
              // ctrl.value = ctrl.value.replaced(replacementRange, replacementString) copyWith(text: value.toUpperCase());
            }

            if (index < 3 && ctrl.text.isNotEmpty) {
              _focusNodes[index + 1].requestFocus();
            } else {
              if (index > 0 && value.isEmpty) {
                _focusNodes[index - 1].requestFocus();
                ctrl.text = _blankChar;
              }
            }
          },
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  void _onTextFieldChanged(int index) async {
    String text = '';
    for (int i = 0; i < 4; i++) {
      text += _textCtrls[i].text.replaceAll(_blankChar, '');
    }
    if (text.length == 4 && !_findTriggered) {
      String accessCode = text.toUpperCase();
      await _findTrainer(accessCode);
    }
  }

  Future<void> _findTrainer(String accesscode) async {
    _findTriggered = true;
    bool flag = await AppController.instance.findTrainer(accesscode);
    _findTriggered = false;
    if (!flag) {
      final String msg =
          'Kan geen trainer met toegangscode $accesscode vinden!';
      wh.showSnackbar(msg, color: Colors.orange);
    }
  }

  void _onSendAccessCode() {
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("CLose"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text('Stuur toegangscode'),
      content: const SizedBox(
        height: 150,
        child: SendAccessCodeWidget(),
      ),
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
}

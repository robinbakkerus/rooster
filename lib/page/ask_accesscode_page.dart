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
  final _textCtrl1 = TextEditingController();

  bool _findTriggered = false;

  @override
  void initState() {
    super.initState();

    _textCtrl1.addListener(_onTextFieldChanged);
  }

  @override
  void dispose() {
    _textCtrl1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text('Vul je accesscode in'),
                Container(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _textCtrl1,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          if (_textCtrl1.text != value.toUpperCase()) {
                            _textCtrl1.value = _textCtrl1.value
                                .copyWith(text: value.toUpperCase());
                          }
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'accesscode',
                        ),
                      ),
                    ),
                  ],
                ),
                wh.verSpace(10),
                TextButton(
                    onPressed: _onSendAccessCode,
                    child: const Text(
                      'Accescode vergeten ?',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTextFieldChanged() async {
    final text = _textCtrl1.text;
    if (text.length == 4 && !_findTriggered) {
      String accessCode = _textCtrl1.text.toUpperCase();
      await _findTrainer(accessCode);
    }
  }

  Future<void> _findTrainer(String accesscode) async {
    _findTriggered = true;
    bool flag = await AppController.instance.findTrainer(accesscode);
    _findTriggered = false;
    if (!flag) {
      final String msg = 'Kan geen trainer met accesscode $accesscode vinden!';
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
      title: const Text('Stuur accesscode'),
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

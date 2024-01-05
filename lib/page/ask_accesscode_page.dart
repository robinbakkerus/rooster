import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/util/page_mixin.dart';
import 'package:flutter/material.dart';

class AskAccessCodePage extends StatefulWidget {
  const AskAccessCodePage({super.key});

  @override
  State<AskAccessCodePage> createState() => _AskAccessCodePageState();
}

class _AskAccessCodePageState extends State<AskAccessCodePage> with PageMixin {
  final _textCtrl = TextEditingController();
  bool _findTriggered = false;

  @override
  void initState() {
    super.initState();

    _textCtrl.addListener(_onTextFieldChanged);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
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
                        controller: _textCtrl,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          if (_textCtrl.text != value.toUpperCase()) {
                            _textCtrl.value = _textCtrl.value
                                .copyWith(text: value.toUpperCase());
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'accesscode',
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                    ),
                    //
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTextFieldChanged() async {
    final text = _textCtrl.text;
    if (text.length == 4 && !_findTriggered) {
      String accessCode = _textCtrl.text.toUpperCase();
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
}

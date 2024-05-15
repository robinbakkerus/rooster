import 'package:flutter/material.dart';
import 'package:rooster/data/app_version.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';

class HelpPage extends StatelessWidget with AppMixin {
  HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help pagina'),
            wh.verSpace(10),
            Row(
              children: [
                const Text(
                    'Een korte video over het gebruik van deze app vind je'),
                Link(
                    uri: Uri.parse(
                        'https://drive.google.com/file/d/1P1VRW5GXnh7jFimqcddL_0VJlvLq3Qrs/view'),
                    target: LinkTarget.blank,
                    builder: (context, followLink) {
                      return TextButton(
                        onPressed: followLink,
                        child: const Text(
                          'hier',
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    }),
              ],
            ),
            wh.verSpace(10),
            _buildFaq(),
            wh.verSpace(10),
            Text('Versie: $appVersion'),
            wh.verSpace(10),
            OutlinedButton(
                onPressed: _removeAccessCodePref,
                child: const Text('Remove cookie')),
            wh.verSpace(10),
            wh.popPageButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFaq() {
    return RichText(text: const TextSpan(text: _faq, children: []));
  }

  static const String _faq = '''
Faq
Hoe kan ik een training ruilen als het schema definitief is?

  Op 2 manieren: 
   1) Jijzelf gaat naar het schema en klikt op [Maak schema open voor wijzigingen], klikt dan op jouw op de dag die je wilt ruilen, en kiest dan een andere trainer.
   2) Degene die jouw training wil overnemen gaat naar het schema en klikt op [Maak schema open voor wijzigingen], klikt dan op jouw op de dag die je wilt ruilen, 
      dan kan hij/zij alleen nog maar zijn/haar eigen naam invullen.    
   In beide gevallen worden er mails verstuurd naar de hoofdtrainer en diegene de training overneemt.

Wat is de betekenis van de status van een schema?

  (Actief) betekent dat dit schema definitief is, het is dan ook zichtbaar voor iedereen op de Lonu website. Er kunnen dan ook geen verhinderingen meer worden opgegeven. 
  Er kunnen nog altijd trainingen worden geruild.
  
  (Nieuw) betekent dat schema nog niet definitief is, er kunnen nog verhinderingen worden opgegeven. Het schema dat getoond wordt kan dan ook nog wijzigen.

Wat gebeurt er als ik geen verhindering heb opgegeven? 

  In dit geval neemt het programma dat je altijd kan op de dagen die je hebt aangeving in Trainer settings pagina.
''';

  void _removeAccessCodePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ac', '');
  }
}

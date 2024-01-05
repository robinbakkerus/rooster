import 'package:flutter/material.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'package:universal_html/html.dart' as html;

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('''Deze pagina moet nog worden gemaakt!'''),
        WH.verSpace(100),
        OutlinedButton(
            onPressed: _removeCookie, child: const Text('Remove cookie')),
      ],
    );
  }

  void _removeCookie() {
    html.document.cookie = "ac=";
  }
}

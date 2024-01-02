import 'package:rooster/widget/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ShowRosterCsvHtmlView extends StatefulWidget {
  final String csv;
  final String html;
  const ShowRosterCsvHtmlView(
      {super.key, required this.csv, required this.html});

  @override
  State<ShowRosterCsvHtmlView> createState() => _ShowRosterCsvHtmlViewState();
}

class _ShowRosterCsvHtmlViewState extends State<ShowRosterCsvHtmlView> {
  int _showText = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            WH.verSpace(10),
            _radioButtons(),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            _showText == 1 ? _showHtml() : _showCsv(),
            WH.verSpace(10),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Sluit"))
          ],
        ),
      ),
    );
  }

  Widget _radioButtons() {
    return Row(children: [
      const Text('Show HTML'),
      Radio(
        value: 1,
        groupValue: _showText,
        onChanged: (value) {
          setState(() {
            _showText = value!;
          });
        },
      ),
      WH.horSpace(20),
      const Text('Show CSV'),
      Radio(
        value: 2,
        groupValue: _showText,
        onChanged: (value) {
          setState(() {
            _showText = value!;
          });
        },
      ),
    ]);
  }

  Widget _showCsv() {
    List lines = widget.csv.split('\n');
    String htmlFromCsv = '<div>';
    htmlFromCsv += lines.join('<br>');
    htmlFromCsv += '</div>';

    return HtmlWidget(
      htmlFromCsv,
      renderMode: RenderMode.column,
      textStyle: const TextStyle(fontSize: 14),
    );
  }

  Widget _showHtml() {
    return HtmlWidget(
      widget.html,
      customStylesBuilder: (element) {
        if (element.classes.contains('toprow')) {
          return {'background-color': 'yellow'};
        }

        return null;
      },

      renderMode: RenderMode.column,

      // set the default styling for text
      textStyle: const TextStyle(fontSize: 14),
    );
  }
}

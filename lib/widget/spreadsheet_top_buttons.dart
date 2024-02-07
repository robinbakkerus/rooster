import 'package:flutter/material.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';

class SpreadsheetTopButtons extends StatelessWidget {
  final int _index;
  const SpreadsheetTopButtons({super.key, required int index}) : _index = index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildButton('Schema', PageEnum.spreadSheet, 0),
          _buildButton('Voortgang', PageEnum.progess, 1),
          _buildButton('Beschikbaarheid', PageEnum.availability, 2),
        ],
      ),
    );
  }

  //-------------------------
  Widget _buildButton(String text, PageEnum page, int index) {
    Color color = _index == index ? Colors.grey : Colors.black;
    BoxDecoration? box = _index == index
        ? const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.blue, width: 2.0)))
        : null;

    return Container(
      decoration: box,
      child: TextButton(
        onPressed: () => _onTopButtonPressed(page),
        style: TextButton.styleFrom(
          foregroundColor: color,
        ),
        child: Text(text),
      ),
    );
  }

  //--------------------------
  void _onTopButtonPressed(PageEnum page) {
    AppEvents.fireShowPage(page);
  }
}

import 'package:flutter/material.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';

class SpreadsheetTopButtons extends StatelessWidget {
  final int index;
  const SpreadsheetTopButtons({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => _onTopButtonPressed(PageEnum.spreadSheet),
          style: TextButton.styleFrom(
            foregroundColor: index == 0 ? Colors.grey : Colors.black,
          ),
          child: const Text('Schema'),
        ),
        TextButton(
            onPressed: () => _onTopButtonPressed(PageEnum.progess),
            style: TextButton.styleFrom(
              foregroundColor: index == 1 ? Colors.grey : Colors.black,
            ),
            child: const Text('Voortgang')),
        TextButton(
            onPressed: () => _onTopButtonPressed(PageEnum.availability),
            style: TextButton.styleFrom(
              foregroundColor: index == 2 ? Colors.grey : Colors.black,
            ),
            child: const Text('Beschikbaarheid')),
      ],
    );
  }

  void _onTopButtonPressed(PageEnum page) {
    AppEvents.fireShowPage(page);
  }
}

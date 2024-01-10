import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';

class RadioButtonWidget extends StatefulWidget {
  final Trainer? trainer;
  final String paramName;
  final int dateIndex;
  final int available;
  final int rbValue;
  final Color color;

  // you have to provide eithe dateIndex && value or trainer && paramName
  const RadioButtonWidget({
    required Key key,
    required this.rbValue,
    required this.color,
    this.dateIndex = -1,
    this.available = 0,
    this.paramName = '',
    this.trainer,
  }) : super(key: key);

  factory RadioButtonWidget.forAvailability({
    required Key key,
    required int rbValue,
    required Color color,
    required int dateIndex,
    required int available,
  }) {
    return RadioButtonWidget(
        key: key,
        rbValue: rbValue,
        color: color,
        dateIndex: dateIndex,
        available: available);
  }

  factory RadioButtonWidget.forPreference({
    required Key key,
    required int rbValue,
    required Color color,
    required Trainer trainer,
    required String paramName,
  }) {
    return RadioButtonWidget(
        key: key,
        rbValue: rbValue,
        color: color,
        trainer: trainer,
        paramName: paramName);
  }
  @override
  State<RadioButtonWidget> createState() => _RadioButtonWidgetState();
}

///------------------------------------------------
class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  int? selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return _radioButton();
  }

  Widget _radioButton() {
    int value = 0;
    if (widget.trainer == null) {
      value = widget.available;
    } else {
      value = _getValueFromParamName(widget.trainer!);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Radio<int>(
        activeColor: widget.color,
        value: value,
        groupValue: widget.rbValue,
        onChanged: (val) => onChangeValue(val),
      ),
    );
  }

  int _getValueFromParamName(Trainer trainer) {
    Map<String, dynamic> map = trainer.toMap();
    return map[widget.paramName];
  }

  void onChangeValue(int? value) {
    setState(() {
      if (widget.trainer == null) {
        AppData.instance.updateAvailability(
            dateIndex: widget.dateIndex, newValue: widget.rbValue);
        AppEvents.fireSchemaUpdated();
      } else {
        if (widget.paramName.isNotEmpty) {
          AppEvents.fireTrainerPrefUpdated(widget.paramName, widget.rbValue);
        }
      }
    });
  }
}

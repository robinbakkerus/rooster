import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/util/app_mixin.dart';

class RadioButtonWidget extends StatefulWidget {
  final String paramName;
  final int dateIndex;
  final int value;
  final int rbValue;
  final Color color;

  // you have to provide either dateIndex && value or paramName && value
  const RadioButtonWidget({
    required Key key,
    required this.rbValue,
    required this.color,
    this.dateIndex = -1,
    this.paramName = '',
    this.value = 0,
  }) : super(key: key);

  factory RadioButtonWidget.forAvailability({
    required Key key,
    required int rbValue,
    required Color color,
    required int dateIndex,
    required int value,
  }) {
    return RadioButtonWidget(
        key: key,
        rbValue: rbValue,
        color: color,
        dateIndex: dateIndex,
        value: value);
  }

  factory RadioButtonWidget.forPreference({
    required Key key,
    required int rbValue,
    required Color color,
    required String paramName,
    required int value,
  }) {
    return RadioButtonWidget(
        key: key,
        rbValue: rbValue,
        color: color,
        paramName: paramName,
        value: value);
  }
  @override
  State<RadioButtonWidget> createState() => _RadioButtonWidgetState();
}

///------------------------------------------------
class _RadioButtonWidgetState extends State<RadioButtonWidget> with AppMixin {
  int? selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return _radioButton();
  }

  Widget _radioButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Radio<int>(
        activeColor: widget.color,
        value: widget.value,
        groupValue: widget.rbValue,
        onChanged: (val) => onChangeValue(val),
      ),
    );
  }

  void onChangeValue(int? value) {
    setState(() {
      if (widget.paramName.isEmpty) {
        AppData.instance.updateAvailability(
            dateIndex: widget.dateIndex, newValue: widget.rbValue);
        AppEvents.fireSchemaUpdated();
      } else {
        AppEvents.fireTrainerPrefUpdated(widget.paramName, widget.rbValue);
      }
    });
  }
}

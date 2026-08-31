import 'package:flutter/material.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';
import 'package:rooster/util/app_mixin.dart';

class RadioButtonWidget extends StatefulWidget {
  final String paramName;
  final int
      buttonValue; //this corresponds with 0 = not-available, 1 = available, 2 = if-needed
  final bool isEditable;
  final bool forAvailability;
  final AvailableData availableData;
  final int actualValue;

  // you have to provide either dateIndex && value or paramName && value
  const RadioButtonWidget({
    required Key key,
    required this.buttonValue,
    required this.isEditable,
    required this.forAvailability,
    required this.availableData,
    required this.paramName,
    required this.actualValue,
  }) : super(key: key);

  factory RadioButtonWidget.forAvailability({
    required Key key,
    required int buttomValue,
    required AvailableData availableData,
    required bool isEditable,
  }) {
    int value = availableData.value;
    return RadioButtonWidget(
        key: key,
        buttonValue: buttomValue,
        isEditable: isEditable,
        availableData: availableData,
        actualValue: value,
        paramName: '',
        forAvailability: true);
  }

  factory RadioButtonWidget.forPreference(
      {required Key key,
      required int rbValue,
      required Color color,
      required String paramName,
      required int value,
      required bool isEditable}) {
    return RadioButtonWidget(
        key: key,
        buttonValue: rbValue,
        paramName: paramName,
        isEditable: isEditable,
        availableData: AvailableData(day: 0, value: 0),
        actualValue: value,
        forAvailability: false);
  }

  @override
  State<RadioButtonWidget> createState() => _RadioButtonWidgetState();
}

///------------------------------------------------
class _RadioButtonWidgetState extends State<RadioButtonWidget> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return _radioButton();
  }

  Widget _radioButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: RadioGroup<int>(
        groupValue: widget.buttonValue,
        onChanged: (val) => widget.isEditable ? onChangeValue(val) : null,
        child: Column(children: <Widget>[
          Radio<int>(
              value: widget.actualValue,
              activeColor: _getColorForValue(buttonValue: widget.buttonValue)),
        ]),
      ),
    );
  }

  void onChangeValue(int? value) {
    setState(() {
      if (widget.forAvailability) {
        widget.availableData.value = widget.buttonValue;
        AppEvents.fireSchemaUpdated();
      } else {
        AppEvents.fireTrainerPrefUpdated(widget.paramName, widget.buttonValue);
      }
    });
  }
}

///------------------------------------------------

Color _getColorForValue({required int buttonValue}) {
  switch (buttonValue) {
    case 0:
      return Colors.red;
    case 1:
      return Colors.green;
    case 2:
      return Colors.brown;
    default:
      return Colors.grey;
  }
}

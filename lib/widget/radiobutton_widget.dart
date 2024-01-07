import 'package:flutter/material.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/model/app_models.dart';

class RadioButtonWidget extends StatefulWidget {
  final DaySchema? daySchema;
  final Trainer? trainer;
  final String paramName;
  final int rbValue;
  final Color color;

  const RadioButtonWidget({
    required Key key,
    required this.rbValue,
    required this.color,
    this.daySchema,
    this.trainer,
    this.paramName = '',
  }) : super(key: key);

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
    if (widget.daySchema != null) {
      value = widget.daySchema!.available;
    } else if (widget.paramName.isNotEmpty && widget.trainer != null) {
      value = _getValueFromParamName(widget.trainer!);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
        child: Radio<int>(
          activeColor: widget.color,
          value: value,
          groupValue: widget.rbValue,
          onChanged: (val) => onChangeValue(val),
        ),
      ),
    );
  }

  int _getValueFromParamName(Trainer trainer) {
    Map<String, dynamic> map = trainer.toMap();
    return map[widget.paramName];
  }

  void onChangeValue(int? value) {
    setState(() {
      if (widget.daySchema != null) {
        AppData.instance.updateAvailability(widget.daySchema!, widget.rbValue);
        AppEvents.fireTrainerUpdated(AppData.instance.getTrainer());
      } else {
        if (widget.paramName.isNotEmpty) {
          AppEvents.fireTrainerPrefUpdated(widget.paramName, widget.rbValue);
        }
      }
    });
  }
}

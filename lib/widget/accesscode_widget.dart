import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessCodeWidget extends StatefulWidget {
  const AccessCodeWidget({
    super.key,
    this.length = 4,
    this.onChanged,
    this.enabled = true,
    this.spacing = 12,
    this.boxSize = 80,
    this.fontSize = 28,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final double spacing;
  final double boxSize;
  final int fontSize;

  @override
  State<AccessCodeWidget> createState() => _AccessCodeWidgetState();
}

class _AccessCodeWidgetState extends State<AccessCodeWidget> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _codeValue =>
      _controllers.map((controller) => controller.text).join();

  void _moveToPreviousField(int index) {
    if (index == 0) {
      _controllers[index].clear();
      _focusNodes[index].requestFocus();
      return;
    }

    _focusNodes[index - 1].requestFocus();
    _controllers[index - 1].clear();
  }

  void _handleCodeInput(int index, String value) {
    final sanitized = value.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');

    if (sanitized != _controllers[index].text) {
      _controllers[index].value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }

    if (sanitized.isEmpty) {
      if (index > 0) {
        _moveToPreviousField(index);
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    widget.onChanged?.call(_codeValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
              right: index < widget.length - 1 ? widget.spacing : 0),
          child: SizedBox(
            width: widget.boxSize,
            height: widget.boxSize,
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is! KeyDownEvent) {
                  return KeyEventResult.ignored;
                }

                if (event.logicalKey != LogicalKeyboardKey.backspace) {
                  return KeyEventResult.ignored;
                }

                if (_controllers[index].text.isEmpty) {
                  if (index > 0) {
                    _moveToPreviousField(index);
                    widget.onChanged?.call(_codeValue);
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.handled;
                }

                _controllers[index].clear();
                widget.onChanged?.call(_codeValue);
                return KeyEventResult.handled;
              },
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final uppercaseText = newValue.text
                        .toUpperCase()
                        .replaceAll(RegExp(r'[^A-Z]'), '');
                    return newValue.copyWith(
                      text: uppercaseText,
                      selection: TextSelection.collapsed(
                        offset: uppercaseText.length,
                      ),
                    );
                  }),
                ],
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFF1F2937),
                ),
                cursorColor: const Color(0xFF1F2937),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                ),
                onChanged: (value) => _handleCodeInput(index, value),
                onTapOutside: (_) => _focusNodes[index].unfocus(),
                onSubmitted: (_) {
                  if (index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
                onEditingComplete: () {
                  if (index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

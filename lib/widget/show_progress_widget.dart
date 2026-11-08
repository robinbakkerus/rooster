import 'package:flutter/material.dart';

class ShowProgressWidget extends StatefulWidget {
  const ShowProgressWidget(
      {super.key, required this.title, required this.showSpinner});

  final bool showSpinner;
  final String title;
  final Color color = Colors.blue;
  final Color backgroundColor = Colors.grey;
  final double strokeWidth = 10.0;

  @override
  State<ShowProgressWidget> createState() => _ShowProgressWidgetState();
}

///--------------- A widget that shows a progress indicator with a title.
class _ShowProgressWidgetState extends State<ShowProgressWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // contentPadding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: 200.0,
        height: 200.0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildText(),
              const SizedBox(height: 20.0),
              _buildProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    if (widget.title.isNotEmpty) {
      return Center(
        child: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildProgress() {
    if (widget.showSpinner) {
      return Center(
        child: CircularProgressIndicator(
          // value: _progressValue,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          strokeWidth: widget.strokeWidth,
        ),
      );
    } else {
      return Container();
    }
  }
}

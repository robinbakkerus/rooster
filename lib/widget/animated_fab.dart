import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedFab extends StatefulWidget {
  const AnimatedFab({super.key});

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab> {
  late Timer timer;
  final List<Color> _colorList = [
    Colors.green,
    // Colors.lightBlue,
    Colors.orange,
    // Colors.yellow,
  ];
  int _colorIndex = 0;
  late Color _color;

  @override
  void initState() {
    _color = _colorList[0];
    timer = Timer.periodic(
        const Duration(milliseconds: 1000), (Timer t) => _animate());
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(child: const Icon(Icons.save));
    BorderRadiusGeometry borderRadius = BorderRadius.circular(8);

    return Container(
      // Use the properties stored in the State class.
      // width: _width,
      // height: _height,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: borderRadius,
      ),
      // duration: const Duration(milliseconds: 500),
      // Provide an optional curve to make the animation feel smoother.
      // curve: Curves.bounceIn,
      // Define how long the animation should take.
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.save),
      ),
    );
  }

  _animate() {
    setState(() {
      if (_colorIndex < _colorList.length - 1) {
        _colorIndex++;
      } else {
        _colorIndex = 0;
      }
      _color = _colorList[_colorIndex];
    });
  }
}

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class AnimatedFab extends StatefulWidget {
  const AnimatedFab({super.key});

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab> {
  // late Timer timer;
  // final List<Color> _colorList = [
  //   Colors.green,
  //   // Colors.lightBlue,
  //   Colors.orange,
  //   // Colors.yellow,
  // ];
  // int _colorIndex = 0;

  @override
  void initState() {
    // timer = Timer.periodic(
    //     const Duration(milliseconds: 1000), (Timer t) => _animate());
    super.initState();
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(),
      // duration: const Duration(milliseconds: 500),
      // Provide an optional curve to make the animation feel smoother.
      // curve: Curves.bounceIn,
      // Define how long the animation should take.

      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: _buildGlow(),
      ),
    );
  }

  // _animate() {
  //   setState(() {
  //     if (_colorIndex < _colorList.length - 1) {
  //       _colorIndex++;
  //     } else {
  //       _colorIndex = 0;
  //     }
  //   });
  // }

  Widget _buildGlow() {
    return AvatarGlow(
      startDelay: const Duration(milliseconds: 1000),
      glowColor: Colors.green,
      glowShape: BoxShape.circle,
      animate: true,
      curve: Curves.fastOutSlowIn,
      child: const Material(
        elevation: 10.0,
        shape: CircleBorder(),
        color: Colors.lightGreen,
        child: CircleAvatar(
          radius: 15.0,
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        color: Colors.lightGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent,
            spreadRadius: 4,
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.greenAccent,
            spreadRadius: -4,
            blurRadius: 5,
          ),
        ]);
  }
}

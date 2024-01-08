import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rooster/data/app_data.dart';
import 'package:rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  final String version = '1.1';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: AppData.instance.screenWidth,
      height: AppData.instance.screenHeight,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _animatedText(),
            wh.verSpace(20),
            Text('Trainingschema ${widget.version}'),
          ]),
    ));
  }

  Widget _animatedText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultTextStyle(
          style: const TextStyle(
              fontSize: 120.0,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.orange),
          child: AnimatedTextKit(
            animatedTexts: [
              ScaleAnimatedText('LO',
                  duration: const Duration(milliseconds: 3000)),
            ],
          ),
        ),
        DefaultTextStyle(
          style: const TextStyle(
              fontSize: 120.0,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue),
          child: AnimatedTextKit(
            animatedTexts: [
              ScaleAnimatedText('NU',
                  duration: const Duration(milliseconds: 3000)),
            ],
          ),
        ),
      ],
    );
  }
}

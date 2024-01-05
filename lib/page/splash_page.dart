import 'package:rooster/data/app_data.dart';
import 'package:rooster/util/page_mixin.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  final String version = '1.1';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with PageMixin {
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('LO',
                    style: TextStyle(
                        fontSize: 100,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange)),
                Text('NU',
                    style: TextStyle(
                        fontSize: 100,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue)),
              ],
            ),
            wh.verSpace(20),
            Text('Trainingschema ${widget.version}'),
          ]),
    ));
  }
}

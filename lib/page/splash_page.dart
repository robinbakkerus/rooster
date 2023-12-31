import 'package:firestore/data/app_data.dart';
import 'package:firestore/widget/widget_helper.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
            WidgetHelper().verSpace(20),
            const Text('Traininschema v1.0'),
          ]),
    ));
  }
}

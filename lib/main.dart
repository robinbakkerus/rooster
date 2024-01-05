import 'package:flutter/gestures.dart';
import 'package:rooster/controller/app_controler.dart';
import 'package:rooster/page/start_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rooster/util/app_helper.dart';
import 'package:rooster/widget/widget_helper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppController.instance.initializeAppData(context);
    TargetPlatform platform = AppHelper.instance.getPlatform();
    bool isWindows = platform == TargetPlatform.windows;

    return MaterialApp(
      scrollBehavior: isWindows
          ? const MaterialScrollBehavior()
              .copyWith(dragDevices: {PointerDeviceKind.mouse})
          : const MaterialScrollBehavior()
              .copyWith(dragDevices: {PointerDeviceKind.touch}),
      scaffoldMessengerKey: WidgetHelper.instance.scaffoldKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          tabBarTheme: const TabBarTheme(labelColor: Colors.black)),
      home: const StartPage(),
    );
  }
}

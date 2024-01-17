import 'package:flutter/material.dart';
import 'package:rooster/event/app_events.dart';
import 'package:rooster/util/app_mixin.dart';

class AppErrorPage extends StatefulWidget {
  const AppErrorPage({super.key});

  @override
  State<AppErrorPage> createState() => _AppErrorPageState();
}

class _AppErrorPageState extends State<AppErrorPage> with AppMixin {
  String _errorMessage = '';

  @override
  void initState() {
    AppEvents.onErrorEvent(_onErrorEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Er is een fout opgetreden!',
            style: TextStyle(color: Colors.red),
          ),
          wh.verSpace(10),
          const Text('error message = '),
          Text(_errorMessage),
          wh.verSpace(10),
          const Text('Er is al een email naar de beheerder verstuurd'),
        ],
      ),
    );
  }

  void _onErrorEvent(ErrorEvent event) {
    setState(() {
      _errorMessage = event.errMsg;
    });
  }
}

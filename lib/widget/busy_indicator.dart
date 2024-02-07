import 'package:flutter/material.dart';
import 'package:rooster/service/navigation_service.dart';

class LoadingIndicatorDialog {
  static final LoadingIndicatorDialog _singleton =
      LoadingIndicatorDialog._internal();
  bool isDisplayed = false;
  BuildContext? _context;

  factory LoadingIndicatorDialog() {
    return _singleton;
  }

  LoadingIndicatorDialog._internal();

  show({String text = 'Loading...'}) {
    if (isDisplayed) {
      return;
    }
    _context = NavigationService.navigatorKey.currentContext!;
    showDialog<void>(
        context: _context!,
        builder: (BuildContext context) {
          isDisplayed = true;
          return const Center(child: CircularProgressIndicator());
        });
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context!, rootNavigator: true).pop();
      isDisplayed = false;
    }
  }
}

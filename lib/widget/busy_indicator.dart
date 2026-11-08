import 'package:flutter/material.dart';
import 'package:rooster/service/navigation_service.dart';
import 'package:rooster/widget/show_progress_widget.dart';

class LoadingIndicatorDialog {
  static final LoadingIndicatorDialog _singleton =
      LoadingIndicatorDialog._internal();
  bool isDisplayed = false;
  BuildContext? _context;

  factory LoadingIndicatorDialog() {
    return _singleton;
  }

  LoadingIndicatorDialog._internal();

  void show({required String title, required bool showSpinner}) {
    if (isDisplayed) {
      return;
    }
    _context = NavigationService.navigatorKey.currentContext!;
    showDialog<void>(
        context: _context!,
        builder: (BuildContext context) {
          isDisplayed = true;
          return Center(
              child:
                  ShowProgressWidget(title: title, showSpinner: showSpinner));
        });
  }

  void dismiss() {
    if (isDisplayed) {
      Navigator.of(_context!, rootNavigator: true).pop();
      isDisplayed = false;
    }
  }
}

import 'dart:developer';

import 'package:rooster/util/app_constants.dart';
import 'package:rooster/widget/widget_helper.dart';

mixin AppMixin {
  final WidgetHelper wh = WidgetHelper.instance;

  final AppConstants c = AppConstants();

  lp(String message) {
    log(message);
  }
}

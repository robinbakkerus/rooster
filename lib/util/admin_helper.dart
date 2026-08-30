import 'package:rooster/util/app_mixin.dart';

class AdminHelper with AppMixin {
  AdminHelper._();
  static final AdminHelper instance = AdminHelper._();

  List<int> getTueThuDays(int year, int month) {
    final days = <int>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (var day = 1; day <= daysInMonth; day++) {
      final weekday = DateTime(year, month, day).weekday;
      if (weekday == DateTime.tuesday || weekday == DateTime.thursday) {
        days.add(day);
      }
    }

    return days;
  }

  List<int> getTueThuSatDays(int year, int month) {
    final days = <int>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (var day = 1; day <= daysInMonth; day++) {
      final weekday = DateTime(year, month, day).weekday;
      if (weekday == DateTime.tuesday ||
          weekday == DateTime.thursday ||
          weekday == DateTime.saturday) {
        days.add(day);
      }
    }

    return days;
  }

  // void updateAvailabeList(TrainerSchema schema, List<int> daysList) {
  //   for (int i = 0; i < daysList.length; i++) {
  //     int value = schema.availableList[i];
  //     AvailableData availableData =
  //         AvailableData(day: daysList[i], value: value);
  //     schema.availableDataList.add(availableData);
  //   }
  // }
}

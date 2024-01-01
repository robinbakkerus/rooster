import 'package:rooster/data/populate_data.dart' as populate;
import 'package:rooster/model/app_models.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class Simulator {
  Simulator._();
  static final Simulator instance = Simulator._();

  TrainerSchema getTrainerSchema(String trainerSchemaId) {
    TrainerSchema? trainerSchema =
        populate.allSchemas.firstWhereOrNull((e) => e.id == trainerSchemaId);
    if (trainerSchema != null) {
      return trainerSchema;
    } else {
      return TrainerSchema.empty();
    }
  }

  List<Trainer> getAllTrainers() {
    List<Trainer> list = [];

    list.add(populate.trainerRobin);
    list.add(populate.trainerPaula);
    list.add(populate.trainerOlav);
    list.add(populate.trainerFried);
    list.add(populate.trainerRonald);
    list.add(populate.trainerMaria);
    list.add(populate.trainerHuib);
    list.add(populate.trainerPauline);
    list.add(populate.trainerJanneke);

    return list;
  }
}

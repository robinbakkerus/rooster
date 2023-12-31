// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:event_bus/event_bus.dart';

import 'package:firestore/model/app_models.dart';

enum ShowPage { editSchema, createSchema, admin }

/*
 * All Events are maintainded here.
 */
class ShowPageEvent {
  ShowPage page;
  ShowPageEvent(this.page);
}

class TrainerDataReadyEvent {}

class SchemaUpdatedEvent {}

// event that is send from widget with radiobuttons, to tell parent page that some value is changed
class TrainerUdatedEvent {
  Trainer trainer;
  TrainerUdatedEvent({
    required this.trainer,
  });
}

class AllTrainersDataReadyEvent {}

class DatesReadyEvent {}

class TrainingUpdatedEvent {
  final int rowIndex;
  final String training;

  TrainingUpdatedEvent(this.rowIndex, this.training);
}

/*
	Static class that contains all onXxx and fireXxx methods.
*/
class AppEvents {
  static final EventBus _sEventBus = EventBus();

  // Only needed if clients want all EventBus functionality.
  static EventBus ebus() => _sEventBus;

  /*
  * The methods below are just convenience shortcuts to make it easier for the client to use.
  */
  static void fireShowPage(ShowPage page) =>
      _sEventBus.fire(ShowPageEvent(page));

  static void fireTrainerDataReady() =>
      _sEventBus.fire(TrainerDataReadyEvent());

  static void fireSchemaUpdated() => _sEventBus.fire(SchemaUpdatedEvent());
  static void fireTrainerUpdated(Trainer trainer) =>
      _sEventBus.fire(TrainerUdatedEvent(trainer: trainer));

  static void fireAllTrainerDataReady() =>
      _sEventBus.fire(AllTrainersDataReadyEvent());

  static void fireDatesReady() => _sEventBus.fire(DatesReadyEvent());

  static void fireTrainingUpdatedEvent(int rowIndex, String training) =>
      _sEventBus.fire(TrainingUpdatedEvent(rowIndex, training));

  ///----- static onXxx methods --------
  static void onShowPage(OnShowPageFunc func) =>
      _sEventBus.on<ShowPageEvent>().listen((event) => func(event));

  static void onTrainerDataReadyEvent(OnTrainerDataReadyEventFunc func) =>
      _sEventBus.on<TrainerDataReadyEvent>().listen((event) => func(event));

  static void onSchemaUpdatedEvent(OnSchemaUpdateEventFunc func) =>
      _sEventBus.on<SchemaUpdatedEvent>().listen((event) => func(event));

  static void onTrainerUpdatedEvent(OnTrainerUpdatedEventFunc func) =>
      _sEventBus.on<TrainerUdatedEvent>().listen((event) => func(event));

  static void onAllTrainersAndSchemasReadyEvent(
          OnAllTrainerDataReadyEventFunc func) =>
      _sEventBus.on<AllTrainersDataReadyEvent>().listen((event) => func(event));

  static void onDatesReadyEvent(OnDatesReadyEventFunc func) =>
      _sEventBus.on<DatesReadyEvent>().listen((event) => func(event));

  static void onTrainingUpdatedEvent(OnTrainingUpdatedEventFunc func) =>
      _sEventBus.on<TrainingUpdatedEvent>().listen((event) => func(event));
}

/// ----- typedef's -----------
typedef OnShowPageFunc = void Function(ShowPageEvent event);

typedef OnTrainerDataReadyEventFunc = void Function(
    TrainerDataReadyEvent event);

typedef OnSchemaUpdateEventFunc = void Function(SchemaUpdatedEvent event);

typedef OnTrainerUpdatedEventFunc = void Function(TrainerUdatedEvent event);

typedef OnAllTrainerDataReadyEventFunc = void Function(
    AllTrainersDataReadyEvent event);

typedef OnDatesReadyEventFunc = void Function(DatesReadyEvent event);

typedef OnTrainingUpdatedEventFunc = void Function(TrainingUpdatedEvent event);

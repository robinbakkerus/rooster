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

class TrainerDataReceivedEvent {
  final Trainer trainer;
  final List<DaySchema> schemas;

  TrainerDataReceivedEvent({
    required this.trainer,
    required this.schemas,
  });
}

class TrainerDataReadyEvent {}

class SchemaUpdatedEvent {}

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

  static void fireTrainerDataReceived(
          Trainer trainer, List<DaySchema> schemas) =>
      _sEventBus
          .fire(TrainerDataReceivedEvent(trainer: trainer, schemas: schemas));

  static void fireTrainerDataReady() =>
      _sEventBus.fire(TrainerDataReadyEvent());

  static void fireSchemaUpdated() => _sEventBus.fire(SchemaUpdatedEvent());

  ///----- static onXxx methods --------
  static void onShowPage(OnShowPageFunc func) =>
      _sEventBus.on<ShowPageEvent>().listen((event) => func(event));

  static void onTrainerDataReceivedEvent(OnTrainerDataReceivedEventFunc func) =>
      _sEventBus.on<TrainerDataReceivedEvent>().listen((event) => func(event));

  static void onTrainerDataReadyEvent(OnTrainerDataReadyEventFunc func) =>
      _sEventBus.on<TrainerDataReadyEvent>().listen((event) => func(event));

  static void onSchemaUpdatedEvent(OnSchemaUpdateEventFunc func) =>
      _sEventBus.on<SchemaUpdatedEvent>().listen((event) => func(event));
}

/// ----- typedef's -----------
typedef OnShowPageFunc = void Function(ShowPageEvent event);
typedef OnTrainerDataReceivedEventFunc = void Function(
    TrainerDataReceivedEvent event);
typedef OnTrainerDataReadyEventFunc = void Function(
    TrainerDataReadyEvent event);
typedef OnSchemaUpdateEventFunc = void Function(SchemaUpdatedEvent event);

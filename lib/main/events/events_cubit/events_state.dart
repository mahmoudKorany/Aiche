abstract class EventsState {}

final class EventsInitial extends EventsState {}

final class EventsLoading extends EventsState {}
final class EventsLoaded extends EventsState {}
final class EventsError extends EventsState {
  final String error;
  EventsError(this.error);
}

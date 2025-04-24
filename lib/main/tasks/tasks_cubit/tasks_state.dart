import 'package:aiche/main/tasks/models/task.dart';

abstract class TasksState {}

class TaskInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> tasks;
  TasksLoaded(this.tasks);
}

class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
}

class TaskAdded extends TasksState {
  final Task task;
  TaskAdded(this.task);
}

class TaskUpdated extends TasksState {
  final Task task;
  TaskUpdated(this.task);
}

class TaskDeleted extends TasksState {
  final String id;
  TaskDeleted(this.id);
}

class NotificationScheduled extends TasksState {
  final int notificationId;
  NotificationScheduled(this.notificationId);
}

class NotificationCancelled extends TasksState {
  final int notificationId;
  NotificationCancelled(this.notificationId);
}

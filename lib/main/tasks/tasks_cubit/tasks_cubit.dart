import 'package:aiche/core/services/dio/dio.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/main/tasks/models/committee_task_model.dart';
import 'package:aiche/main/tasks/models/task.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_state.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TaskInitial()) {
    initializeDatabase();
  }

  static TasksCubit get(context) => BlocProvider.of(context);

  // Database properties
  late Database _database;
  final String _tableName = 'tasks';
  List<Task> _tasks = [];

  // Initialize database
  Future<void> initializeDatabase() async {
    try {
      // Get path for database
      String databasePath = await getDatabasesPath();
      String path = join(databasePath, 'tasks.db');

      // Open/create the database
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          // Create tasks table
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              title TEXT,
              description TEXT,
              dueDate TEXT,
              progress REAL,
              isCompleted INTEGER,
              notificationId INTEGER
            )
          ''');
        },
      );

      // Load tasks after initializing database
      await getTasks();
    } catch (e) {
      emit(TasksError('Failed to initialize database: $e'));
    }
  }

  // Get all tasks
  Future<void> getTasks() async {
    try {
      emit(TasksLoading());

      // Query the database
      List<Map<String, dynamic>> tasksMap = await _database.query(_tableName);

      // Convert maps to Task objects
      _tasks = tasksMap.map((map) => Task.fromJson(map)).toList();

      // Sort tasks by due date (closest first)
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TasksError('Failed to load tasks: $e'));
    }
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required bool shouldNotify,
  }) async {
    try {
      // Generate unique ID
      final String id = const Uuid().v4();
      int? notificationId;

      // Schedule notification if required
      if (shouldNotify) {
        notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await _scheduleNotification(
          notificationId,
          title,
          description,
          dueDate,
        );
      }

      // Create new task
      final Task newTask = Task(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        progress: 0.0,
        isCompleted: false,
        notificationId: notificationId,
      );

      // Insert into database
      await _database.insert(
        _tableName,
        newTask.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Add to list and emit state
      _tasks.add(newTask);

      // Sort tasks by due date
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      emit(TaskAdded(newTask));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TasksError('Failed to add task: $e'));
    }
  }

  // Update an existing task
  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    double? progress,
    bool? isCompleted,
    bool? shouldNotify,
    int?
        notificationId, // Add this parameter to allow direct setting of notification ID
  }) async {
    try {
      // Find the task in the list
      final int index = _tasks.indexWhere((task) => task.id == id);
      if (index == -1) {
        emit(TasksError('Task not found'));
        return;
      }

      // Get existing task
      Task existingTask = _tasks[index];

      // Handle notification if needed
      int? finalNotificationId = notificationId ?? existingTask.notificationId;

      // Cancel existing notification if there is one (unless we're setting a new one directly)
      if (existingTask.notificationId != null && notificationId == null) {
        await _cancelNotification(existingTask.notificationId!);
      }

      // Schedule new notification if requested
      if (shouldNotify == true && notificationId == null) {
        finalNotificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await _scheduleNotification(
          finalNotificationId,
          title ?? existingTask.title,
          description ?? existingTask.description,
          dueDate ?? existingTask.dueDate,
        );
        emit(NotificationScheduled(finalNotificationId));
      } else if (shouldNotify == false) {
        // If explicitly set to false, set to null
        finalNotificationId = null;
      }

      // Create updated task
      final Task updatedTask = existingTask.copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
        progress: progress,
        isCompleted: isCompleted,
        notificationId: finalNotificationId,
      );

      // Update in database
      await _database.update(
        _tableName,
        updatedTask.toJson(),
        where: 'id = ?',
        whereArgs: [id],
      );

      // Update in memory list
      _tasks[index] = updatedTask;

      // Sort tasks by due date
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      emit(TaskUpdated(updatedTask));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TasksError('Failed to update task: $e'));
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      // Find the task in the list
      final int index = _tasks.indexWhere((task) => task.id == id);
      if (index == -1) {
        emit(TasksError('Task not found'));
        return;
      }

      // Get the task
      final Task task = _tasks[index];

      // Cancel notification if exists
      if (task.notificationId != null) {
        await _cancelNotification(task.notificationId!);
        emit(NotificationCancelled(task.notificationId!));
      }

      // Delete from database
      await _database.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      // Remove from memory list
      _tasks.removeAt(index);

      emit(TaskDeleted(id));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TasksError('Failed to delete task: $e'));
    }
  }

  // Mark task as complete/incomplete
  Future<void> toggleTaskCompletion(String id) async {
    try {
      // Find the task
      final int index = _tasks.indexWhere((task) => task.id == id);
      if (index == -1) {
        emit(TasksError('Task not found'));
        return;
      }

      // Get the task and toggle completion
      final Task task = _tasks[index];
      final bool newCompletionStatus = !task.isCompleted;

      // Update the task
      await updateTask(
        id: id,
        isCompleted: newCompletionStatus,
        progress: newCompletionStatus ? 1.0 : task.progress,
      );
    } catch (e) {
      emit(TasksError('Failed to toggle task completion: $e'));
    }
  }

  // Update task progress
  Future<void> updateTaskProgress(String id, double progress) async {
    try {
      // Ensure progress is between 0 and 1
      final double validProgress = progress.clamp(0.0, 1.0);

      // Update the task
      await updateTask(
        id: id,
        progress: validProgress,
        isCompleted: validProgress >= 1.0,
      );
    } catch (e) {
      emit(TasksError('Failed to update task progress: $e'));
    }
  }

  // Schedule a notification for the task
  Future<void> _scheduleNotification(
    int notificationId,
    String title,
    String description,
    DateTime dueDate,
  ) async {
    try {
      // Check if the scheduled time is in the future
      if (dueDate.isBefore(DateTime.now()) && kDebugMode) {
        print('Cannot schedule notification for past date: $dueDate');
        return;
      }

      // Use a microtask to help ensure we're not blocking the main thread
      await Future.microtask(() async {
        return await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'task_channel',
            title: '⏰ Task Reminder: $title',
            body: '📅 Due now: $description',
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Alarm,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            autoDismissible: false,
            actionType: ActionType.Default,
            customSound: null, // Use default alarm sound
            backgroundColor: const Color(0xFF111347),
            largeIcon: 'resource://drawable/app_icon',
            locked: false,
            hideLargeIconOnExpand: false,
            displayOnForeground: true,
            displayOnBackground: true,
            ticker: 'Task due: $title',
            showWhen: true,
            payload: {
              'taskId': notificationId.toString(),
              'taskTitle': title,
              'taskDescription': description,
            },
          ),
          actionButtons: [
            NotificationActionButton(
              key: 'MARK_DONE',
              label: 'Mark Complete',
              actionType: ActionType.SilentAction,
              autoDismissible: true,
              color: Colors.green,
            ),
            NotificationActionButton(
              key: 'SNOOZE',
              label: 'Snooze 5min',
              actionType: ActionType.SilentAction,
              autoDismissible: true,
              color: Colors.orange,
            ),
          ],
          schedule: NotificationCalendar.fromDate(
            date: dueDate,
            preciseAlarm: true, // Enable precise alarm for exact timing
            allowWhileIdle:
                true, // Allow notification while device is idle/dozing
          ),
        );
      });

      if (kDebugMode) {
        print('Scheduled task alarm for: $dueDate');
        print('Notification ID: $notificationId');
        print('Task: $title');
        print('Current time: ${DateTime.now()}');
        print('Time until alarm: ${dueDate.difference(DateTime.now())}');
      }
    } catch (e) {
      print('Failed to schedule notification: $e');
      // We don't emit error here as task creation should continue
    }
  }

  // Cancel a notification
  Future<void> _cancelNotification(int notificationId) async {
    try {
      // Use a microtask to help ensure proper thread handling
      await Future.microtask(() async {
        return await AwesomeNotifications().cancel(notificationId);
      });
    } catch (e) {
      print('Failed to cancel notification: $e');
      // We don't emit error here as task operations should continue
    }
  }

  // Handle notification actions (Mark Complete, Snooze)
  Future<void> handleNotificationAction(
      String actionKey, int notificationId) async {
    try {
      // Find the task with this notification ID
      final Task? task = _tasks.cast<Task?>().firstWhere(
            (task) => task?.notificationId == notificationId,
            orElse: () => null,
          );

      if (task == null) {
        // If task not found in memory, reload from database to ensure we have latest data
        await getTasks();
        // Try to find the task again after reloading
        final Task? reloadedTask = _tasks.cast<Task?>().firstWhere(
              (task) => task?.notificationId == notificationId,
              orElse: () => null,
            );
        if (reloadedTask == null) return;

        // Use the reloaded task for further processing
        switch (actionKey) {
          case 'MARK_DONE':
            // Mark task as complete
            await updateTask(
              id: reloadedTask.id,
              isCompleted: true,
              progress: 1.0,
            );
            // Cancel the notification since task is completed
            await _cancelNotification(notificationId);
            // Force a UI update by emitting a fresh state
            await getTasks();
            break;
          case 'SNOOZE':
            // Snooze for 5 minutes
            await _snoozeTask(reloadedTask, const Duration(minutes: 5));
            break;
        }
        return;
      }

      switch (actionKey) {
        case 'MARK_DONE':
          // Mark task as complete
          await updateTask(
            id: task.id,
            isCompleted: true,
            progress: 1.0,
          );
          // Cancel the notification since task is completed
          await _cancelNotification(notificationId);
          // Force a UI update by emitting a fresh state
          await getTasks();
          break;
        case 'SNOOZE':
          // Snooze for 5 minutes
          await _snoozeTask(task, const Duration(minutes: 5));
          break;
      }
    } catch (e) {
      print('Failed to handle notification action: $e');
      // In case of error, reload tasks to ensure UI is in sync
      await getTasks();
    }
  }

  // Snooze a task by rescheduling its notification
  Future<void> _snoozeTask(Task task, Duration snoozeDuration) async {
    try {
      // Cancel current notification
      if (task.notificationId != null) {
        await _cancelNotification(task.notificationId!);
      }

      // Schedule new notification for snooze time
      final DateTime snoozeTime = DateTime.now().add(snoozeDuration);
      final int newNotificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Create the snooze notification with enhanced alarm properties
      await _scheduleNotification(
        newNotificationId,
        '⏰ Snoozed: ${task.title}',
        task.description.isEmpty
            ? 'Snoozed reminder - task is due!'
            : task.description,
        snoozeTime,
      );

      // Update task with new notification ID in database
      await updateTask(
        id: task.id,
        notificationId: newNotificationId,
        shouldNotify: true,
      );

      print(
          'Task "${task.title}" snoozed for ${snoozeDuration.inMinutes} minutes. New alarm at: $snoozeTime');
    } catch (e) {
      print('Failed to snooze task: $e');
    }
  }

  // Get filtered tasks (completed, upcoming, or all)
  List<Task> getFilteredTasks({bool? isCompleted}) {
    if (isCompleted == null) {
      return _tasks;
    }
    return _tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // Get tasks due today
  List<Task> getTasksDueToday() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      final DateTime taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
    }).toList();
  }

  // Get tasks for a specific date
  List<Task> getTasksForDate(DateTime date) {
    final DateTime targetDate = DateTime(date.year, date.month, date.day);

    return _tasks.where((task) {
      final DateTime taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Close the database when the cubit is closed
  @override
  Future<void> close() async {
    await _database.close();
    super.close();
  }

  // get All tasks From API
  List<TasksModel> tasks = [];

  Future<void> getTasksFromApi() async {
    tasks = [];
    emit(GetAllTasksFromApiLoading());
    try {
      DioHelper.getData(url: UrlConstants.getTasks, query: {}, token: token)
          .then((value) {
        if (value.statusCode == 200) {
          for (var element in value.data['data']) {
            tasks.add(TasksModel.fromJson(element));
          }
          emit(GetAllTasksFromApiLoaded());
        } else {
          emit(GetAllTasksFromApiError('Failed to load tasks from API'));
        }
      }).catchError((error) {
        emit(GetAllTasksFromApiError('Failed to load tasks from API: $error'));
      });
    } catch (e) {
      emit(GetAllTasksFromApiError('Failed to load tasks from API: $e'));
    }
  }
}

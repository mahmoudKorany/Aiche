import 'package:aiche/core/services/dio/dio.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/main/tasks/models/committee_task_model.dart';
import 'package:aiche/main/tasks/models/task.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_state.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
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
      await getTasksFromApi();

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
      int? notificationId = existingTask.notificationId;

      // Cancel existing notification if there is one
      if (notificationId != null) {
        await _cancelNotification(notificationId);
      }

      // Schedule new notification if requested
      if (shouldNotify == true) {
        notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await _scheduleNotification(
          notificationId,
          title ?? existingTask.title,
          description ?? existingTask.description,
          dueDate ?? existingTask.dueDate,
        );
        emit(NotificationScheduled(notificationId));
      } else if (shouldNotify == false) {
        // If explicitly set to false, set to null
        notificationId = null;
      }

      // Create updated task
      final Task updatedTask = existingTask.copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
        progress: progress,
        isCompleted: isCompleted,
        notificationId: notificationId,
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
      // Use a microtask to help ensure we're not blocking the main thread
      // while still handling the notification operation properly
      await Future.microtask(() async {
        return await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'task_channel',
            title: 'Task Reminder: $title',
            body: description,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar.fromDate(date: dueDate),
        );
      });
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

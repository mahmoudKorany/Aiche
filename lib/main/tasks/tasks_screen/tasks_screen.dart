import 'dart:io';

import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/tasks/models/task.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_cubit.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/shared/components/components.dart';
import '../../../core/shared/components/gaps.dart';
import '../../home/home_component/drawer_icon.dart';
import '../models/committee_task_model.dart';
import 'add_task_dialog.dart';
import 'edit_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0;
  final List<String> _filterLabels = [
    'Committee',
    'All',
    'Active',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterLabels.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedFilterIndex = _tabController.index;
      });
    });

    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksCubit>().getTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state is TaskAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${state.task.title}" added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is TaskUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${state.task.title}" updated'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is TaskDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      builder: (context, state) {
        // Get tasks based on selected filter
        List<Task> tasks = [];
        if (state is TasksLoaded) {
          if (_selectedFilterIndex == 1) {
            // All tasks
            tasks = state.tasks;
          } else if (_selectedFilterIndex == 2) {
            // Active tasks
            tasks = state.tasks.where((task) => !task.isCompleted).toList();
          } else if (_selectedFilterIndex == 3) {
            // Completed tasks
            tasks = state.tasks.where((task) => task.isCompleted).toList();
          }
          // Committee tab (index 0) uses a different data source and view
        }

        // Get task counts
        int activeTasks = 0;
        int completedTasks = 0;

        if (state is TasksLoaded) {
          activeTasks = state.tasks.where((task) => !task.isCompleted).length;
          completedTasks = state.tasks.where((task) => task.isCompleted).length;
        }

        return Stack(
          children: [
            const BackGround(),
            Scaffold(
              floatingActionButton: _buildAddTaskButton(context),
              backgroundColor: Colors.black.withOpacity(0.0),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),

                  // Filters
                  _buildFilters(context, activeTasks, completedTasks),

                  // Tasks List
                  Expanded(
                    child: state is TasksLoading
                        ? _buildLoadingIndicator()
                        : TasksCubit.get(context).tasks.isEmpty
                            ? _buildEmptyState()
                            : _selectedFilterIndex == 0
                                ? _buildCommitteeTabContent(context)
                                : _buildTasksList(context, tasks),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 60.h, left: 16.w, right: 16.w, bottom: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DrawerIcon(),
          const Gap10(isHorizontal: true,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 20.0.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 12.0.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.all(8.r),
            child: BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                int todayTasksCount = 0;
                if (state is TasksLoaded) {
                  todayTasksCount =
                      context.read<TasksCubit>().getTasksDueToday().length;
                }

                return Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$todayTasksCount today',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
      BuildContext context, int activeTasks, int completedTasks) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.w),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.zero,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.r),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
              splashFactory: NoSplash.splashFactory,
              padding: EdgeInsets.zero,
              splashBorderRadius: BorderRadius.circular(10.r),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
              ),
              tabs: [
                Tab(text: 'Committee'),
                Tab(text: 'All (${activeTasks + completedTasks})'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading tasks...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = '';
    String subMessage = '';
    IconData icon;
    bool showAddButton = false;

    // Select appropriate messages based on the current tab
    if (_selectedFilterIndex == 0) {
      // Committee tab
      message = 'No committee tasks available';
      subMessage = 'Committee tasks will appear here';
      icon = Icons.group_work_outlined;
      showAddButton = false;
    } else if (_selectedFilterIndex == 1) {
      // All tasks
      message = 'No tasks yet';
      subMessage = 'Add a new task to get started';
      icon = Icons.assignment_outlined;
      showAddButton = false;
    } else if (_selectedFilterIndex == 2) {
      // Active tasks
      message = 'No active tasks';
      subMessage = 'Add a task or complete one';
      icon = Icons.assignment_late_outlined;
      showAddButton = false;
    } else {
      // Completed tasks
      message = 'No completed tasks';
      subMessage = 'Complete a task to see it here';
      icon = Icons.assignment_turned_in_outlined;
      showAddButton = false;
    }

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 80.sp,
                  color: Colors.white.withOpacity(0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subMessage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                if (showAddButton)
                  ElevatedButton.icon(
                    onPressed: () {
                      navigateTo(
                        context: context,
                        widget: AddTaskScreen(),
                      );
                    },
                    icon: Icon(Icons.add, size: 18.sp),
                    label: Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<Task> tasks) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildTaskItem(context, task),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    final bool isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final bool isDueToday = _isToday(task.dueDate);

    Color statusColor = Colors.blue;
    if (task.isCompleted) {
      statusColor = Colors.green;
    } else if (isOverdue) {
      statusColor = Colors.red;
    } else if (isDueToday) {
      statusColor = Colors.orange;
    }

    return Dismissible(
      key: Key(task.id),
      background: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          Icons.delete_forever,
          color: Colors.red[300],
          size: 28.sp,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Delete Task',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "${task.title}"?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<TasksCubit>().deleteTask(task.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.2),
              Colors.white.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: statusColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header
            ListTile(
              contentPadding: EdgeInsets.all(16.r),
              leading: InkWell(
                onTap: () {
                  context.read<TasksCubit>().toggleTaskCompletion(task.id);
                },
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : isOverdue
                            ? Icons.error_outline
                            : Icons.circle_outlined,
                    color: statusColor,
                    size: 24.sp,
                  ),
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        isDueToday
                            ? Icons.today
                            : task.dueDate.isAfter(DateTime.now())
                                ? Icons.date_range
                                : Icons.event_busy,
                        size: 14.sp,
                        color: statusColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDueDate(task.dueDate),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isOverdue ? Colors.red[300] : Colors.white70,
                          fontWeight: isDueToday || isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (task.notificationId != null) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.notifications_active,
                          size: 14.sp,
                          color: Colors.amber,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                  size: 20.sp,
                ),
                color: Colors.grey[850],
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Edit task logic
                      Future.delayed(
                        const Duration(milliseconds: 10),
                        () {
                          // Navigate to edit task screen
                          navigateTo(
                            context: context,
                            widget: EditTaskScreen(task: task),
                          );
                        },
                      );
                    },
                  ),
                  if (!task.isCompleted)
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Mark as completed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onTap: () {
                        context
                            .read<TasksCubit>()
                            .toggleTaskCompletion(task.id);
                      },
                    ),
                  if (task.isCompleted)
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.refresh,
                              color: Colors.orange, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Mark as active',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onTap: () {
                        context
                            .read<TasksCubit>()
                            .toggleTaskCompletion(task.id);
                      },
                    ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.red[300], size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(
                        const Duration(milliseconds: 10),
                        () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: Text(
                                'Delete Task',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                'Are you sure you want to delete "${task.title}"?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel',
                                      style: TextStyle(color: Colors.blue)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context
                                        .read<TasksCubit>()
                                        .deleteTask(task.id);
                                  },
                                  child: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Task Progress
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${(task.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: task.progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        task.isCompleted ? Colors.green : Colors.blue),
                    borderRadius: BorderRadius.circular(4.r),
                    minHeight: 5.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 60.h : 90.h),
      child: FloatingActionButton.extended(
        tooltip: 'Add New Task',
        onPressed: () {
          navigateTo(
            context: context,
            widget: AddTaskScreen(),
          );
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        elevation: 5,
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today at ${_formatTime(dueDate)}';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow at ${_formatTime(dueDate)}';
    } else if (dueDate.isBefore(now) && !_isToday(dueDate)) {
      return 'Overdue (${DateFormat('MMM d').format(dueDate)}) at ${_formatTime(dueDate)}';
    } else if (dueDate.difference(now).inDays < 7) {
      return '${DateFormat('EEEE').format(dueDate)} at ${_formatTime(dueDate)}';
    } else {
      return '${DateFormat('MMM d').format(dueDate)} at ${_formatTime(dueDate)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime).toLowerCase();
  }

  Widget _buildCommitteeTabContent(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final tasksCubit = context.read<TasksCubit>();
        
        if (state is GetAllTasksFromApiLoading) {
          return _buildLoadingIndicator();
        }
        
        if (tasksCubit.tasks.isEmpty) {
          return _buildEmptyState();
        }
        
        return AnimationLimiter(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemCount: tasksCubit.tasks.length,
            itemBuilder: (context, index) {
              final task = tasksCubit.tasks[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildCommitteeTaskItem(context, task),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildCommitteeTaskItem(BuildContext context, TasksModel task) {
    // Format date if available
    String formattedDate = '';
    if (task.date != null && task.date!.isNotEmpty) {
      try {
        final DateTime taskDate = DateTime.parse(task.date!);
        formattedDate = _formatCommitteeTaskDate(taskDate);
      } catch (e) {
        formattedDate = task.date ?? 'No date';
      }
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Header
          ListTile(
            contentPadding: EdgeInsets.all(16.r),
            leading: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.group_work,
                color: Colors.blue,
                size: 24.sp,
              ),
            ),
            title: Text(
              task.title ?? 'No Title',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      formattedDate.isNotEmpty ? formattedDate : 'No date specified',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    if (task.user != null && task.user!.name != null) ...[
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.person,
                        size: 14.sp,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        task.user!.name!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Resource link if available
          if (task.link != null && task.link!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open the resource link
                  // You can use url_launcher or any other method to open the link
                  launchUrl(
                    Uri.parse(task.link!),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: Icon(
                  Icons.link,
                  size: 18.sp,
                ),
                label: Text(
                  'Open Resource',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatCommitteeTaskDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (date.isBefore(now) && !_isToday(date)) {
      return 'Past (${DateFormat('MMM d').format(date)})';
    } else if (date.difference(now).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

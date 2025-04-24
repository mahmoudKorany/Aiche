import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/tasks/models/task.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_cubit.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _notifyMe;
  late String _selectedDay;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late double _progress;
  late bool _isCompleted;
  final _formKey = GlobalKey<FormState>();

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Priority levels with colors
  final List<Map<String, dynamic>> _priorities = [
    {'label': 'Low', 'color': Colors.green},
    {'label': 'Medium', 'color': Colors.orange},
    {'label': 'High', 'color': Colors.red},
  ];

  int _selectedPriorityIndex = 1; // Default to Medium

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing task data
    _nameController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.dueDate;
    _selectedTime = TimeOfDay(
      hour: widget.task.dueDate.hour,
      minute: widget.task.dueDate.minute,
    );
    _notifyMe = widget.task.notificationId != null;
    _selectedDay = DateFormat('EEEE').format(widget.task.dueDate);
    _progress = widget.task.progress;
    _isCompleted = widget.task.isCompleted;

    // Determine priority based on due date proximity or task attributes
    // This is a simple example - you might want to adjust the logic based on your needs
    if (_isCompleted) {
      _selectedPriorityIndex = 0; // Low priority for completed tasks
    } else {
      final now = DateTime.now();
      final difference = _selectedDate.difference(now).inDays;

      if (difference < 1) {
        _selectedPriorityIndex =
            2; // High priority for tasks due today or overdue
      } else if (difference < 3) {
        _selectedPriorityIndex =
            1; // Medium priority for tasks due in next 3 days
      } else {
        _selectedPriorityIndex = 0; // Low priority for tasks due later
      }
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111347),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF111347),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedDay = DateFormat('EEEE').format(pickedDate);
      });

      // After selecting date, ask for time
      _selectTime(context);
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111347),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF111347),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  String _getFormattedDateTime() {
    String formattedDate = DateFormat('MMM dd, yyyy').format(_selectedDate);
    String formattedTime = _selectedTime.format(context);
    return '$formattedDate at $formattedTime';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a DateTime with both date and time components
      final DateTime deadline = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Use TasksCubit to update the task
      TasksCubit.get(context).updateTask(
        id: widget.task.id,
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: deadline,
        shouldNotify: _notifyMe,
        progress: _progress,
        isCompleted: _isCompleted,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TasksState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            const BackGround(),
            Scaffold(
              backgroundColor: Colors.grey.withOpacity(0.0),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Edit Task',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                leadingWidth: 60.w,
                centerTitle: false,
                leading: Padding(
                  padding: EdgeInsets.only(left: 20.0.w),
                  child: const Pop(),
                ),
              ),
              body: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: AnimationLimiter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                9,
                                // Number of form sections (one more for task completion status)
                                (index) => AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildFormSection(index),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap25(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormSection(int index) {
    switch (index) {
      case 0:
        // Task Name Field
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Task Name', Icons.title),
            const Gap10(),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Enter task name'),
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.grey[800],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Task name is required';
                }
                return null;
              },
            ),
            const Gap25(),
          ],
        );

      case 1:
        // Task Description Field
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Description', Icons.description),
            const Gap10(),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration:
                  _buildInputDecoration('Enter task description (optional)'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const Gap25(),
          ],
        );

      case 2:
        // Priority Selection
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Priority', Icons.flag),
            const SizedBox(height: 10),
            Container(
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(
                  _priorities.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPriorityIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _selectedPriorityIndex == index
                              ? _priorities[index]['color'].withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedPriorityIndex == index
                              ? Border.all(color: _priorities[index]['color'])
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16.w,
                                height: 16.h,
                                decoration: BoxDecoration(
                                  color: _priorities[index]['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap10(
                                isHorizontal: true,
                              ),
                              Text(
                                _priorities[index]['label'],
                                style: GoogleFonts.poppins(
                                  color: _selectedPriorityIndex == index
                                      ? _priorities[index]['color']
                                      : Colors.grey[700],
                                  fontWeight: _selectedPriorityIndex == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap25(),
          ],
        );

      case 3:
        // Deadline Selector
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Deadline', Icons.event),
            const Gap10(),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111347).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: const Color(0xFF111347),
                        size: 20.sp,
                      ),
                    ),
                    const Gap15(
                      isHorizontal: true,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Gap5(),
                          Text(
                            _getFormattedDateTime(),
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
            const Gap25(),
          ],
        );

      case 4:
        // Day Selector
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Day', Icons.view_week),
            const Gap10(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: InputDecoration(
                  prefixIcon: Container(
                    margin: EdgeInsets.all(8.r),
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111347).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.view_day,
                      color: const Color(0xFF111347),
                      size: 20.sp,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                items: _daysOfWeek.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDay = newValue;
                    });
                  }
                },
              ),
            ),
            const Gap25(),
          ],
        );

      case 5:
        // Task Progress
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Progress', Icons.trending_up),
            const Gap10(),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task Completion',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF111347),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  const Gap15(),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF111347),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: const Color(0xFF111347),
                      overlayColor: const Color(0xFF111347).withOpacity(0.2),
                      valueIndicatorColor: const Color(0xFF111347),
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      trackHeight: 8.0,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 24.0),
                    ),
                    child: Slider(
                      value: _progress,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_progress * 100).toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _progress = value;
                          if (value == 1.0) {
                            _isCompleted = true;
                          } else if (_isCompleted) {
                            _isCompleted = false;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Gap25(),
          ],
        );

      case 6:
        // Task Status (Completed/Not Completed)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Task Status', Icons.check_circle_outline),
            const Gap10(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SwitchListTile(
                title: Text(
                  'Mark as Completed',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  _isCompleted
                      ? 'This task is marked as completed'
                      : 'Toggle to mark this task as completed',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
                value: _isCompleted,
                activeColor: Colors.green,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onChanged: (bool value) {
                  setState(() {
                    _isCompleted = value;
                    if (value) {
                      _progress = 1.0; // If completed, set progress to 100%
                    }
                  });
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: _isCompleted ? Colors.green : Colors.grey,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            const Gap25(),
          ],
        );

      case 7:
        // Notification Toggle
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notifications', Icons.notifications),
            const Gap10(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  _notifyMe
                      ? 'You will receive reminders for this task'
                      : 'No reminders will be sent for this task',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                value: _notifyMe,
                activeColor: const Color(0xFF111347),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onChanged: (bool value) {
                  setState(() {
                    _notifyMe = value;
                  });
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _notifyMe
                        ? const Color(0xFF111347).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _notifyMe
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _notifyMe
                        ? const Color(0xFF111347)
                        : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
            const Gap25(),
          ],
        );

      case 8:
        // Save Button
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor:const Color(0xFF111347),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_outlined, size: 24.sp),
                const Gap10(isHorizontal: true,),
                Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: Colors.white,
        ),
        const Gap10(isHorizontal: true,),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 15.sp,
        color: Colors.black,
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF111347),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      errorStyle: GoogleFonts.poppins(
        color: Colors.red,
      ),
    );
  }
}

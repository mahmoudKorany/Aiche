import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_cubit.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_state.dart'; // Added explicit import for TasksState
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(String name, String description, DateTime deadline,
      bool notify, String day, int priority)? onAdd;

  const AddTaskScreen({
    super.key,
    this.onAdd,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _notifyMe = true;
  String _selectedDay = DateFormat('EEEE').format(DateTime.now());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
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
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
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

      // Use TasksCubit to add the task to the database
      TasksCubit.get(context).addTask(
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: deadline,
        shouldNotify: _notifyMe,
      );

      // Also call the callback if provided (for backward compatibility)
      if (widget.onAdd != null) {
        widget.onAdd!(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          deadline,
          _notifyMe,
          _selectedDay,
          _selectedPriorityIndex,
        );
      }

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
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Create New Task',
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
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      children: [
                        // Form content
                        AnimationLimiter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              8, // Number of form sections
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
                        const Gap20(),
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
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Enter task name'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Task name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],
        );

      case 1:
        // Task Description Field
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Description', Icons.description),
            const SizedBox(height: 10),
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
            const SizedBox(height: 24),
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
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                       // margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5),
                        decoration: BoxDecoration(
                          color: _selectedPriorityIndex == index
                              ? _priorities[index]['color'].withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedPriorityIndex == index
                              ? Border.all(
                                  color: _priorities[index]['color'], width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _priorities[index]['color'],
                                  shape: BoxShape.circle,
                                  boxShadow: _selectedPriorityIndex == index
                                      ? [
                                          BoxShadow(
                                            color: _priorities[index]['color']
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _priorities[index]['label'],
                                style: GoogleFonts.poppins(
                                  color: _selectedPriorityIndex == index
                                      ? _priorities[index]['color']
                                      : Colors.grey[700],
                                  fontWeight: _selectedPriorityIndex == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
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
            const SizedBox(height: 24),
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
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding:  EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111347).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child:  Icon(
                        Icons.calendar_today,
                        color:const  Color(0xFF111347),
                        size: 20.sp,
                      ),
                    ),
                    const Gap15(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111347),
                            ),
                          ),
                          const Gap5(),
                          Text(
                            _getFormattedDateTime(),
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:  EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color:const Color(0xFF111347).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_calendar,
                        color: const Color(0xFF111347),
                        size: 18.sp,
                      ),
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
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: InputDecoration(
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111347).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.view_day,
                      color: const Color(0xFF111347),
                      size: 20.sp,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111347).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF111347),
                    size: 20.sp,
                  ),
                ),
                items: _daysOfWeek.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(
                      day,
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedDay == day
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
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
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _notifyMe
                        ? const Color(0xFF111347)
                        : Colors.grey[700],
                  ),
                ),
                subtitle: Text(
                  'You will receive reminders for this task',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    letterSpacing: 0.2,
                  ),
                ),
                value: _notifyMe,
                activeColor: const Color(0xFF111347),
                activeTrackColor:
                const Color(0xFF111347).withOpacity(0.3),
                inactiveTrackColor: Colors.grey[300],
                inactiveThumbColor: Colors.grey[400],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onChanged: (bool value) {
                  setState(() {
                    _notifyMe = value;
                  });
                },
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _notifyMe
                        ?const Color(0xFF111347).withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _notifyMe
                            ? const Color(0xFF111347).withOpacity(0.1)
                            : Colors.transparent,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _notifyMe
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _notifyMe
                        ? const Color(0xFF111347)
                        : Colors.grey,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            const Gap40(),
          ],
        );

      case 6:
        // Save Button
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xFF111347),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF111347).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:  EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_task, size: 20.sp),
                    ),
                    const Gap15(isHorizontal: true,),
                    Text(
                      'Create Task',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap10(isHorizontal: true,),
            Center(
              child: Text(
                'Press to add the task to your list',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        );

      case 7:
        // Bottom padding
        return const Gap30();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 4.0.h),
      child: Row(
        children: [
          Container(
            padding:  EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: Colors.white,
            ),
          ),
          const Gap10(isHorizontal: true,),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 15.sp,
        color: Colors.grey[600],
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
      prefixIcon: hint.contains('task name')
          ? const Icon(Icons.assignment, color: Color(0xFF111347))
          : hint.contains('description')
              ? const Icon(Icons.description_outlined,
                  color: Color(0xFF111347))
              : null,
      suffixIcon: hint.contains('description')
          ? Icon(Icons.edit_note, color: Colors.grey[400])
          : null,
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      alignLabelWithHint: true,
      // Add subtle shadow inside the field for depth
    );
  }
}

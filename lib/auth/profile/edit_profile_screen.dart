import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class EditProfileScreen extends StatefulWidget {
  final String fieldToEdit;
  
  const EditProfileScreen({
    super.key, 
    required this.fieldToEdit,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  
  String _fieldTitle = '';
  String _fieldHint = '';
  IconData _fieldIcon = Icons.edit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Create animations
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    
    // Configure field properties based on the field to edit
    _setupFieldProperties();
    
    // Fetch current value
    _fetchCurrentValue();
    
    // Start the animation when the screen loads
    _controller.forward();
  }
  
  void _setupFieldProperties() {
    switch (widget.fieldToEdit) {
      case 'LinkedIn':
        _fieldTitle = 'Update LinkedIn Profile';
        _fieldHint = 'Enter your LinkedIn URL';
        _fieldIcon = Iconsax.message;
        break;
      case 'bio':
        _fieldTitle = 'Update Bio';
        _fieldHint = 'Tell us about yourself';
        _fieldIcon = Iconsax.user;
        break;
      case 'phone':
        _fieldTitle = 'Update Phone Number';
        _fieldHint = 'Enter your phone number';
        _fieldIcon = Iconsax.call;
        break;
      default:
        _fieldTitle = 'Update Profile';
        _fieldHint = 'Enter new information';
        _fieldIcon = Iconsax.edit;
    }
  }
  
  void _fetchCurrentValue() {
    final userModel = AuthCubit.get(context).userModel;
    if (userModel != null) {
      switch (widget.fieldToEdit) {
        case 'LinkedIn':
          _textController.text = userModel.linkedInLink ?? '';
          break;
        case 'bio':
          _textController.text = userModel.bio ?? '';
          break;
        case 'phone':
          _textController.text = userModel.phone ?? '';
          break;
        default:
          _textController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      if(AuthCubit.get(context).userModel != null) {
        switch (widget.fieldToEdit) {
          case 'LinkedIn':
            AuthCubit.get(context).updateUserData(
              context: context,
              bio: AuthCubit.get(context).userModel!.bio,
              phone: AuthCubit.get(context).userModel!.phone,
              linkedInLink: _textController.text,
            );
            break;
          case 'bio':
            AuthCubit.get(context).updateUserData(
              context: context,
              bio: _textController.text,
              phone: AuthCubit.get(context).userModel!.phone,
              linkedInLink: AuthCubit.get(context).userModel!.linkedInLink,
            );
            break;
          case 'phone':
            AuthCubit.get(context).updateUserData(
              context: context,
              bio: AuthCubit.get(context).userModel!.bio,
              phone: _textController.text,
              linkedInLink: AuthCubit.get(context).userModel!.linkedInLink,
            );
            break;
          default:
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UpdateUserDataSuccess) {
          setState(() {
            _isLoading = false;
          });
          showToast(msg: 'Updated successfully', state: MsgState.success);
          Navigator.pop(context);
        } else if (state is UpdateUserDataError) {
          setState(() {
            _isLoading = false;
          });
          showToast(msg: 'Failed To Update ', state: MsgState.error);
        }else if (state is UpdateUserDataLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            alignment: Alignment.center,
            children: [
              BackGround(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: EdgeInsets.only(left: 10.0.w),
                    child: Pop(),
                  ),
                  title: Text(
                    _fieldTitle,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                body: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(20.0.r),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap20(),
                                  Center(
                                    child: Container(
                                      width: 80.r,
                                      height: 80.r,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _fieldIcon,
                                        color: Colors.blue,
                                        size: 40.r,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Field label
                                  Text(
                                    'Current $_fieldTitle:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  
                                  const Gap10(),
                                  
                                  // Input field with animation
                                  TextFormField(
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: _fieldHint,
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: Icon(_fieldIcon, color: Colors.blue),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 15.r,
                                        horizontal: 20.r,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(color: Colors.blue.withOpacity(0.3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(color: Colors.blue.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(color: Colors.blue, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        borderSide: BorderSide(color: Colors.red, width: 1),
                                      ),
                                    ),
                                    maxLines: widget.fieldToEdit == 'bio' ? 5 : 1,
                                    keyboardType: widget.fieldToEdit == 'LinkedIn'
                                        ? TextInputType.text
                                        : (widget.fieldToEdit == 'phone'
                                            ? TextInputType.phone
                                            : TextInputType.text),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'This field cannot be empty';
                                      }
                                      if (widget.fieldToEdit == 'LinkedIn' && !_isValidLinkedIn(value)) {
                                        return 'Please enter a valid LinkedIn URL';
                                      }
                                      if (widget.fieldToEdit == 'phone' && !_isValidPhone(value)) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  // Info text for field requirements
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.r, left: 8.r),
                                    child: Text(
                                      _getInfoText(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                  
                                  const Gap50(),
                                  Center(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: _isLoading ? 60.r : 250.r,
                                      height: 55.r,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _submitUpdate,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(_isLoading ? 30.r : 15.r),
                                          ),
                                          elevation: 5,
                                          shadowColor: Colors.blue.withOpacity(0.5),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                                width: 30.r,
                                                height: 30.r,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3.r,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle_outline, size: 20.r),
                                                  SizedBox(width: 10.r),
                                                  Text(
                                                    'Update',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _getInfoText() {
    switch (widget.fieldToEdit) {
      case 'LinkedIn':
        return 'Enter a valid LinkedIn URL';
      case 'bio':
        return 'Tell others about yourself (max 150 characters)';
      case 'phone':
        return 'Enter a valid phone number with country code';
      default:
        return '';
    }
  }
  
  bool _isValidLinkedIn(String email) {
    return RegExp(r'^(https?:\/\/)?(www\.)?linkedin\.com\/.*$').hasMatch(email);
  }
  
  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone);
  }
}
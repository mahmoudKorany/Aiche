import 'dart:async';
import 'dart:io';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:aiche/auth/auth_screens/login_screen.dart';
import 'package:aiche/auth/models/user_model.dart';
import 'package:aiche/core/services/dio/dio.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/core/utils/cache-helper/cache-helper.dart';
import 'package:aiche/core/utils/google_signin_error_handler.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:aiche/main/committee/cubit/committee_cubit.dart';
import 'package:aiche/main/events/events_cubit/events_cubit.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:aiche/main/home/home_screen/home_layout_screen.dart';
import 'package:aiche/main/shop/shop_cubit/shop_cubit.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_cubit.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  static AuthCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  // login
  Future<void> login(
      String email, String password, BuildContext context) async {
    emit(AuthLoading());
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) {
        print("Warning: Could not get FCM token during login: $e");
        if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
          print("FCM service not available - this is normal in debug mode");
        }
      }
      // Continue with login even if we can't get FCM token
    }

    final response = await DioHelper.postData(
      url: UrlConstants.login,
      data: {
        'email': email,
        'password': password,
        "fcm_token":
            fcmToken ?? 'debug_mode_${DateTime.now().millisecondsSinceEpoch}'
      },
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Login failed';
      showToast(msg: errorMessage, state: MsgState.error);
      emit(AuthError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      try {
        if (response.data != null &&
            response.data is Map &&
            response.data['token'] != null) {
          final tokenValue = response.data['token']?.toString();
          await CacheHelper.saveData(key: 'token', value: tokenValue);
        }
        await getUserData();
        await Future.wait([
          TasksCubit.get(context).getTasksFromApi(),
          BlogsCubit.get(context).getBlogs(),
          LayoutCubit.get(context).getHomeBanner(),
          LayoutCubit.get(context).getAwards(),
          LayoutCubit.get(context).getMaterial(),
          EventsCubit.get(context).fetchEvents(),
          ShopCubit.get(context).getAllCollections(),
          ShopCubit.get(context).getAllProducts(),
          CommitteeCubit.get(context).getCommitteeData(),
        ]);
        emit(AuthSuccess());
        navigateAndFinish(context: context, widget: const HomeLayoutScreen());
        showToast(msg: 'Login done Successfully', state: MsgState.success);
      } catch (e) {
        emit(AuthError("Error parsing response data"));
      }
    } else {
      String errorMessage = 'Login Failed: Email or password is incorrect';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      showToast(msg: errorMessage, state: MsgState.error);
      emit(AuthError(errorMessage));
    }
  }

  // register
  Future<void> register(
      String name, String email, String password, context) async {
    emit(RegisterLoading());
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      // debugPrint("Could not get FCM token: $e");
      // Continue with login even if we can't get FCM token
    }

    final response =
        await DioHelper.postData(url: UrlConstants.register, data: {
      'name': name,
      'email': email,
      'password': password,
      "fcm_token": fcmToken ?? 'no token ${DateTime.now().toString()}'
    });

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Register failed';
      showToast(msg: errorMessage, state: MsgState.error);
      emit(RegisterError(errorMessage));
      return;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        if (response.data != null &&
            response.data is Map &&
            response.data['token'] != null) {
          final tokenValue = response.data['token']?.toString();
          await CacheHelper.saveData(key: 'token', value: tokenValue);
        }

        await getUserData();
        await Future.wait([
          BlogsCubit.get(context).getBlogs(),
          TasksCubit.get(context).getTasksFromApi(),
          LayoutCubit.get(context).getHomeBanner(),
          LayoutCubit.get(context).getAwards(),
          LayoutCubit.get(context).getMaterial(),
          ShopCubit.get(context).getAllCollections(),
          ShopCubit.get(context).getAllProducts(),
          EventsCubit.get(context).fetchEvents(),
          CommitteeCubit.get(context).getCommitteeData(),
        ]);
        navigateAndFinish(
          context: context,
          widget: const HomeLayoutScreen(),
        );
        showToast(msg: 'Register done Successfully', state: MsgState.success);
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterError("Error parsing response data"));
      }
    } else {
      String errorMessage = 'Register Failed: Email or password is incorrect';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      showToast(msg: errorMessage, state: MsgState.error);
      emit(RegisterError(errorMessage));
    }
  }

  Future<void> getUserData() async {
    token = await CacheHelper.getData(key: 'token');
    emit(AuthLoading1());

    final response = await DioHelper.getData(
      url: UrlConstants.getUserDetails,
      token: token,
      query: {},
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to get user data';
      emit(GetUserDataError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      userModel = UserModel.fromJson(response.data);
      emit(GetUserDataSuccess());
    } else {
      String errorMessage = 'Failed to get user data';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(GetUserDataError(errorMessage));
    }
  }

  Future<void> logout(BuildContext context) async {
    token = await CacheHelper.getData(key: 'token');
    emit(AuthLogoutLoading());

    final response = await DioHelper.getData(
      url: UrlConstants.logout,
      token: token,
      query: {},
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Logout failed';
      emit(AuthLogoutError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      navigateAndFinish(context: context, widget: const LoginScreen());
      showToast(msg: 'Logout done Successfully', state: MsgState.success);
      await CacheHelper.removeData(key: 'token');
      emit(AuthLogoutSuccess());
      Future.delayed(
        const Duration(seconds: 1),
        () {
          userModel = null;
        },
      );
    } else {
      String errorMessage = 'Logout failed';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(AuthLogoutError(errorMessage));
    }
  }

  // Update profile image
  Future<void> updateProfileImage({
    required BuildContext context,
    required File imageFile,
  }) async {
    emit(UpdateProfileImageLoading());
    token = await CacheHelper.getData(key: 'token');

    // Create form data for file upload
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      "bio": userModel?.bio,
      "phone": userModel?.phone,
      "linkedin": userModel?.linkedInLink,
    });
    Map<String, dynamic> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Make API call to update profile image
    final response = await DioHelper.postData(
        url: UrlConstants.updateUser,
        data: formData,
        token: token!,
        headers: headers);

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to update profile image';
      emit(UpdateProfileImageError(errorMessage));
      return;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      await getUserData();
      emit(UpdateProfileImageSuccess());
    } else {
      String errorMessage = 'Failed to update profile image';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(UpdateProfileImageError(errorMessage));
    }
  }

  // Update user data
  Future<void> updateUserData({
    required BuildContext context,
    required String? bio,
    required String? phone,
    required String? linkedInLink,
  }) async {
    emit(UpdateUserDataLoading());

    // Prepare data for the API call
    Map<String, dynamic> data = {
      "bio": bio,
      "phone": phone,
      "linkedin": linkedInLink,
    };

    // Make API call to update user data
    final response = await DioHelper.postData(
      url: UrlConstants.updateUser,
      data: data,
      token: token!,
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to update user data';
      emit(UpdateUserDataError(errorMessage));
      return;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      await getUserData();
      emit(UpdateUserDataSuccess());
      showToast(msg: 'User data updated successfully', state: MsgState.success);
    } else {
      String errorMessage = 'Failed to update user data';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(UpdateUserDataError(errorMessage));
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    emit(AuthGoogleLoading());

    try {
      // Initialize Google Sign In with the new client configuration
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Check if user is already signed in and sign out for clean state
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Add a small delay to ensure clean state
      await Future.delayed(const Duration(milliseconds: 500));

      // Begin the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        emit(AuthGoogleError("Google Sign In cancelled"));
        return;
      }

      // Verify we have a valid user
      if (googleUser.email.isEmpty) {
        emit(AuthGoogleError("Failed to get user information from Google"));
        return;
      }

      // Get authentication details with timeout
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication.timeout(const Duration(seconds: 30));

      // Get ID token to send to backend
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        emit(AuthGoogleError("Failed to get Google ID token"));
        return;
      }

      // Get FCM token for notifications with better error handling
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        print("Warning: Could not get FCM token: $e");
        // Continue with Google sign in even if we can't get FCM token
      }

      // Make API call to sign in with Google using the ID token
      final response = await DioHelper.postData(
        url: UrlConstants.signWithGoogle,
        data: {
          "id_token": idToken,
          "fcm_token": fcmToken ?? 'no token ${DateTime.now().toString()}'
        },
      );

      // Check if the response contains an error
      if (response.data != null &&
          response.data is Map &&
          response.data['error'] == true) {
        String errorMessage =
            response.data['message'] ?? 'Google Sign In failed';
        showToast(msg: errorMessage, state: MsgState.error);
        emit(AuthGoogleError(errorMessage));
        return;
      }

      if (response.statusCode == 200) {
        try {
          if (response.data != null &&
              response.data is Map &&
              response.data['token'] != null) {
            final tokenValue = response.data['token']?.toString();
            if (tokenValue == null || tokenValue.isEmpty) {
              emit(AuthGoogleError("Invalid token received from server"));
              return;
            }

            await CacheHelper.saveData(key: 'token', value: tokenValue);
          } else {
            emit(AuthGoogleError("Invalid response from server"));
            return;
          }
          await getUserData();
          await Future.wait([
            BlogsCubit.get(context).getBlogs(),
            LayoutCubit.get(context).getHomeBanner(),
            LayoutCubit.get(context).getAwards(),
            LayoutCubit.get(context).getMaterial(),
            EventsCubit.get(context).fetchEvents(),
            ShopCubit.get(context).getAllCollections(),
            ShopCubit.get(context).getAllProducts(),
            CommitteeCubit.get(context).getCommitteeData(),
            TasksCubit.get(context).getTasksFromApi(),
          ]).timeout(const Duration(seconds: 30));

          emit(AuthGoogleSuccess());
          navigateAndFinish(context: context, widget: const HomeLayoutScreen());
          showToast(msg: 'Google Sign In Successful', state: MsgState.success);
        } catch (e) {
          print("Error processing Google sign in response: $e");
          emit(AuthGoogleError(
              "Error processing Google sign in response: ${e.toString()}"));
        }
      } else {
        String errorMessage = "Google Sign In failed";
        if (response.data != null &&
            response.data is Map &&
            response.data['message'] != null) {
          errorMessage = response.data['message'].toString();
        }
        showToast(msg: errorMessage, state: MsgState.error);
        emit(AuthGoogleError(errorMessage));
      }
    } on TimeoutException {
      emit(AuthGoogleError('Google Sign In timed out. Please try again.'));
    } catch (e) {
      String errorMessage = GoogleSignInErrorHandler.getErrorMessage(e);
      print("Google Sign In Error: $errorMessage");
      showToast(msg: errorMessage, state: MsgState.error);
      emit(AuthGoogleError(errorMessage));
    }
  }
}

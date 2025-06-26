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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  static AuthCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  // login
  Future<void> login(
      String email, String password, BuildContext context) async
  {
    emit(AuthLoading());
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      //debugPrint("Could not get FCM token: $e");
      // Continue with login even if we can't get FCM token
    }
    print("FCM Token: $fcmToken");
    try {
      final response = await DioHelper.postData(
        url: UrlConstants.login,
        data: {
          'email': email,
          'password': password,
          "fcm_token": fcmToken ?? 'no token'
        },
      );

      if (response.statusCode == 200) {
        try {
          if (response.data != null &&
              response.data is Map &&
              response.data['token'] != null) {
            final tokenValue = response.data['token']?.toString();
            await CacheHelper.saveData(key: 'token', value: tokenValue);
          }
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
            getUserData(),
          ]);
          emit(AuthSuccess());
          navigateAndFinish(context: context, widget: const HomeLayoutScreen());
          showToast(msg: 'Login done Successfully', state: MsgState.success);
        } catch (e) {
          emit(AuthError("Error parsing response data"));
        }
      } else {
        emit(AuthError(response.data.toString()));
      }
    } catch (e) {
      showToast(
          msg: 'Login Failed: Email or password is incorrect',
          state: MsgState.error);
      emit(AuthError(e.toString()));
    }
  }

  // register
  Future<void> register(
      String name, String email, String password, context) async
  {
    emit(RegisterLoading());
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      // debugPrint("Could not get FCM token: $e");
      // Continue with login even if we can't get FCM token
    }

    try {
      final response =
          await DioHelper.postData(url: UrlConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        "fcm_token": fcmToken ?? 'no token ${DateTime.now().toString()}'
      });
      await CacheHelper.saveData(key: 'token', value: response.data['token']);

      await Future.wait([
        BlogsCubit.get(context).getBlogs(),
        TasksCubit.get(context).getTasksFromApi(),
        LayoutCubit.get(context).getHomeBanner(),
        LayoutCubit.get(context).getAwards(),
        LayoutCubit.get(context).getMaterial(),
        ShopCubit.get(context).getAllCollections(),
        ShopCubit.get(context).getAllProducts(),
        getUserData(),
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
      showToast(
          msg: 'Register Failed: Email or password is incorrect',
          state: MsgState.error);
      emit(RegisterError('Register Failed'));
    }
  }

  Future<void> getUserData() async {
    emit(AuthLoading1());
    try {
      final response = await DioHelper.getData(
        url: UrlConstants.getUserDetails,
        token: token,
        query: {},
      );

      if (response.statusCode == 200) {
        userModel = UserModel.fromJson(response.data);
        emit(GetUserDataSuccess());
      } else {
        emit(GetUserDataError(response.data.toString()));
      }
    } catch (e) {
      // print(token);
      //print(e.toString());
      emit(GetUserDataError(e.toString()));
    }
  }

  Future<void> logout(BuildContext context) async {
    token = await CacheHelper.getData(key: 'token');
    emit(AuthLogoutLoading());
    try {
      final response = await DioHelper.getData(
        url: UrlConstants.logout,
        token: token,
        query: {},
      );
      //print(response.data);
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
        emit(AuthLogoutError(response.data.toString()));
      }
    } catch (e) {
      //8log(e.toString());
      emit(AuthLogoutError(e.toString()));
    }
  }

  // Update profile image
  Future<void> updateProfileImage({
    required BuildContext context,
    required File imageFile,
  }) async
  {
    emit(UpdateProfileImageLoading());
    token = await CacheHelper.getData(key: 'token');
    try {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getUserData();
        emit(UpdateProfileImageSuccess());
      } else {
        emit(UpdateProfileImageError('Failed to update profile image'));
      }
    } catch (e) {
      emit(UpdateProfileImageError(e.toString()));
    }
  }

  // Update user data
  Future<void> updateUserData({
    required BuildContext context,
    required String? bio,
    required String? phone,
    required String? linkedInLink,
  }) async
  {
    emit(UpdateUserDataLoading());

    try {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getUserData();
        emit(UpdateUserDataSuccess());
        showToast(
            msg: 'User data updated successfully', state: MsgState.success);
      } else {
        emit(UpdateUserDataError('Failed to update user data'));
      }
    } catch (e) {
      emit(UpdateUserDataError(e.toString()));
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
      final String? accessToken = googleAuth.accessToken;

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
          "access_token": accessToken,
          "email": googleUser.email,
          "name": googleUser.displayName ?? '',
          "fcm_token": fcmToken ?? 'no token ${DateTime.now().toString()}'
        },
      );

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

          // Load all necessary data after successful sign in
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
            getUserData(),
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

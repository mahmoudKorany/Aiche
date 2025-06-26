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
      String email, String password, BuildContext context) async {
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
          await TasksCubit.get(context).getTasksFromApi();
          await BlogsCubit.get(context).getBlogs();
          await LayoutCubit.get(context).getHomeBanner();
          await LayoutCubit.get(context).getAwards();
          await LayoutCubit.get(context).getMaterial();
          await EventsCubit.get(context).fetchEvents();
          await ShopCubit.get(context).getAllCollections();
          await ShopCubit.get(context).getAllProducts();
          await CommitteeCubit.get(context).getCommitteeData();
          await getUserData();
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
      String name, String email, String password, context) async {
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
      await CacheHelper.saveData(key: 'token', value: response.data['token'])
          .then((v) async {});
      await BlogsCubit.get(context).getBlogs();
      await TasksCubit.get(context).getTasksFromApi();
      await LayoutCubit.get(context).getHomeBanner();
      await LayoutCubit.get(context).getAwards();
      await LayoutCubit.get(context).getMaterial();
      await ShopCubit.get(context).getAllCollections();
      await ShopCubit.get(context).getAllProducts();
      await getUserData();
      await EventsCubit.get(context).fetchEvents();
      await CommitteeCubit.get(context).getCommitteeData();
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
        navigateAndFinish(context: context, widget: LoginScreen());
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
  }) async {
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
  }) async {
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
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Begin the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        emit(AuthGoogleError("Google Sign In cancelled"));
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get ID token to send to backend
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        emit(AuthGoogleError("Failed to get Google ID token"));
        return;
      }

      // Get FCM token for notifications
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
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


      if (response.statusCode == 200) {
        try {
          if (response.data != null &&
              response.data is Map &&
              response.data['token'] != null) {
            final tokenValue = response.data['token']?.toString();
            await CacheHelper.saveData(key: 'token', value: tokenValue);
          }

          // Load all necessary data after successful sign in
          await BlogsCubit.get(context).getBlogs();
          await LayoutCubit.get(context).getHomeBanner();
          await LayoutCubit.get(context).getAwards();
          await LayoutCubit.get(context).getMaterial();
          await EventsCubit.get(context).fetchEvents();
          await ShopCubit.get(context).getAllCollections();
          await ShopCubit.get(context).getAllProducts();
          await CommitteeCubit.get(context).getCommitteeData();

          emit(AuthGoogleSuccess());
          await getUserData();
          navigateAndFinish(context: context, widget: const HomeLayoutScreen());
          showToast(msg: 'Google Sign In Successful', state: MsgState.success);
        } catch (e) {
          emit(AuthGoogleError("Error processing Google sign in response"));
        }
      } else {
        emit(AuthGoogleError(response.data.toString()));
      }
    } catch (e) {
      showToast(
          msg: 'Google Sign In Failed: ${e.toString()}', state: MsgState.error);
      emit(AuthGoogleError(e.toString()));
    }
  }
}

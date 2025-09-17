import 'package:aiche/core/services/dio/dio.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/main/blogs/blogs_screen/blogs_screen.dart';
import 'package:aiche/main/events/events_screen/events_screen.dart';
import 'package:aiche/main/home/home_component/home_body.dart';
import 'package:aiche/main/home/model/awards_model.dart';
import 'package:aiche/main/home/model/banner_model.dart';
import 'package:aiche/main/home/model/material_model.dart';
import 'package:aiche/main/sessions/model/session_model.dart';
import 'package:aiche/main/shop/shop_screen/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../tasks/tasks_screen/tasks_screen.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(context) => BlocProvider.of(context);

  List<Widget> screens = [
    const HomeBody(),
    const BlogsScreen(),
    const EventsScreen(),
    const TasksScreen(),
    const ShopScreen(),
  ];
  int currentIndex = 0;

  void changeBottomNavBar(int index, context) {
    currentIndex = index;
    emit(LayoutChangeBottomNavBar());
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var bannerList = <BannerModel>[];
  Future<void> getHomeBanner() async {
    bannerList = [];
    emit(LayoutGetBannerLoading());

    final response = await DioHelper.getData(
        url: UrlConstants.getHomeBanner, query: {}, token: token ?? '');

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Failed to load banner';
      emit(LayoutGetBannerError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['baners']) {
        bannerList.add(BannerModel.fromJson(element));
      }
      await getAwards();
      await getMaterial();
      emit(LayoutGetBannerSuccess());
    } else {
      String errorMessage = 'Failed to load banner';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(LayoutGetBannerError(errorMessage));
    }
  }

  //get material
  var materialList = <MaterialModel>[];

  Future<void> getMaterial() async {
    materialList = [];
    emit(LayoutGetMaterialLoading());

    final response = await DioHelper.getData(
      url: UrlConstants.getMaterial,
      query: {},
      token: token ?? '',
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to load material';
      emit(LayoutGetMaterialError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']['date']) {
        materialList.add(MaterialModel.fromJson(element));
      }
      emit(LayoutGetMaterialSuccess());
    } else {
      String errorMessage = 'Failed to load material';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(LayoutGetMaterialError(errorMessage));
    }
  }

  //get awards
  var awardsList = <AwardsModel>[];

  Future<void> getAwards() async {
    awardsList = [];
    emit(LayoutGetAwardsLoading());

    final response = await DioHelper.getData(
      url: UrlConstants.getAwards,
      query: {},
      token: token ?? '',
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Failed to load awards';
      emit(LayoutGetAwardsError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']) {
        awardsList.add(AwardsModel.fromJson(element));
      }
      emit(LayoutGetAwardsSuccess());
    } else {
      String errorMessage = 'Failed to load awards';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(LayoutGetAwardsError(errorMessage));
    }
  }

  // request join
  Future<void> requestJoinCommittee({
    required int committeeId,
  }) async {
    emit(LayoutRequestJoinLoading());

    final response = await DioHelper.postData(
      url: UrlConstants.requestJoin,
      data: {
        'committee_id': committeeId,
      },
      token: token ?? '',
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to request join committee';
      showToast(msg: errorMessage, state: MsgState.error);
      emit(LayoutRequestJoinError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      showToast(
          msg: 'Join request sent successfully!', state: MsgState.success);
      emit(LayoutRequestJoinSuccess());
    } else {
      String errorMessage = 'Failed to request join committee';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      showToast(msg: errorMessage, state: MsgState.error);
      emit(LayoutRequestJoinError(errorMessage));
    }
  }

  //get user sessions
  List<SessionModel> userSessions = [];
  Future<void> getUserSessions() async {
    userSessions = [];
    emit(LayoutGetUserSessionsLoading());

    final response = await DioHelper.getData(
      url: UrlConstants.getSessions,
      query: {},
      token: token ?? '',
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to load user sessions';
      emit(LayoutGetUserSessionsError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']) {
        userSessions.add(SessionModel.fromJson(element));
      }
      emit(LayoutGetUserSessionsSuccess());
    } else {
      String errorMessage = 'Failed to load user sessions';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(LayoutGetUserSessionsError(errorMessage));
    }
  }
}

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
import 'package:flutter/foundation.dart';
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
    try {
      await DioHelper.getData(
        url: UrlConstants.getHomeBanner,
        query: {},
        token: token??''
      ).then((value) async{
        if (value.statusCode == 200) {
          for (var element in value.data['baners']) {
            bannerList.add(BannerModel.fromJson(element));
          }
          await getAwards();
          await getMaterial();
        } else {
          emit(LayoutGetBannerError(value.statusMessage.toString()));
        }
      });
      emit(LayoutGetBannerSuccess());
    } catch (error) {
      emit(LayoutGetBannerError(error.toString()));
    }
  }

  //get material
  var materialList = <MaterialModel>[];

  Future<void> getMaterial() async {
    materialList = [];
    emit(LayoutGetMaterialLoading());
    try {
      await DioHelper.getData(
        url: UrlConstants.getMaterial,
        query: {},
        token: token??'',
      ).then((value) {
        if (value.statusCode == 200) {
          for (var element in value.data['data']['date']) {
            materialList.add(MaterialModel.fromJson(element));
          }
        } else {
          emit(LayoutGetMaterialError(value.statusMessage.toString()));
        }
      });
      emit(LayoutGetMaterialSuccess());
    } catch (error) {
      emit(LayoutGetMaterialError(error.toString()));
    }
  }


  //get awards
  var awardsList = <AwardsModel>[];

  Future<void> getAwards() async {
    awardsList = [];
    emit(LayoutGetAwardsLoading());
    try {
      await DioHelper.getData(
        url: UrlConstants.getAwards,
        query: {},
        token: token??'',
      ).then((value) {
        if (value.statusCode == 200) {
          for (var element in value.data['data']) {
            awardsList.add(AwardsModel.fromJson(element));
          }
        } else {
          emit(LayoutGetAwardsError(value.statusMessage.toString()));
        }
      });
      emit(LayoutGetAwardsSuccess());
    } catch (error) {
      emit(LayoutGetAwardsError(error.toString()));
    }
  }


  // request join
  Future<void> requestJoinCommittee({
    required int committeeId,
  }) async {
    emit(LayoutRequestJoinLoading());
    try {
      await DioHelper.postData(
        url: UrlConstants.requestJoin,
        data: {
          'committee_id': committeeId,
        },
        token: token??'',
      ).then((value) {
        if (value.statusCode == 200) {

          emit(LayoutRequestJoinSuccess());
        } else {
          emit(LayoutRequestJoinError(value.statusMessage.toString()));
        }
      });
    } catch (error) {
      showToast(msg: "Failed to request join : Maybe you are already member of committee", state: MsgState.error );
      emit(LayoutRequestJoinError(error.toString()));
    }
  }

  //get user sessions
  List<SessionModel> userSessions = [];
  Future<void> getUserSessions() async {
    userSessions = [];
    emit(LayoutGetUserSessionsLoading());
    try {
       await DioHelper.getData(
        url: UrlConstants.getSessions,
        query: {},
        token: token??'',
      ).then((value) {
        if (value.statusCode == 200) {
          for (var element in value.data['data']) {
            userSessions.add(SessionModel.fromJson(element));
          }
        } else {
          emit(LayoutGetUserSessionsError(value.statusMessage.toString()));
        }
      });
      emit(LayoutGetUserSessionsSuccess());
    } catch (error) {
      emit(LayoutGetUserSessionsError(error.toString()));
    }
  }
}

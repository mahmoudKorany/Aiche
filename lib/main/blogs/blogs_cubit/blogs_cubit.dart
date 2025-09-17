import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/dio/dio.dart';
import '../../../core/shared/constants/constants.dart';
import '../../../core/utils/cache-helper/cache-helper.dart';
import '../model/blog_model.dart';
part 'blogs_state.dart';

class BlogsCubit extends Cubit<BlogsState> {
  BlogsCubit() : super(BlogsInitial());

  static BlogsCubit get(context) => BlocProvider.of(context);
  List<BlogModel> blogs = [];

  ///get blogs
  Future<void> getBlogs() async {
    token = await CacheHelper.getData(key: 'token');
    emit(BlogsLoading());

    final response = await DioHelper.getData(
      token: token ?? '',
      query: {},
      url: UrlConstants.getBlogs,
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Failed to load blogs';
      emit(BlogsError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      blogs = [];
      for (var element in response.data['data']) {
        blogs.add(BlogModel.fromJson(element));
      }
      emit(BlogsSuccess());
    } else {
      String errorMessage = 'Failed to load blogs';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(BlogsError(errorMessage));
    }
  }
}

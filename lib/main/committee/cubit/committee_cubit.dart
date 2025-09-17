import 'package:aiche/core/services/dio/dio.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/main/committee/cubit/committee_states.dart';
import 'package:aiche/main/committee/model/committee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/shared/constants/constants.dart';

class CommitteeCubit extends Cubit<CommitteeState> {
  CommitteeCubit() : super(CommitteeInitial());

  static CommitteeCubit get(context) => BlocProvider.of(context);

  //Get Committee Data
  List<CommitteeModel> committeeList = [];

  Future<void> getCommitteeData() async {
    committeeList = [];
    emit(GetCommitteeLoadingState());

    final response = await DioHelper.getData(
        url: UrlConstants.getCommittees, query: {}, token: token);

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to load committee data';
      emit(GetCommitteeErrorState(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']) {
        committeeList.add(CommitteeModel.fromJson(element));
      }
      emit(GetCommitteeSuccessState());
    } else {
      String errorMessage = 'Failed to load committee data';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(GetCommitteeErrorState(errorMessage));
    }
  }
}

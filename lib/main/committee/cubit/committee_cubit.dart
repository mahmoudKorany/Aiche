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
    try {
      DioHelper.getData(
              url: UrlConstants.getCommittees, query: {}, token: token)
          .then((value) {
        for (var element in value.data['data']) {
          committeeList.add(CommitteeModel.fromJson(element));
        }
        emit(GetCommitteeSuccessState());
      });
    } catch (error) {
      emit(GetCommitteeErrorState(error.toString()));
    }
  }
}

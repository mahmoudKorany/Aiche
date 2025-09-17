import 'package:aiche/core/services/dio/dio.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/main/events/events_cubit/events_state.dart';
import 'package:aiche/main/events/events_model/event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit() : super(EventsInitial());
  static EventsCubit get(context) => BlocProvider.of(context);

  List<EventModel> events = [];

  Future<void> fetchEvents() async {
    events = [];
    emit(EventsLoading());

    final response = await DioHelper.getData(
      url: UrlConstants.getEvents,
      query: {},
      token: token ?? '',
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage = response.data['message'] ?? 'Failed to load events';
      emit(EventsError(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']) {
        events.add(EventModel.fromJson(element));
      }
      emit(EventsLoaded());
    } else {
      String errorMessage = 'Failed to load events';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(EventsError(errorMessage));
    }
  }
}

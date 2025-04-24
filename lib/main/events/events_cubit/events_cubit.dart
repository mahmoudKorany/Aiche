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
    try {
      await DioHelper.getData(
        url: UrlConstants.getEvents,
        query: {},
        token: token??'',
      ).then((value){
        if (value.statusCode == 200) {
          for (var element in value.data['data']) {
            events.add(EventModel.fromJson(element));
          }
        } else {
          emit(EventsError(value.statusMessage.toString()));
        }
      });
      emit(EventsLoaded());
    } catch (error) {
      emit(EventsError('Failed to load events'));
    }
  }

}

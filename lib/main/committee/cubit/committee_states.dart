abstract class CommitteeState {}

class CommitteeInitial extends CommitteeState {}

class GetCommitteeLoadingState extends CommitteeState {}

class GetCommitteeSuccessState extends CommitteeState {}
class GetCommitteeErrorState extends CommitteeState {
  final String error;

  GetCommitteeErrorState(this.error);
}

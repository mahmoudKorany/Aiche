part of 'layout_cubit.dart';

@immutable
sealed class LayoutState {}

final class LayoutInitial extends LayoutState {}

final class LayoutChangeBottomNavBar extends LayoutState {}

//get banner
final class LayoutGetBannerLoading extends LayoutState {}
final class LayoutGetBannerSuccess extends LayoutState {}
final class LayoutGetBannerError extends LayoutState {
  final String error;
  LayoutGetBannerError(this.error);
}

//get material
final class LayoutGetMaterialLoading extends LayoutState {}
final class LayoutGetMaterialSuccess extends LayoutState {}
final class LayoutGetMaterialError extends LayoutState {
  final String error;
  LayoutGetMaterialError(this.error);
}

//get awards
final class LayoutGetAwardsLoading extends LayoutState {}
final class LayoutGetAwardsSuccess extends LayoutState {}
final class LayoutGetAwardsError extends LayoutState {
  final String error;
  LayoutGetAwardsError(this.error);
}

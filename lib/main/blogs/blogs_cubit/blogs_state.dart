part of 'blogs_cubit.dart';

@immutable
sealed class BlogsState {}

final class BlogsInitial extends BlogsState {}

final class BlogsLoading extends BlogsState {}
final class BlogsSuccess extends BlogsState {}
final class BlogsError extends BlogsState {
  final String error;
  BlogsError(this.error);
}

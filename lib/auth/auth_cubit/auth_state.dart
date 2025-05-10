abstract class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}
final class AuthLoading1 extends AuthState {}

final class AuthSuccess extends AuthState {}

final class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}

final class GetUserDataLoading extends AuthState {}

final class GetUserDataSuccess extends AuthState {}

final class GetUserDataError extends AuthState {
  final String error;
  GetUserDataError(this.error);
}

//register
final class RegisterLoading extends AuthState {}

final class RegisterSuccess extends AuthState {}

final class RegisterError extends AuthState {
  final String error;
  RegisterError(this.error);
}

//logout
final class AuthLogoutLoading extends AuthState {}

final class AuthLogoutSuccess extends AuthState {}

final class AuthLogoutError extends AuthState {
  final String error;
  AuthLogoutError(this.error);
}

//update profile
final class UpdateProfileLoading extends AuthState {}

final class UpdateProfileSuccess extends AuthState {}

final class UpdateProfileError extends AuthState {
  final String error;
  UpdateProfileError(this.error);
}

//update profile image
final class UpdateProfileImageLoading extends AuthState {}

final class UpdateProfileImageSuccess extends AuthState {}

final class UpdateProfileImageError extends AuthState {
  final String error;
  UpdateProfileImageError(this.error);
}

final class UpdateUserDataLoading extends AuthState {}

final class UpdateUserDataSuccess extends AuthState {}

final class UpdateUserDataError extends AuthState {
  final String error;
  UpdateUserDataError(this.error);
}

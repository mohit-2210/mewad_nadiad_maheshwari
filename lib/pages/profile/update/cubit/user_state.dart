abstract class UserState {}

class UserInitial extends UserState {}

class UserUpdating extends UserState {}

class UserUpdateSuccess extends UserState {}

class UserUpdateFailure extends UserState {
  final String message;
  UserUpdateFailure(this.message);
}

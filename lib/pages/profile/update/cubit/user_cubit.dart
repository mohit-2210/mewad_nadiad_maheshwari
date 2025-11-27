import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/pages/profile/update/cubit/user_state.dart';
import 'package:mmsn/pages/profile/update/service/user_repository.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repo;

  UserCubit(this._repo) : super(UserInitial());

  Future<void> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    emit(UserUpdating());

    try {
      await _repo.updateUserProfile(userId, data);
      emit(UserUpdateSuccess());
    } catch (e) {
      emit(UserUpdateFailure(e.toString()));
    }
  }
}

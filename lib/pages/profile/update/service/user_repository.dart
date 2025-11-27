import 'package:mmsn/pages/auth/data/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> updatedData,
  ) {
    return _service.updateUser(
      userId,
      updatedData,
    );
  }
}


import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/auth/data/auth_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class AuthRepository {
  final AuthApiService _api = AuthApiService();

  Future<UserModel> login(String mobile, String password) async {
    final response = await _api.login(mobile, password);

    if (response.data["status"] == true) {
      final user = UserModel.fromJson(response.data["data"]["user"]);
      final tokens = TokenModel.fromJson(response.data["data"]);
      await AuthLocalStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
      return user;
    } else {
      throw Exception(response.data["message"]);
    }
  }

  Future<void> sendOtp(String mobile) async {
    await _api.sendOtp(mobile);
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    await _api.verifyOtp(mobile, otp);
  }
}

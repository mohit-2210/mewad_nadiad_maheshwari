import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/services/device_service.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthInitial());

  final AuthRepository _repo;

  // Step 1: Check if user exists
  Future<void> checkUser(String mobile) async {
    emit(AuthLoading());
    try {
      final result = await _repo.checkUser(mobile);

      switch (result.status) {
        case UserExistsStatus.existsWithPin:
          emit(UserExistsWithPin(mobile));
          break;
        case UserExistsStatus.existsWithoutPin:
          if (result.user != null) {
            emit(UserExistsWithoutPin(mobile, result.user!));
          } else {
            emit(AuthError('User data is missing'));
          }
          break;
        case UserExistsStatus.doesNotExist:
          emit(UserDoesNotExist(mobile));
          break;
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(UserDoesNotExist(mobile));
      } else {
        emit(AuthError(e.message));
      }
    } catch (e) {
      emit(AuthError('Failed to check user: ${e.toString()}'));
    }
  }

  // Login with mobile and PIN
  Future<void> loginWithPin(String mobile, String password) async {
    emit(AuthLoading());
    try {
      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        emit(AuthError("Device details not ready. Please try again."));
        return;
      }

      final user = await _repo.login(mobile, password, deviceId, deviceToken);
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Send OTP (for users without PIN or new users)
  Future<void> sendOtp(String mobile, {bool isNewUser = false}) async {
    emit(AuthLoading());
    try {
      await _repo.sendOtp(mobile);
      emit(OtpSent(mobile, isNewUser: isNewUser));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  // Verify OTP
  Future<void> verifyOtp(String mobile, String otp,
      {bool isNewUser = false}) async {
    emit(AuthLoading());
    try {
      final isValid = await _repo.verifyOtp(otp);

      if (isValid) {
        emit(OtpVerified(mobile, needsPin: !isNewUser, isNewUser: isNewUser));
      } else {
        emit(AuthError("Invalid OTP"));
      }
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('OTP verification failed: ${e.toString()}'));
    }
  }

  // Set PIN for existing user (after OTP verification)
  Future<void> setPin(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      final user = await _repo.setPin(mobile, pin);
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to set PIN: ${e.toString()}'));
    }
  }

  // Register new user - just creates user, doesn't log in
  Future<void> register(Map<String, dynamic> userData) async {
    emit(AuthLoading());
    try {
      // Call register API which creates the user
      await _repo.register(userData);

      // Registration successful - emit state with mobile and PIN
      // This will trigger navigation to OTP screen
      emit(RegistrationSuccess(
        mobile: userData['mobile'] as String,
        pin: userData['password'] as String,
      ));
    } on ValidationException catch (e) {
      final errorMessage = e.errors != null && e.errors!.isNotEmpty
          ? e.errors!.values.first.toString()
          : e.message;
      emit(AuthError(errorMessage));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  // Auto-login after successful OTP verification (for new users)
  Future<void> loginAfterRegistration(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        emit(AuthError("Device details not ready. Please try again."));
        return;
      }

      final user = await _repo.login(mobile, pin, deviceId, deviceToken);
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Auto-login failed: ${e.toString()}'));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _repo.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      // Even if API fails, clear local data
      emit(AuthLoggedOut());
    }
  }

  // Check if already logged in
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    emit(AuthLoading());

    try {
      await _repo.changePassword(oldPassword, newPassword);

      emit(PasswordChanged()); // Create this state in AuthState
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError("Failed to change password: ${e.toString()}"));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/services/device_service.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthInitial());

  final AuthRepository _repo;

  // ==================== Check User ====================
  
  Future<void> checkUser(String mobile) async {
    emit(AuthLoading());
    try {
      print('🔍 Checking user: $mobile');
      final result = await _repo.checkUser(mobile);

      switch (result.status) {
        case UserExistsStatus.existsWithPin:
          print('✅ User exists with PIN');
          emit(UserExistsWithPin(mobile));
          break;
        case UserExistsStatus.existsWithoutPin:
          print('⚠️ User exists without PIN');
          if (result.user != null) {
            emit(UserExistsWithoutPin(mobile, result.user!));
          } else {
            emit(AuthError('User data is missing'));
          }
          break;
        case UserExistsStatus.doesNotExist:
          print('❌ User does not exist');
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

  // ==================== Login with PIN ====================
  
  Future<void> loginWithPin(String mobile, String password) async {
    emit(AuthLoading());
    try {
      print('🔐 Logging in with PIN: $mobile');
      
      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        emit(AuthError("Device details not ready. Please try again."));
        return;
      }

      final user = await _repo.login(mobile, password, deviceId, deviceToken);
      print('✅ Login successful');
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // ==================== Send OTP ====================
  
  Future<void> sendOtp(String mobile, {bool isNewUser = false}) async {
    emit(AuthLoading());
    try {
      print('📤 Sending OTP to: $mobile (isNewUser: $isNewUser)');
      await _repo.sendOtp(mobile);
      print('✅ OTP sent successfully');
      emit(OtpSent(mobile, isNewUser: isNewUser));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  // ==================== Verify OTP ====================
  
  Future<void> verifyOtp(
    String mobile,
    String otp, {
    bool isNewUser = false,
  }) async {
    emit(AuthLoading());
    try {
      print('🔐 Verifying OTP: $otp for $mobile (isNewUser: $isNewUser)');
      
      // Verify OTP with tokens included for new users
      final result = await _repo.verifyOtp(otp, includeTokens: isNewUser);

      if (result != null) {
        print('✅ OTP verified successfully');
        
        if (isNewUser) {
          // For new users, tokens are already saved, emit verified state
          // The UI will trigger auto-login with the PIN
          emit(OtpVerified(mobile, needsPin: false, isNewUser: true));
        } else {
          // For existing users without PIN, they need to set PIN
          emit(OtpVerified(mobile, needsPin: true, isNewUser: false));
        }
      } else {
        emit(AuthError("Invalid OTP"));
      }
    } on ApiException catch (e) {
      print('❌ OTP verification failed: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('❌ OTP verification error: $e');
      emit(AuthError('OTP verification failed: ${e.toString()}'));
    }
  }

  // ==================== Set PIN ====================
  
  Future<void> setPin(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      print('🔑 Setting PIN for: $mobile');
      final user = await _repo.setPin(mobile, pin);
      print('✅ PIN set and user logged in');
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to set PIN: ${e.toString()}'));
    }
  }

  // ==================== Register ====================
  
  Future<void> register(Map<String, dynamic> userData) async {
    emit(AuthLoading());
    try {
      print('📝 Registering user: ${userData['mobile']}');
      
      // Register user - this will also save OTP token
      await _repo.register(userData);

      print('✅ Registration successful');
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

  // ==================== Login After Registration ====================
  
  Future<void> loginAfterRegistration(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      print('🔐 Auto-login after registration: $mobile');
      
      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        emit(AuthError("Device details not ready. Please try again."));
        return;
      }

      final user = await _repo.loginAfterRegistration(mobile, pin);
      print('✅ Auto-login successful');
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      print('❌ Auto-login failed: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('❌ Auto-login error: $e');
      emit(AuthError('Auto-login failed: ${e.toString()}'));
    }
  }

  // ==================== Logout ====================
  
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      print('🚪 Logging out');
      await _repo.logout();
      print('✅ Logged out successfully');
      emit(AuthLoggedOut());
    } catch (e) {
      print('⚠️ Logout error (clearing local data anyway): $e');
      emit(AuthLoggedOut());
    }
  }

  // ==================== Check Auth Status ====================
  
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      print('🔍 Checking auth status');
      final user = await _repo.getCurrentUser();
      if (user != null) {
        print('✅ User is logged in: ${user.fullName}');
        emit(AuthSuccess(user));
      } else {
        print('❌ No user logged in');
        emit(AuthInitial());
      }
    } catch (e) {
      print('⚠️ Auth check error: $e');
      emit(AuthInitial());
    }
  }

  // ==================== Change Password ====================
  
  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(AuthLoading());
    try {
      print('🔑 Changing password');
      await _repo.changePassword(oldPassword, newPassword);
      print('✅ Password changed successfully');
      emit(PasswordChanged());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError("Failed to change password: ${e.toString()}"));
    }
  }
}
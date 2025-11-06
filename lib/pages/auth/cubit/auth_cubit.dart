// lib/pages/auth/cubit/auth_cubit.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          emit(UserExistsWithoutPin(mobile, result.user! as User));
          break;
        case UserExistsStatus.doesNotExist:
          emit(UserDoesNotExist(mobile));
          break;
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 2a: Login with PIN (for existing users with PIN)
  Future<void> loginWithPin(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(mobile, pin);
      emit(AuthSuccess(user as User));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 2b: Send OTP (for users without PIN or new users)
  Future<void> sendOtp(String mobile, {bool isNewUser = false}) async {
    emit(AuthLoading());
    try {
      await _repo.sendOtp(mobile);
      emit(OtpSent(mobile, isNewUser: isNewUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 3: Verify OTP
  Future<void> verifyOtp(String mobile, String otp, {bool isNewUser = false}) async {
    emit(AuthLoading());
    try {
      final isValid = await _repo.verifyOtp(mobile, otp);
      
      if (isValid) {
        // OTP verified - now user needs to set PIN or register
        emit(OtpVerified(mobile, needsPin: !isNewUser, isNewUser: isNewUser));
      } else {
        emit(AuthError("Invalid OTP"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 4a: Set PIN for existing user (after OTP verification)
  Future<void> setPin(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      final user = await _repo.setPin(mobile, pin);
      emit(AuthSuccess(user as User));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 4b: Register new user (after OTP verification)
  Future<void> register(Map<String, dynamic> userData) async {
    emit(AuthLoading());
    try {
      final user = await _repo.register(userData);
      emit(AuthSuccess(user as User));
    } catch (e) {
      emit(AuthError(e.toString()));
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
        emit(AuthSuccess(user as User));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }
}
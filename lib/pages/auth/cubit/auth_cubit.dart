import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/services/device_service.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';
import 'package:mmsn/pages/auth/services/firebase_services.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthInitial());

  final AuthRepository _repo;
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService.instance;
  
  String? _currentVerificationId;
  String? _currentPhoneNumber;

  // ==================== Check User (Simplified) ====================
  Future<void> checkUser(String mobile) async {
    emit(AuthLoading());

    try {
      print('🔍 Checking user: $mobile');
      final result = await _repo.checkUser(mobile);

      switch (result.status) {
        case UserExistsStatus.existsWithPinVerified:
        case UserExistsStatus.existsWithPinNotVerified:
        case UserExistsStatus.existsWithoutPin:
          // Existing user -> directly call backend login (no OTP)
          print('✅ User exists - logging in with mobile');
          final user = await _repo.loginWithMobile(mobile);
          emit(AuthSuccess(user));
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
      emit(AuthError('Failed to check user: $e'));
    }
  }

  // ==================== Send Firebase OTP ====================
  Future<void> sendFirebaseOtp(
    String mobile, {
    bool isNewUser = false,
    bool isForPinSetup = false,
    bool isForPhoneVerification = false,
  }) async {
    emit(AuthLoading());
    
    try {
      print('📤 Sending Firebase OTP to: $mobile');
      print('   - isNewUser: $isNewUser');
      
      _currentPhoneNumber = mobile;

      final success = await _firebaseAuth.sendOtp(
        phoneNumber: mobile,
        onCodeSent: (verificationId) {
          print('✅ Firebase OTP sent successfully');
          _currentVerificationId = verificationId;
          emit(OtpSent(
            mobile,
            isNewUser: isNewUser,
            isForPinSetup: false,
            isForPhoneVerification: isForPhoneVerification,
            verificationId: verificationId,
          ));
        },
        onError: (error) {
          print('❌ Firebase OTP error: $error');
          emit(AuthError(error));
        },
        onAutoVerify: (credential) async {
          print('✅ Auto-verification completed');
          await _handleFirebaseAutoVerify(credential, isNewUser);
        },
      );

      if (!success) {
        emit(AuthError('Failed to send OTP. Please try again.'));
      }
    } catch (e) {
      print('❌ Error in sendFirebaseOtp: $e');
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  // ==================== Verify Firebase OTP ====================
  Future<void> verifyFirebaseOtp(
    String mobile,
    String otp, {
    required String verificationId,
    bool isNewUser = false,
  }) async {
    emit(AuthLoading());
    
    try {
      print('🔐 Verifying Firebase OTP for $mobile');
      print('   - isNewUser: $isNewUser');

      final firebaseUser = await _firebaseAuth.verifyOtp(
        otp: otp,
        verificationId: verificationId,
        onError: (error) {
          print('❌ Firebase OTP verification error: $error');
          emit(AuthError(error));
        },
      );

      if (firebaseUser != null) {
        print('✅ Firebase OTP verified successfully');

        // After successful OTP verification (only for new users),
        // perform backend login with mobile + device info.
        final user = await _repo.loginWithMobile(mobile);
        print('✅ User logged in successfully after OTP');
        emit(AuthSuccess(user));
      }
    } catch (e) {
      print('❌ Error in verifyFirebaseOtp: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Handle Firebase Auto-Verify ====================
  Future<void> _handleFirebaseAutoVerify(
    firebase_auth.PhoneAuthCredential credential,
    bool isNewUser,
  ) async {
    try {
      if (_currentPhoneNumber == null) return;

      // If auto-verified for a new user, directly login with mobile.
      final user = await _repo.loginWithMobile(_currentPhoneNumber!);
      print('✅ Auto-verified and logged in');
      emit(AuthSuccess(user));
    } catch (e) {
      print('❌ Auto-verify error: $e');
      emit(AuthError('Auto-verification failed'));
    }
  }

  // ==================== Register ====================
  Future<void> register(Map<String, dynamic> userData) async {
    emit(AuthLoading());
    try {
      print('📝 Registering user: ${userData['mobile']}');

      await _repo.register(userData);

      print('✅ Registration successful, sending Firebase OTP');
      emit(RegistrationSuccess(
        mobile: userData['mobile'] as String,
        pin: '', // No longer needed
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

  // ==================== Resend OTP ====================
  Future<void> resendOtp(
    String mobile, {
    bool isNewUser = false,
  }) async {
    await sendFirebaseOtp(mobile, isNewUser: isNewUser);
  }

  // ==================== Logout ====================
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      print('🚪 Logging out');
      await _repo.logout();
      await _firebaseAuth.signOut();
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
}
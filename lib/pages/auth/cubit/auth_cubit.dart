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

  // ==================== Check User ====================

  Future<void> checkUser(String mobile) async {
    emit(AuthLoading());

    try {
      print('🔍 Checking user: $mobile');
      final result = await _repo.checkUser(mobile);

      switch (result.status) {
        case UserExistsStatus.existsWithPinVerified:
          print('✅ User exists with PIN and phone verified - Direct login');
          emit(UserExistsWithPin(mobile, isPhoneVerified: true));
          break;

        case UserExistsStatus.existsWithPinNotVerified:
          print('⚠️ User exists with PIN but phone not verified - Send OTP first');
          emit(UserExistsWithPin(mobile, isPhoneVerified: false));
          // Send OTP via Firebase for verification
          await sendOtpViaFirebase(mobile, isForPinSetup: false);
          break;

        case UserExistsStatus.existsWithoutPin:
          print('⚠️ User exists without PIN - Need to set PIN');
          emit(UserExistsWithoutPin(mobile, result.user!));
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

  // ==================== Send OTP via Firebase ====================

  Future<void> sendOtpViaFirebase(
    String mobile, {
    bool isNewUser = false,
    bool isForPinSetup = false,
  }) async {
    emit(AuthLoading());
    
    try {
      print('📤 Sending OTP via Firebase to: $mobile');
      print('   - isNewUser: $isNewUser');
      print('   - isForPinSetup: $isForPinSetup');
      
      _currentPhoneNumber = mobile;

      final success = await _firebaseAuth.sendOtp(
        phoneNumber: mobile,
        onCodeSent: (verificationId) {
          print('✅ Firebase OTP sent successfully');
          _currentVerificationId = verificationId;
          emit(OtpSent(
            mobile,
            isNewUser: isNewUser,
            isForPinSetup: isForPinSetup,
            verificationId: verificationId,
          ));
        },
        onError: (error) {
          print('❌ Firebase OTP error: $error');
          emit(AuthError(error));
        },
        onAutoVerify: (credential) async {
          print('✅ Auto-verification completed (Android only)');
          // Handle auto-verification
          await _handleFirebaseAutoVerify(credential, isNewUser, isForPinSetup);
        },
      );

      if (!success) {
        emit(AuthError('Failed to send OTP. Please try again.'));
      }
    } catch (e) {
      print('❌ Error in sendOtpViaFirebase: $e');
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  // ==================== Verify OTP via Firebase ====================

  Future<void> verifyOtpViaFirebase(
    String mobile,
    String otp, {
    required String verificationId,
    bool isNewUser = false,
    bool isForPinSetup = false,
  }) async {
    emit(AuthLoading());
    
    try {
      print('🔐 Verifying OTP via Firebase for $mobile');
      print('   - isNewUser: $isNewUser');
      print('   - isForPinSetup: $isForPinSetup');

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
        print('👤 Firebase UID: ${firebaseUser.uid}');
        
        // Get Firebase ID Token to send to backend
        final idToken = await _firebaseAuth.getIdToken();
        
        if (idToken != null) {
          print('🎫 Firebase ID Token obtained');
          
          // Send ID token to your backend for verification
          // Your backend will verify this token using Firebase Admin SDK
          await _verifyWithBackend(idToken, mobile, isNewUser, isForPinSetup);
        } else {
          emit(AuthError('Failed to get authentication token'));
        }
      }
    } catch (e) {
      print('❌ Error in verifyOtpViaFirebase: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Verify with Backend ====================

  Future<void> _verifyWithBackend(
    String firebaseIdToken,
    String mobile,
    bool isNewUser,
    bool isForPinSetup,
  ) async {
    try {
      print('🔄 Sending Firebase token to backend for verification');
      
      // Call your backend endpoint to verify Firebase token
      // Your backend should:
      // 1. Verify the Firebase ID token using Firebase Admin SDK
      // 2. Extract phone number from verified token
      // 3. Update user's phone verification status in your database
      
      // For now, we'll emit OtpVerified state
      // You'll need to call your backend API here
      
      print('✅ Backend verification completed');
      
      if (isNewUser) {
        emit(OtpVerified(
          mobile,
          needsPin: false,
          isNewUser: true,
        ));
      } else if (isForPinSetup) {
        emit(OtpVerified(
          mobile,
          needsPin: true,
          isNewUser: false,
        ));
      } else {
        emit(OtpVerified(
          mobile,
          needsPin: false,
          isNewUser: false,
        ));
      }
    } catch (e) {
      print('❌ Backend verification error: $e');
      emit(AuthError('Backend verification failed: ${e.toString()}'));
    }
  }

  // ==================== Handle Firebase Auto-Verify ====================

  Future<void> _handleFirebaseAutoVerify(
    firebase_auth.PhoneAuthCredential credential,
    bool isNewUser,
    bool isForPinSetup,
  ) async {
    try {
      final idToken = await _firebaseAuth.getIdToken();
      if (idToken != null && _currentPhoneNumber != null) {
        await _verifyWithBackend(
          idToken,
          _currentPhoneNumber!,
          isNewUser,
          isForPinSetup,
        );
      }
    } catch (e) {
      print('❌ Auto-verify error: $e');
      emit(AuthError('Auto-verification failed'));
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

  // ==================== Set PIN ====================

  Future<void> setPin(String mobile, String pin) async {
    emit(AuthLoading());
    try {
      print('🔒 Setting PIN for: $mobile');
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

  // ==================== Resend OTP ====================

  Future<void> resendOtp(String mobile, {
    bool isNewUser = false,
    bool isForPinSetup = false,
  }) async {
    await sendOtpViaFirebase(
      mobile,
      isNewUser: isNewUser,
      isForPinSetup: isForPinSetup,
    );
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

  // ==================== Change Password ====================

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(AuthLoading());
    try {
      print('🔐 Changing password');
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
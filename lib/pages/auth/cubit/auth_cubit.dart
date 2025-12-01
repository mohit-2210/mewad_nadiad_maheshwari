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
  String? _firebaseIdToken;

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
          print('⚠️ User exists with PIN but phone not verified - Send Firebase OTP');
          emit(UserExistsWithPin(mobile, isPhoneVerified: false));
          // Send Firebase OTP to verify phone
          await sendFirebaseOtp(mobile, isForPhoneVerification: true);
          break;

        case UserExistsStatus.existsWithoutPin:
          print('⚠️ User exists without PIN - Need Firebase OTP then set PIN');
          emit(UserExistsWithoutPin(mobile, result.user!));
          // Send Firebase OTP for PIN setup flow
          await sendFirebaseOtp(mobile, isForPinSetup: true);
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
      print('   - isForPinSetup: $isForPinSetup');
      print('   - isForPhoneVerification: $isForPhoneVerification');
      
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
            isForPhoneVerification: isForPhoneVerification,
            verificationId: verificationId,
          ));
        },
        onError: (error) {
          print('❌ Firebase OTP error: $error');
          emit(AuthError(error));
        },
        onAutoVerify: (credential) async {
          print('✅ Auto-verification completed (Android only)');
          await _handleFirebaseAutoVerify(
            credential,
            isNewUser,
            isForPinSetup,
            isForPhoneVerification,
          );
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
    bool isForPinSetup = false,
    bool isForPhoneVerification = false,
  }) async {
    emit(AuthLoading());
    
    try {
      print('🔐 Verifying Firebase OTP for $mobile');
      print('   - isNewUser: $isNewUser');
      print('   - isForPinSetup: $isForPinSetup');
      print('   - isForPhoneVerification: $isForPhoneVerification');

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
        
        // Get Firebase ID Token
        final idToken = await _firebaseAuth.getIdToken();
        
        if (idToken != null) {
          print('🎫 Firebase ID Token obtained');
          _firebaseIdToken = idToken;
          
          // Handle different flows based on user type
          if (isNewUser) {
            await _handleNewUserVerification(mobile, idToken);
          } else if (isForPinSetup) {
            await _handlePinSetupVerification(mobile, idToken);
          } else if (isForPhoneVerification) {
            await _handlePhoneVerification(mobile, idToken);
          } else {
            emit(AuthError('Invalid verification flow'));
          }
        } else {
          emit(AuthError('Failed to get authentication token'));
        }
      }
    } catch (e) {
      print('❌ Error in verifyFirebaseOtp: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Handle New User Verification ====================
  Future<void> _handleNewUserVerification(String mobile, String firebaseIdToken) async {
    try {
      print('🆕 Handling new user verification');
      
      // Send Firebase ID token to backend for verification
      await _repo.sendFirebaseTokenToBackend(
        mobile: mobile,
        firebaseIdToken: firebaseIdToken,
        tokenType: 'OTP_VERIFICATION_TOKEN',
      );
      
      print('✅ New user phone verified via backend');
      emit(OtpVerified(
        mobile,
        needsPin: false,
        isNewUser: true,
      ));
    } catch (e) {
      print('❌ New user verification error: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Handle PIN Setup Verification ====================
  Future<void> _handlePinSetupVerification(String mobile, String firebaseIdToken) async {
    try {
      print('🔧 Handling PIN setup verification');
      
      // Send Firebase ID token to backend with PASSWORD_RESET_TOKEN type
      final tokens = await _repo.sendFirebaseTokenToBackend(
        mobile: mobile,
        firebaseIdToken: firebaseIdToken,
        tokenType: 'PASSWORD_RESET_TOKEN',
      );
      
      print('✅ Phone verified, ready for PIN setup');
      emit(OtpVerified(
        mobile,
        needsPin: true,
        isNewUser: false,
      ));
    } catch (e) {
      print('❌ PIN setup verification error: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Handle Phone Verification (Existing User with PIN) ====================
  Future<void> _handlePhoneVerification(String mobile, String firebaseIdToken) async {
    try {
      print('📱 Handling phone verification for existing user');
      
      // Send Firebase ID token to backend for phone verification
      await _repo.sendFirebaseTokenToBackend(
        mobile: mobile,
        firebaseIdToken: firebaseIdToken,
        tokenType: 'OTP_VERIFICATION_TOKEN',
      );
      
      print('✅ Phone verified, user can now login with PIN');
      emit(OtpVerified(
        mobile,
        needsPin: false,
        isNewUser: false,
      ));
    } catch (e) {
      print('❌ Phone verification error: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Handle Firebase Auto-Verify ====================
  Future<void> _handleFirebaseAutoVerify(
    firebase_auth.PhoneAuthCredential credential,
    bool isNewUser,
    bool isForPinSetup,
    bool isForPhoneVerification,
  ) async {
    try {
      final idToken = await _firebaseAuth.getIdToken();
      if (idToken != null && _currentPhoneNumber != null) {
        if (isNewUser) {
          await _handleNewUserVerification(_currentPhoneNumber!, idToken);
        } else if (isForPinSetup) {
          await _handlePinSetupVerification(_currentPhoneNumber!, idToken);
        } else if (isForPhoneVerification) {
          await _handlePhoneVerification(_currentPhoneNumber!, idToken);
        }
      }
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

  // ==================== Resend OTP ====================
  Future<void> resendOtp(
    String mobile, {
    bool isNewUser = false,
    bool isForPinSetup = false,
    bool isForPhoneVerification = false,
  }) async {
    await sendFirebaseOtp(
      mobile,
      isNewUser: isNewUser,
      isForPinSetup: isForPinSetup,
      isForPhoneVerification: isForPhoneVerification,
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
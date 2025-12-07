import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';
import 'package:mmsn/pages/auth/services/firebase_services.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthInitial());

  final AuthRepository _repo;
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService.instance;

  String? _currentVerificationId;
  String? _currentPhoneNumber;
  bool _tokensRetrieved = false; // Track if we have tokens

  // ==================== Check User (Updated) ====================
  Future<void> checkUser(String mobile) async {
    emit(AuthLoading());

    try {
      print('🔍 Checking user: $mobile');
      final result = await _repo.checkUser(mobile);

      switch (result.status) {
        case UserExistsStatus.existsWithPinVerified:
        case UserExistsStatus.existsWithPinNotVerified:
        case UserExistsStatus.existsWithoutPin:
          // Existing user -> Call login to get tokens first
          print('✅ User exists - Getting auth tokens');

          // Call login API to get and store tokens
          await _loginAndGetTokens(mobile);

          // Now send Firebase OTP for verification
          print('📤 Sending Firebase OTP for verification');
          await sendFirebaseOtp(
            mobile,
            isNewUser: false,
            isForPhoneVerification: true,
          );
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

  // ==================== Login and Get Tokens (New Method) ====================
  Future<void> _loginAndGetTokens(String mobile) async {
    try {
      print('🔐 Logging in to retrieve tokens');

      final user = await _repo.loginWithMobile(mobile);

      // Verify tokens were saved
      final accessToken = await AuthLocalStorage.getAccessToken();
      final refreshToken = await AuthLocalStorage.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        throw AuthenticationException(
            'Failed to retrieve authentication tokens');
      }

      _tokensRetrieved = true;
      print('✅ Tokens retrieved and stored successfully');
      print('   - Access Token: ${accessToken.substring(0, 20)}...');
      print('   - Refresh Token: ${refreshToken.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error getting tokens: $e');
      throw AuthenticationException('Failed to authenticate: ${e.toString()}');
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
          await _handleFirebaseAutoVerify(
              credential, isNewUser, isForPhoneVerification);
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

  // ==================== Verify Firebase OTP (Updated) ====================
  Future<void> verifyFirebaseOtp(
    String mobile,
    String otp, {
    required String verificationId,
    bool isNewUser = false,
    bool isForPhoneVerification = false,
  }) async {
    emit(AuthLoading());

    try {
      print('🔐 Verifying Firebase OTP for $mobile');
      print('   - isNewUser: $isNewUser');
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

        // Get Firebase ID token
        final idToken = await _firebaseAuth.getIdToken();
        if (idToken == null) {
          throw AuthenticationException('Failed to get Firebase ID token');
        }

        if (isForPhoneVerification && _tokensRetrieved) {
          // Existing user verification - update verification status
          print('📝 Updating phone verification status');
          await _updatePhoneVerificationStatus(mobile, idToken);

          // Now login to get updated user data
          final user = await _repo.loginWithMobile(mobile);
          print('✅ User logged in with updated verification status');
          emit(AuthSuccess(user));
        } else if (isNewUser) {
          // New user - perform backend login
          print('🆕 New user - performing backend login');
          final user = await _repo.loginWithMobile(mobile);
          print('✅ New user logged in successfully');
          emit(AuthSuccess(user));
        } else {
          // Regular login flow
          final user = await _repo.loginWithMobile(mobile);
          print('✅ User logged in successfully');
          emit(AuthSuccess(user));
        }
      }
    } catch (e) {
      print('❌ Error in verifyFirebaseOtp: $e');
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ==================== Update Phone Verification Status (New Method) ====================
  Future<void> _updatePhoneVerificationStatus(
      String mobile, String firebaseIdToken) async {
    try {
      print('🔄 Calling backend to update phone verification');

      // Send Firebase token to backend to update verification status
      await _repo.sendFirebaseTokenToBackend(
        mobile: mobile,
        firebaseIdToken: firebaseIdToken,
        tokenType: 'OTP_VERIFICATION_TOKEN',
      );

      print('✅ Phone verification status updated on backend');
    } catch (e) {
      print('⚠️ Error updating verification status: $e');
      // Don't throw - allow login to continue even if verification update fails
    }
  }

  // ==================== Handle Firebase Auto-Verify (Updated) ====================
  Future<void> _handleFirebaseAutoVerify(
    firebase_auth.PhoneAuthCredential credential,
    bool isNewUser,
    bool isForPhoneVerification,
  ) async {
    try {
      if (_currentPhoneNumber == null) return;

      // Get Firebase ID token from credential
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw AuthenticationException('Failed to get Firebase ID token');
      }

      if (isForPhoneVerification && _tokensRetrieved) {
        // Update verification status
        await _updatePhoneVerificationStatus(_currentPhoneNumber!, idToken);
      }

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
        pin: '',
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
    bool isForPhoneVerification = false,
  }) async {
    await sendFirebaseOtp(
      mobile,
      isNewUser: isNewUser,
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
      _tokensRetrieved = false;
      print('✅ Logged out successfully');
      emit(AuthLoggedOut());
    } catch (e) {
      print('⚠️ Logout error (clearing local data anyway): $e');
      _tokensRetrieved = false;
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
        final hasTokens = await AuthLocalStorage.hasAuthTokens();
        if (hasTokens) {
          _tokensRetrieved = true;
          print('✅ User is logged in: ${user.fullName}');
          emit(AuthSuccess(user));
        } else {
          print('⚠️ User data exists but no tokens found');
          emit(AuthInitial());
        }
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

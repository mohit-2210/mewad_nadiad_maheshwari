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
  bool _tokensRetrieved = false;
  String? _currentUserId; // Store user ID for verification update

  // ==================== Check User ====================
  Future<void> checkUser(String mobile) async {
    emit(AuthLoading());

    try {
      print('🔍 Checking user: $mobile');
      final result = await _repo.checkUser(mobile);
      final user = result.user;

      switch (result.status) {
        case UserExistsStatus.existsWithPinVerified:
        case UserExistsStatus.existsWithPinNotVerified:
        case UserExistsStatus.existsWithoutPin:

          // 🔥 NEW LOGIC: If mobile is already verified → skip OTP
          if (user?.mobileVerification == "ACCEPTED") {
            print('🎉 User already verified → Direct login WITHOUT OTP');

            final loggedInUser = await _repo.loginWithMobile(mobile);

            emit(AuthSuccess(loggedInUser));
            return;
          }
          // Step 1: Call login API in background to get and store tokens
          print('✅ User exists - Getting tokens via login API');
          await _loginAndGetTokens(mobile);

          // Step 2: Send Firebase OTP for verification
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

  // ==================== Login and Get Tokens (Background) ====================
  Future<void> _loginAndGetTokens(String mobile) async {
    try {
      print('🔐 Step 1: Calling login API to get tokens');

      // Call login API - this saves tokens automatically
      final user = await _repo.loginWithMobile(mobile);

      // Store user ID for later verification update
      _currentUserId = user.id;

      // Verify tokens were saved
      final accessToken = await AuthLocalStorage.getAccessToken();
      final refreshToken = await AuthLocalStorage.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        throw AuthenticationException(
            'Failed to retrieve authentication tokens');
      }

      _tokensRetrieved = true;
      print('✅ Step 1 Complete: Tokens saved');
      print('   - User ID: $_currentUserId');
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
      print('📤 Step 2: Sending Firebase OTP to: $mobile');
      print('   - isNewUser: $isNewUser');
      print('   - isForPhoneVerification: $isForPhoneVerification');

      _currentPhoneNumber = mobile;

      final success = await _firebaseAuth.sendOtp(
        phoneNumber: mobile,
        onCodeSent: (verificationId) {
          print('✅ Step 2 Complete: Firebase OTP sent');
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

  // ==================== Verify Firebase OTP ====================
  Future<void> verifyFirebaseOtp(
    String mobile,
    String otp, {
    required String verificationId,
    bool isNewUser = false,
    bool isForPhoneVerification = false,
  }) async {
    emit(AuthLoading());

    try {
      print('🔐 Step 3: Verifying Firebase OTP for $mobile');
      print('   - isNewUser: $isNewUser');
      print('   - isForPhoneVerification: $isForPhoneVerification');

      // Verify OTP with Firebase
      final firebaseUser = await _firebaseAuth.verifyOtp(
        otp: otp,
        verificationId: verificationId,
        onError: (error) {
          print('❌ Firebase OTP verification error: $error');
          emit(AuthError(error));
        },
      );

      if (firebaseUser != null) {
        print('✅ Step 3 Complete: Firebase OTP verified');

        // Get Firebase ID token
        final idToken = await _firebaseAuth.getIdToken();
        if (idToken == null) {
          throw AuthenticationException('Failed to get Firebase ID token');
        }

        if (isForPhoneVerification && _tokensRetrieved) {
          // EXISTING USER FLOW
          print('👤 Existing user flow');

          if (_currentUserId == null) {
            throw AuthenticationException('User ID not found');
          }

          // Step 4: Update verification status to ACCEPTED using user update endpoint
          print('📝 Step 4: Updating verification status to ACCEPTED');
          print('   - User ID: $_currentUserId');
          try {
            await _repo.updateMobileVerificationStatus(_currentUserId!);
            print('✅ Step 4 Complete: Verification status updated to ACCEPTED');
          } catch (e) {
            print('⚠️ Error updating verification status: $e');
            emit(AuthError('Failed to update verification status'));
            return;
          }

          // Step 5: Call login API again to get updated user with verified fields
          print('🔐 Step 5: Calling login API to get updated user');
          final user = await _repo.loginWithMobile(mobile);

          print('✅ Step 5 Complete: User logged in with updated data');
          print('   - Mobile Verification: ${user.mobileVerification}');
          print('   - Email Verification: ${user.emailVerification}');
          print('');
          print('🎉 FLOW COMPLETE: Navigating to home');

          emit(AuthSuccess(user));
        } else if (isNewUser) {
          // NEW USER FLOW
          print('🆕 New user flow');

          // For new user, first login to get user ID
          print('🔐 Getting user ID for new user');
          final tempUser = await _repo.loginWithMobile(mobile);
          _currentUserId = tempUser.id;

          // Step 4: Update verification status to ACCEPTED
          print('📝 Step 4: Updating verification status for new user');
          print('   - User ID: $_currentUserId');
          try {
            await _repo.updateMobileVerificationStatus(_currentUserId!);
            print(
                '✅ Step 4 Complete: New user verification updated to ACCEPTED');
          } catch (e) {
            print('⚠️ Error updating new user verification: $e');
            emit(AuthError('Failed to update verification status'));
            return;
          }

          // Step 5: Call login API again to get updated user
          print('🔐 Step 5: Logging in new user with updated status');
          final user = await _repo.loginWithMobile(mobile);

          print('✅ Step 5 Complete: New user logged in');
          print('   - Mobile Verification: ${user.mobileVerification}');
          print('');
          print('🎉 FLOW COMPLETE: Navigating to home');

          emit(AuthSuccess(user));
        } else {
          // Regular login flow (shouldn't hit this case)
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

  // ==================== Handle Firebase Auto-Verify ====================
  Future<void> _handleFirebaseAutoVerify(
    firebase_auth.PhoneAuthCredential credential,
    bool isNewUser,
    bool isForPhoneVerification,
  ) async {
    try {
      if (_currentPhoneNumber == null) return;

      print('🤖 Auto-verification flow started');

      // Get Firebase ID token from credential
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw AuthenticationException('Failed to get Firebase ID token');
      }

      // Step 4: Update verification status
      if (isForPhoneVerification || isNewUser) {
        if (_currentUserId == null) {
          // For new user, get user ID first
          final tempUser = await _repo.loginWithMobile(_currentPhoneNumber!);
          _currentUserId = tempUser.id;
        }

        print('📝 Step 4 (Auto): Updating verification status');
        print('   - User ID: $_currentUserId');
        try {
          await _repo.updateMobileVerificationStatus(_currentUserId!);
          print('✅ Step 4 Complete (Auto): Verification updated to ACCEPTED');
        } catch (e) {
          print('⚠️ Auto-verify: Error updating verification: $e');
          emit(AuthError('Failed to update verification status'));
          return;
        }
      }

      // Step 5: Login to get updated user
      print('🔐 Step 5 (Auto): Logging in with updated data');
      final user = await _repo.loginWithMobile(_currentPhoneNumber!);

      print('✅ Step 5 Complete (Auto): User logged in');
      print('   - Mobile Verification: ${user.mobileVerification}');
      print('');
      print('🎉 AUTO-VERIFY FLOW COMPLETE: Navigating to home');

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

      print('✅ Registration successful, will send Firebase OTP');
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
      _currentUserId = null;
      print('✅ Logged out successfully');
      emit(AuthLoggedOut());
    } catch (e) {
      print('⚠️ Logout error (clearing local data anyway): $e');
      _tokensRetrieved = false;
      _currentUserId = null;
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
          _currentUserId = user.id;
          print('✅ User is logged in: ${user.fullName}');
          print('   - Mobile Verification: ${user.mobileVerification}');
          print('   - Email Verification: ${user.emailVerification}');
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

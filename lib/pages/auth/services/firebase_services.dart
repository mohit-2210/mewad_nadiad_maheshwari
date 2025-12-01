import 'package:firebase_auth/firebase_auth.dart';

/// Complete Firebase Phone Authentication Service
/// Handles OTP sending and verification on client side
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Singleton pattern
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  static FirebaseAuthService get instance => _instance;
  FirebaseAuthService._internal();

  String? _verificationId;
  int? _resendToken;

  /// Send OTP to phone number
  /// Returns true if OTP sent successfully, false otherwise
  Future<bool> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    try {
      // Ensure phone number has country code
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Default to India
      }

      print('📤 Sending OTP to: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        
        // Auto-verification (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verification completed');
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          }
        },
        
        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.code} - ${e.message}');
          String errorMessage = _getErrorMessage(e);
          onError(errorMessage);
        },
        
        // OTP sent successfully
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP sent successfully');
          print('📝 Verification ID: ${verificationId.substring(0, 20)}...');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto-retrieval timeout');
          _verificationId = verificationId;
        },
        
        // For resending OTP
        forceResendingToken: _resendToken,
      );

      return true;
    } catch (e) {
      print('❌ Error sending OTP: $e');
      onError('Failed to send OTP: ${e.toString()}');
      return false;
    }
  }

  /// Verify OTP code
  /// Returns Firebase User if successful, null otherwise
  Future<User?> verifyOtp({
    required String otp,
    required String verificationId,
    required Function(String error) onError,
  }) async {
    try {
      print('🔐 Verifying OTP: $otp');
      
      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        print('✅ OTP verified successfully');
        print('👤 User UID: ${userCredential.user!.uid}');
        return userCredential.user;
      } else {
        onError('Verification failed. Please try again.');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e);
      onError(errorMessage);
      return null;
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      onError('Verification failed: ${e.toString()}');
      return null;
    }
  }

  /// Get Firebase ID Token for backend verification
  /// This is what you'll send to your Node.js backend
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return null;
      }
      
      final idToken = await user.getIdToken();
      print('🎫 Firebase ID Token obtained: ${idToken?.substring(0, 20)}...');
      return idToken;
    } catch (e) {
      print('❌ Error getting ID token: $e');
      return null;
    }
  }

  /// Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign out from Firebase
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _verificationId = null;
      _resendToken = null;
      print('✅ Signed out from Firebase');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request new OTP';
      case 'session-expired':
        return 'OTP expired. Please request a new code';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'app-not-authorized':
        return 'App not authorized. Please check Firebase configuration';
      case 'missing-phone-number':
        return 'Please provide a phone number';
      default:
        return e.message ?? 'Authentication failed. Please try again';
    }
  }

  /// Resend OTP (uses the resend token)
  Future<bool> resendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    print('🔄 Resending OTP...');
    return await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  /// For testing: Get stored verification ID
  String? get verificationId => _verificationId;
}
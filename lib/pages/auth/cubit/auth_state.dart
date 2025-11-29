import 'package:equatable/equatable.dart';
import 'package:mmsn/models/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial
class AuthInitial extends AuthState {}

// Loading
class AuthLoading extends AuthState {}

// Error
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// User Check States
class UserExistsWithPin extends AuthState {
  final String mobile;
  final bool isPhoneVerified;
  UserExistsWithPin(this.mobile, {required this.isPhoneVerified});

  @override
  List<Object?> get props => [mobile, isPhoneVerified];
}

class UserExistsWithoutPin extends AuthState {
  final String mobile;
  final User user;
  UserExistsWithoutPin(this.mobile, this.user);

  @override
  List<Object?> get props => [mobile, user];
}

class UserDoesNotExist extends AuthState {
  final String mobile;
  UserDoesNotExist(this.mobile);

  @override
  List<Object?> get props => [mobile];
}

// OTP States
class OtpSent extends AuthState {
  final String mobile;
  final bool isNewUser;
  final bool isForPinSetup; // True when user exists but needs PIN
  OtpSent(
    this.mobile, {
    this.isNewUser = false,
    this.isForPinSetup = false,
  });

  @override
  List<Object?> get props => [mobile, isNewUser, isForPinSetup];
}

class OtpVerified extends AuthState {
  final String mobile;
  final bool needsPin;
  final bool isNewUser;
  OtpVerified(
    this.mobile, {
    this.needsPin = false,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [mobile, needsPin, isNewUser];
}

// Registration State - User created successfully, now needs OTP verification
class RegistrationSuccess extends AuthState {
  final String mobile;
  final String pin;
  
  RegistrationSuccess({
    required this.mobile,
    required this.pin,
  });

  @override
  List<Object?> get props => [mobile, pin];
}

// Success States
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// Logged Out
class AuthLoggedOut extends AuthState {}

// Change Password
class PasswordChanged extends AuthState {}
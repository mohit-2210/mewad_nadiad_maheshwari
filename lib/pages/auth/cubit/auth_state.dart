// lib/pages/auth/cubit/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial State
class AuthInitial extends AuthState {}

// Loading State
class AuthLoading extends AuthState {}

// Error State
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// User Check States
class UserExistsWithPin extends AuthState {
  final String mobile;
  UserExistsWithPin(this.mobile);

  @override
  List<Object?> get props => [mobile];
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
  OtpSent(this.mobile, {this.isNewUser = false});

  @override
  List<Object?> get props => [mobile, isNewUser];
}

class OtpVerified extends AuthState {
  final String mobile;
  final bool needsPin;
  final bool isNewUser;
  OtpVerified(this.mobile, {this.needsPin = false, this.isNewUser = false});

  @override
  List<Object?> get props => [mobile, needsPin, isNewUser];
}

// Success State
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// Logged Out
class AuthLoggedOut extends AuthState {}
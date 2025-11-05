import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// ✅ Initial State
class AuthInitial extends AuthState {}

/// ✅ Loading (Login / OTP)
class AuthLoading extends AuthState {}

/// ✅ Error State
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// ✅ OTP Sent successfully
class OtpSentState extends AuthState {
  final String phone;
  final String verificationId;

  OtpSentState(this.phone, this.verificationId);

  @override
  List<Object?> get props => [phone, verificationId];
}

/// ✅ OTP Verified + Backend login success
class AuthSuccess extends AuthState {}

/// ✅ Logged out (for future logout flow)
class AuthLoggedOut extends AuthState {}

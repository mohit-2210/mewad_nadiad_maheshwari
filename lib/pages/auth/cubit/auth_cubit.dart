import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthInitial());

  final AuthRepository _repo;

  Future<void> loginWithPhone(String phone, String pin) async {
    emit(AuthLoading());
    try {
      final loginResponse = await _repo.login(phone, pin);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        verificationCompleted: (cred) async {},
        verificationFailed: (e) => emit(AuthError(e.message ?? "OTP failed")),
        codeSent: (id, _) => emit(OtpSentState(phone, id)),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String code, String verificationId) async {
    emit(AuthLoading());
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _repo.completeLogin(); 
        emit(AuthSuccess());
      }
    } catch (e) {
      emit(AuthError("Invalid OTP"));
    }
  }
}

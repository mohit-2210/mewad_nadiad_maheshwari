// lib/pages/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:mmsn/app/globals/app_strings.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';
import 'package:mmsn/pages/auth/pin_setup_screen.dart';
import 'package:mmsn/pages/auth/register_screen.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isNewUser;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isNewUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: OTPVerificationView(
        phoneNumber: phoneNumber,
        isNewUser: isNewUser,
      ),
    );
  }
}

class OTPVerificationView extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;

  const OTPVerificationView({
    super.key,
    required this.phoneNumber,
    required this.isNewUser,
  });

  @override
  State<OTPVerificationView> createState() => _OTPVerificationViewState();
}

class _OTPVerificationViewState extends State<OTPVerificationView> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOTP() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifyOtp(
          widget.phoneNumber,
          otp,
          isNewUser: widget.isNewUser,
        );
  }

  void _resendOTP() {
    context.read<AuthCubit>().sendOtp(
          widget.phoneNumber,
          isNewUser: widget.isNewUser,
        );
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyOTP),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            // Clear OTP fields on error
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          } else if (state is OtpVerified) {
            if (state.isNewUser) {
              // Navigate to registration screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
            } else if (state.needsPin) {
              // Navigate to PIN setup screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PinSetupScreen(
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
            }
          } else if (state is OtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final isResending = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap.s32H(),
                    Icon(
                      Icons.message,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Gap.s24H(),
                    Text(
                      AppStrings.verifyPhone,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Gap.s8H(),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        children: [
                          const TextSpan(text: AppStrings.enter6DigitCode),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Gap.s48H(),
                    
                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          height: 55,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              
                              if (index == 5 && value.isNotEmpty) {
                                final otp = _controllers.map((c) => c.text).join();
                                if (otp.length == 6) {
                                  _verifyOTP();
                                }
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    Gap.s32H(),
                    
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                AppStrings.verifyOTP,
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    Gap.s24H(),
                    
                    // Resend OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(AppStrings.didntReciveCode),
                        if (_resendTimer > 0)
                          Text(
                            ' Resend in $_resendTimer s',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        else
                          TextButton(
                            onPressed: isResending ? null : _resendOTP,
                            child: const Text(AppStrings.resend),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
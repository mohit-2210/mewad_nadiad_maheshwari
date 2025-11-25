import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:mmsn/app/globals/app_strings.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';
import 'package:mmsn/pages/auth/pin_setup_screen.dart';
import 'package:mmsn/pages/home/main_screen.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isNewUser;
  final String? userPin;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isNewUser = false,
    this.userPin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: OTPVerificationView(
        phoneNumber: phoneNumber,
        isNewUser: isNewUser,
        userPin: userPin,
      ),
    );
  }
}

class OTPVerificationView extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;
  final String? userPin;

  const OTPVerificationView({
    super.key,
    required this.phoneNumber,
    required this.isNewUser,
    this.userPin,
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
      _showSnackBar('Please enter complete OTP', isError: true);
      return;
    }

    print('🔐 Verifying OTP: $otp for ${widget.phoneNumber}');
    print('📱 Is new user: ${widget.isNewUser}');
    print('🔑 User PIN available: ${widget.userPin != null}');

    context.read<AuthCubit>().verifyOtp(
          widget.phoneNumber,
          otp,
          isNewUser: widget.isNewUser,
        );
  }

  void _resendOTP() {
    print('📤 Resending OTP to ${widget.phoneNumber}');
    context.read<AuthCubit>().sendOtp(
          widget.phoneNumber,
          isNewUser: widget.isNewUser,
        );
    _startResendTimer();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  void _clearOTPFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
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
          print('🔄 OTP Screen State: ${state.runtimeType}');

          if (state is AuthError) {
            _showSnackBar(state.message, isError: true);
            _clearOTPFields();
          } else if (state is OtpVerified) {
            print('✅ OTP Verified - isNewUser: ${state.isNewUser}, needsPin: ${state.needsPin}');

            if (state.isNewUser) {
              // New user - auto-login with PIN from registration
              if (widget.userPin != null && widget.userPin!.isNotEmpty) {
                _showSnackBar('OTP verified! Logging you in...');
                context.read<AuthCubit>().loginAfterRegistration(
                      widget.phoneNumber,
                      widget.userPin!,
                    );
              } else {
                _showSnackBar('Registration error: PIN not found', isError: true);
              }
            } else if (state.needsPin) {
              // Existing user without PIN - navigate to PIN setup
              _showSnackBar('OTP verified! Please set your PIN');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PinSetupScreen(
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
            }
          } else if (state is AuthSuccess) {
            print('✅ Auth Success - Navigating to home');
            _showSnackBar('Login successful!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          } else if (state is OtpSent) {
            _showSnackBar('OTP sent successfully');
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

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
                            enabled: !isLoading,
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
                              fillColor: isLoading ? Colors.grey[200] : Colors.grey[50],
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              // Auto-verify when all 6 digits are entered
                              if (index == 5 && value.isNotEmpty) {
                                final otp = _controllers.map((c) => c.text).join();
                                if (otp.length == 6 && !isLoading) {
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
                            onPressed: isLoading ? null : _resendOTP,
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
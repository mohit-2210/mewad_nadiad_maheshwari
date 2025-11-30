import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:mmsn/app/globals/app_strings.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/pin_setup_screen.dart';
import 'package:mmsn/pages/home/main_screen.dart';

/// OTP Verification Screen
/// This screen receives the existing AuthCubit via BlocProvider.value
class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;
  final bool isForPinSetup;
  final String? userPin;
  final String? verificationId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isNewUser = false,
    this.isForPinSetup = false,
    this.userPin,
    this.verificationId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendTimer = 30;
  Timer? _timer;
  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();

    // Get verification ID from widget parameter
    _currentVerificationId = widget.verificationId;

    if (_currentVerificationId == null) {
      print('⚠️ Warning: No verification ID provided to OTP screen');
    } else {
      print(
          '✅ OTP screen initialized with verification ID: ${_currentVerificationId!.substring(0, 20)}...');
    }

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

    if (_currentVerificationId == null || _currentVerificationId!.isEmpty) {
      _showSnackBar('Verification session expired. Please resend OTP',
          isError: true);
      return;
    }

    print('🔐 Verifying Firebase OTP: $otp for ${widget.phoneNumber}');
    print('📱 Is new user: ${widget.isNewUser}');
    print('🔧 Is for PIN setup: ${widget.isForPinSetup}');
    print('🔑 User PIN available: ${widget.userPin != null}');
    print(
        '🎫 Using Verification ID: ${_currentVerificationId!.substring(0, 20)}...');

    // Verify via Firebase using existing cubit
    context.read<AuthCubit>().verifyOtpViaFirebase(
          widget.phoneNumber,
          otp,
          verificationId: _currentVerificationId!,
          isNewUser: widget.isNewUser,
          isForPinSetup: widget.isForPinSetup,
        );
  }

  void _resendOTP() {
    print('🔄 Resending OTP to ${widget.phoneNumber}');

    // Clear current OTP fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // Resend OTP via existing cubit
    context.read<AuthCubit>().resendOtp(
          widget.phoneNumber,
          isNewUser: widget.isNewUser,
          isForPinSetup: widget.isForPinSetup,
        );
    _startResendTimer();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

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
          } else if (state is OtpSent) {
            // Update verification ID when new OTP is sent (for resend)
            setState(() {
              _currentVerificationId = state.verificationId;
            });
            print(
                '✅ New verification ID received: ${state.verificationId?.substring(0, 20)}...');
            _showSnackBar('OTP sent successfully');
          } else if (state is OtpVerified) {
            print('✅ OTP Verified:');
            print('   - isNewUser: ${state.isNewUser}');
            print('   - needsPin: ${state.needsPin}');

            if (state.isNewUser) {
              // New user - auto-login with PIN from registration
              if (widget.userPin != null && widget.userPin!.isNotEmpty) {
                _showSnackBar('OTP verified! Logging you in...');
                context.read<AuthCubit>().loginAfterRegistration(
                      widget.phoneNumber,
                      widget.userPin!,
                    );
              } else {
                _showSnackBar('Registration error: PIN not found',
                    isError: true);
              }
            } else if (state.needsPin) {
              // Existing user without PIN - navigate to PIN setup
              _showSnackBar('OTP verified! Please set your PIN');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (newContext) => BlocProvider.value(
                    value: context.read<AuthCubit>(),
                    child: PinSetupScreen(
                      phoneNumber: widget.phoneNumber,
                    ),
                  ),
                ),
              );
            } else {
              // Existing user with PIN, phone verification complete
              _showSnackBar('Phone verified! Please enter your PIN');
              Navigator.pop(context);
            }
          } else if (state is AuthSuccess) {
            print('✅ Auth Success - Navigating to home');
            _showSnackBar('Login successful!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
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
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                    Gap.s16H(),

                    // Firebase indicator
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'OTP sent via Firebase SMS',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
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
                              fillColor: isLoading
                                  ? Colors.grey[200]
                                  : Colors.grey[50],
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              // Auto-verify when all 6 digits are entered
                              if (index == 5 && value.isNotEmpty) {
                                final otp =
                                    _controllers.map((c) => c.text).join();
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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

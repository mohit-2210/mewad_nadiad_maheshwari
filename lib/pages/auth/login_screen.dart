// lib/pages/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/globals/app_strings.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';
import 'package:mmsn/pages/auth/o_t_p_verification_screen.dart';
import 'package:mmsn/pages/home/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  
  bool _showPinField = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) return;
    
    final mobile = _phoneController.text.trim();
    context.read<AuthCubit>().checkUser(mobile);
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    
    final mobile = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    
    context.read<AuthCubit>().loginWithPin(mobile, pin);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserExistsWithPin) {
            setState(() => _showPinField = true);
          } else if (state is UserExistsWithoutPin) {
            // User exists but no PIN - send OTP
            context.read<AuthCubit>().sendOtp(state.mobile);
          } else if (state is UserDoesNotExist) {
            // Show dialog to create account
            _showNewUserDialog(context, state.mobile);
          } else if (state is OtpSent) {
            // Navigate to OTP screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                  phoneNumber: state.mobile,
                  isNewUser: state.isNewUser,
                ),
              ),
            );
          } else if (state is AuthSuccess) {
            // Navigate to main screen based on role
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.1),
                      Icon(
                        Icons.home,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Gap.s16H(),
                      Text(
                        AppStrings.loginTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Gap.s8H(),
                      Text(
                        AppStrings.loginSubTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.08),
                      
                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        enabled: !_showPinField,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: AppStrings.phoneNumber,
                          hintText: AppStrings.phoneHint,
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      
                      // PIN Field (shown only after user check)
                      if (_showPinField) ...[
                        Gap.s16H(),
                        TextFormField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            labelText: AppStrings.pin,
                            hintText: AppStrings.pinHint,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() => _obscurePin = !_obscurePin);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter PIN';
                            }
                            if (value.length != 4) {
                              return 'PIN must be 4 digits';
                            }
                            return null;
                          },
                        ),
                      ],
                      
                      Gap.s32H(),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : (_showPinField ? _handleLogin : _handleContinue),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _showPinField ? AppStrings.loginButton : 'Continue',
                                  style: const TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      
                      if (_showPinField) ...[
                        Gap.s16H(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showPinField = false;
                              _pinController.clear();
                            });
                          },
                          child: const Text('Use different number'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showNewUserDialog(BuildContext context, String mobile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Account'),
        content: const Text(
          'This number is not registered. Would you like to create a new account?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _phoneController.clear();
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Send OTP for registration
              context.read<AuthCubit>().sendOtp(mobile, isNewUser: true);
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
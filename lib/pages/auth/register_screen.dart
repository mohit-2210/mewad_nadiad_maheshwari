import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/globals/app_localizations.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';
import 'package:mmsn/pages/auth/o_t_p_verification_screen.dart';

class RegisterScreen extends StatelessWidget {
  final String phoneNumber;

  const RegisterScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: RegisterView(phoneNumber: phoneNumber),
    );
  }
}

class RegisterView extends StatefulWidget {
  final String phoneNumber;

  const RegisterView({super.key, required this.phoneNumber});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      'name': _nameController.text.trim(),
      'mobile': widget.phoneNumber,
      'userType': 'MEMBER',
    };

    print('📝 Submitting registration for: ${widget.phoneNumber}');
    context.read<AuthCubit>().register(userData);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) =>
              Text(AppLocalizations.text(context, 'register')),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          print('🔄 Register Screen State: ${state.runtimeType}');

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RegistrationSuccess) {
            print('✅ Registration successful, sending Firebase OTP');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Sending OTP...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );

            // Send Firebase OTP automatically for new user
            context.read<AuthCubit>().sendFirebaseOtp(
                  state.mobile,
                  isNewUser: true,
                );
          } else if (state is OtpSent && state.isNewUser) {
            print('📱 Navigating to OTP verification for new user');
            // Navigate to OTP verification screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (newContext) => BlocProvider.value(
                  value: context.read<AuthCubit>(),
                  child: OTPVerificationScreen(
                    phoneNumber: state.mobile,
                    isNewUser: true,
                    isForPhoneVerification: state.isForPhoneVerification,
                    verificationId: state.verificationId,
                  ),
                ),
              ),
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
                      Text(
                        AppLocalizations.text(context, 'createAccount'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Gap.s8H(),
                      Text(
                        AppLocalizations.text(context, 'appName'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.05),

                      // Phone Number (Read-only)
                      TextFormField(
                        initialValue: widget.phoneNumber,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.text(
                            context,
                            'phoneNumber',
                          ),
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      Gap.s16H(),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.text(context, 'fullName'),
                          hintText:
                              AppLocalizations.text(context, 'fullNameHint'),
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      Gap.s32H(),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
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
                              : Builder(
                                  builder: (context) => Text(
                                    AppLocalizations.text(context, 'register'),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                        ),
                      ),
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
}
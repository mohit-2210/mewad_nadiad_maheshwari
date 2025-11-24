import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  bool showCurrentPass = false;
  bool showNewPass = false;
  bool showNewConfirmPass = false;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Password updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );

            currentPasswordController.clear();
            newPasswordController.clear();
            confirmPasswordController.clear();

            setState(() => isLoading = false);
          }

          if (state is AuthLoading) {
            setState(() => isLoading = true);
          }

          if (state is AuthError) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: buildUI(),
      ),
    );
  }

  Padding buildUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPasswordField(
              'Current Password',
              currentPasswordController,
              4,
              showCurrentPass,
              () => setState(
                () => showCurrentPass = !showCurrentPass,
              ),
            ),
            _buildPasswordField(
              'New Password',
              newPasswordController,
              4,
              showNewPass,
              () => setState(
                () => showNewPass = !showNewPass,
              ),
            ),
            _buildPasswordField(
              'Confirm Password',
              confirmPasswordController,
              4,
              showNewConfirmPass,
              () => setState(
                () => showNewConfirmPass = !showNewConfirmPass,
              ),
            ),
            Gap.s30H(),
            ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                isLoading ? 'Updating...' : 'Update Password',
              ),
              onPressed: isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    int maxLength,
    bool show,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: !show,
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              show ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: toggle,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    context.read<AuthCubit>().changePassword(
          currentPasswordController.text.trim(),
          newPasswordController.text.trim(),
        );
  }
}

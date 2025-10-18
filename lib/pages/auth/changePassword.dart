import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField('Current Password', currentPasswordController),
              _buildPasswordField('New Password', newPasswordController),
              _buildPasswordField('Confirm Password', confirmPasswordController),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(isLoading ? 'Updating...' : 'Update Password'),
                onPressed: isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔸 TODO: Call your API endpoint for password change here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password changed successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

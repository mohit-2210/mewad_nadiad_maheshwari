import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/app_localizations.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/auth/data/user_service.dart';
import 'package:mmsn/pages/profile/update/service/user_repository.dart';

class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({required this.member, super.key});

  final User member;

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _educationController;
  late TextEditingController _occupationController;
  late TextEditingController _occupationAddressController;
  late TextEditingController _addressController;
  late TextEditingController _nativePlaceController;
  late TextEditingController _relationController;
  late DateTime? _dateOfBirth;

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isVisible = false;
  bool _isApiCallInProgress = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.fullName);
    _phoneController = TextEditingController(text: widget.member.phoneNumber);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _educationController =
        TextEditingController(text: widget.member.education ?? '');
    _occupationController =
        TextEditingController(text: widget.member.occupation ?? '');
    _occupationAddressController = TextEditingController(
      text: widget.member.occupationAddress ?? '',
    );
    _addressController =
        TextEditingController(text: widget.member.address ?? '');
    _nativePlaceController =
        TextEditingController(text: widget.member.nativePlace ?? '');
    _relationController =
        TextEditingController(text: widget.member.relation ?? '');
    _dateOfBirth = widget.member.dateOfBirth;

    // Add listeners
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _educationController.addListener(_onFieldChanged);
    _occupationController.addListener(_onFieldChanged);
    _occupationAddressController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _nativePlaceController.addListener(_onFieldChanged);
    _relationController.addListener(_onFieldChanged);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _occupationAddressController.dispose();
    _addressController.dispose();
    _nativePlaceController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No changes to update."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isApiCallInProgress = true;
      _isLoading = true;
    });

    try {
      // Create updated user object
      final updatedUser = widget.member.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        education: _educationController.text.trim().isEmpty
            ? null
            : _educationController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
        occupationAddress: _occupationAddressController.text.trim().isEmpty
            ? null
            : _occupationAddressController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        nativePlace: _nativePlaceController.text.trim().isEmpty
            ? null
            : _nativePlaceController.text.trim(),
        relation: widget.member.isHeadOfFamily
            ? null
            : (_relationController.text.trim().isEmpty
                ? null
                : _relationController.text.trim()),
        dateOfBirth: _dateOfBirth,
      );

      // Send update with API field names
      final repo = UserRepository(UserService.instance);
      await repo.updateUserProfile(
        widget.member.id,
        updatedUser.toUpdateJson(), // ✅ Uses API field names
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApiCallInProgress = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isApiCallInProgress,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit ${widget.member.fullName}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _isApiCallInProgress,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedOpacity(
                opacity: _isVisible ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    _buildProfileImage(),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Required';
                        if (v?.length != 10) return 'Must be 10 digits';
                        return null;
                      },
                    ),
                    Gap.s16H(),
                    _buildDateField(),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email (Optional)',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Gap.s16H(),
                    if (!widget.member.isHeadOfFamily) ...[
                      _buildTextField(
                        controller: _relationController,
                        label: 'Relation',
                        icon: Icons.people,
                      ),
                      Gap.s16H(),
                    ],
                    _buildTextField(
                      controller: _educationController,
                      label: 'Education (Optional)',
                      icon: Icons.school,
                    ),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _occupationController,
                      label: 'Occupation (Optional)',
                      icon: Icons.work,
                    ),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _occupationAddressController,
                      label: 'Occupation Address (Optional)',
                      icon: Icons.business,
                      maxLines: 2,
                    ),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _addressController,
                      label: '${AppLocalizations.text(context, 'address')} ${AppLocalizations.text(context, 'optional')}',
                      icon: Icons.home,
                      maxLines: 2,
                    ),
                    Gap.s16H(),
                    _buildTextField(
                      controller: _nativePlaceController,
                      // label: 'Native Place (Optional)',
                      label: '${AppLocalizations.text(context, 'nativePlace')} ${AppLocalizations.text(context, 'optional')}',
                      icon: Icons.place,
                    ),
                    Gap.s40H(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return AnimatedScale(
      scale: _isVisible ? 1 : 0.5,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      child: Stack(
        children: [
          Hero(
            tag: 'edit_member_${widget.member.id}',
            child: CircleAvatar(
              radius: 60,
              backgroundImage: widget.member.profileImage != null
                  ? NetworkImage(widget.member.profileImage!)
                  : null,
              child: widget.member.profileImage == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    final formattedDate = _dateOfBirth != null
        ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/'
            '${_dateOfBirth!.month.toString().padLeft(2, '0')}/'
            '${_dateOfBirth!.year}'
        : '';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _dateOfBirth = picked;
            _onFieldChanged();
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: formattedDate),
          decoration: InputDecoration(
            labelText: 'Date of Birth (Optional)',
            prefixIcon: const Icon(Icons.cake),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

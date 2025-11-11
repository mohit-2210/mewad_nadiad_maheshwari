import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/user.dart';

class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({required this.member, super.key});

  final User member;

  @override
  State<EditMemberScreen> createState() {
    return _EditMemberScreenState();
  }
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  late TextEditingController _phoneController;

  late TextEditingController _emailController;

  late TextEditingController _occupationController;

  late TextEditingController _addressController;

  late TextEditingController _nativePlaceController;

  late TextEditingController _relationController;
  late DateTime? _dateOfBirthController;

  bool _isLoading = false;

  bool _hasChanges = false;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.fullName);
    _phoneController = TextEditingController(text: widget.member.phoneNumber);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _occupationController = TextEditingController(
      text: widget.member.occupation ?? '',
    );
    _addressController = TextEditingController(
      text: widget.member.address ?? '',
    );
    _nativePlaceController = TextEditingController(
      text: widget.member.nativePlace ?? '',
    );
    _relationController = TextEditingController(
      text: widget.member.relation ?? '',
    );
    _dateOfBirthController = widget.member.dateOfBirth ?? null;
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _occupationController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _nativePlaceController.addListener(_onFieldChanged);
    _relationController.addListener(_onFieldChanged);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _nativePlaceController.dispose();
    _relationController.dispose();
    _dateOfBirthController = null;
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final updatedUser = widget.member.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
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
        dateOfBirth: _dateOfBirthController,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.member.fullName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasChanges)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                key: const ValueKey('save'),
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimatedOpacity(
            opacity: _isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 800),
            child: Column(
              children: [
                AnimatedScale(
                  scale: _isVisible ? 1 : 0.5,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  // transform: Matrix4.translationValues(
                  //   0,
                  //   _isVisible ? 0 : 50,
                  //   0,
                  // ),
                  // margin: const EdgeInsets.only(bottom: 32),
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
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.s16H(),
                _buildAnimatedTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  delay: 100,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter full name' : null,
                ),
                Gap.s16H(),
                _buildAnimatedTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  delay: 200,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please enter phone number';
                    }
                    if (value?.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                Gap.s16H(),
                _buildDateOfBirthField(
                  dateOfBirthController: _dateOfBirthController,
                  icon: Icons.cake,
                ),
                Gap.s16H(),
                _buildAnimatedTextField(
                  controller: _emailController,
                  label: 'Email (Optional)',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  delay: 300,
                ),
                Gap.s16H(),
                if (!widget.member.isHeadOfFamily)
                  _buildAnimatedTextField(
                    controller: _relationController,
                    label: 'Relation',
                    icon: Icons.people,
                    delay: 400,
                  ),
                Gap.s16H(),
                
                Gap.s16H(),
                _buildAnimatedTextField(
                  controller: _occupationController,
                  label: 'Occupation (Optional)',
                  icon: Icons.work,
                  delay: 500,
                ),
                Gap.s16H(),
                _buildAnimatedTextField(
                  controller: _addressController,
                  label: 'Address (Optional)',
                  icon: Icons.home,
                  maxLines: 2,
                  delay: 600,
                ),
                Gap.s16H(),
                _buildAnimatedTextField(
                  controller: _nativePlaceController,
                  label: 'Native Place (Optional)',
                  icon: Icons.place,
                  delay: 700,
                ),
                Gap.s40H(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField({
    required DateTime? dateOfBirthController,
    required IconData icon,
  }) {
    final formattedDate = dateOfBirthController != null
        ? "${dateOfBirthController.day.toString().padLeft(2, '0')}/"
          "${dateOfBirthController.month.toString().padLeft(2, '0')}/"
          "${dateOfBirthController.year}"
        : '';
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          helpText: "Select Date of Birth",
          initialDate: dateOfBirthController ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dateOfBirthController = pickedDate;
            _onFieldChanged();
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: formattedDate),
          decoration: InputDecoration(
            labelText: 'Date of Birth (Optional)',
            
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
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return AnimatedScale(
      scale: _isVisible ? 1 : 0.5,
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      // transform: Matrix4.translationValues(0, _isVisible ? 0 : 50, 0),
      // margin: const EdgeInsets.only(bottom: 20),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1 : 0,
        duration: Duration(milliseconds: 600 + delay),
        child: TextFormField(
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
        ),
      ),
    );
  }
}

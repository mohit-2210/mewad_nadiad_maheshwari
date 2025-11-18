import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/app/services/selct_image.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/announcement/services/announcement_api_service.dart';
import 'package:mmsn/pages/family/services/family_api_services.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class AddAnnouncementPage extends StatefulWidget {
  const AddAnnouncementPage({super.key});

  @override
  State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  File? _imageFile;
  File? _pdfFile;
  bool _isSubmitting = false;

  final String _date = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String? _sendToOption;
  String? _selectedSociety;
  User? _selectedHead;

  // society data loaded from API
  Map<String, List<Family>> _societyGroups = {};
  List<String> _selectedSocieties = [];
  bool _isSocietyLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSocietyGroups();
  }

  Future<void> _loadSocietyGroups() async {
    final groups = await FamilyApiService.instance.getFamiliesBySociety();
    setState(() {
      _societyGroups = groups;
      _isSocietyLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pdfFile = File(result.files.single.path!));
    }
  }

  void _clearImage() => setState(() => _imageFile = null);
  void _clearPdf() => setState(() => _pdfFile = null);

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      // 1️⃣ Upload Image if selected
      List<String>? imageUrls;
      if (_imageFile != null) {
        final uploadedImageUrl =
            await AnnouncementApiService.instance.uploadFile(_imageFile!);
        imageUrls = [uploadedImageUrl];
      }

// 2️⃣ Upload PDF if selected
      List<String>? pdfUrls;
      if (_pdfFile != null) {
        final uploadedPdfUrl =
            await AnnouncementApiService.instance.uploadFile(_pdfFile!);
        pdfUrls = [uploadedPdfUrl];
      }

// 3️⃣ Call Create Announcement API
      await AnnouncementApiService.instance.createAnnouncement(
        title: _titleController.text,
        description: _descriptionController.text,
        content: _contentController.text,
        date: DateTime.now(),
        // sendTo: _sendToOption!,
        imageUrls: imageUrls,
        pdfUrls: pdfUrls,
        selectedSocieties:
            _sendToOption == "specific_society" ? _selectedSocieties : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement added successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ Close keyboard when going back
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        return true;
      },
      child: KeyboardDismissOnTap(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              'Add Announcement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date: $_date",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Gap.s16H(),

                                _sectionLabel("Send Announcement To"),
                                Gap.s8H(),
                                DropdownButtonFormField<String>(
                                  value: _sendToOption,
                                  items: const [
                                    DropdownMenuItem(
                                        value: "all_members",
                                        child: Text("All Members")),
                                    DropdownMenuItem(
                                        value: "all_heads",
                                        child: Text("All Heads")),
                                    DropdownMenuItem(
                                        value: "specific_society",
                                        child: Text("Specific Society")),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _sendToOption = value;
                                      _selectedSociety = null;
                                      _selectedHead = null;
                                    });
                                  },
                                  decoration: _inputDecoration("Select Option"),
                                  validator: (v) => v == null
                                      ? "Please select an option"
                                      : null,
                                ),
                                Gap.s16H(),

                                if (_sendToOption == "specific_society") ...[
                                  _sectionLabel("Select Societies"),
                                  Gap.s8H(),
                                  if (_isSocietyLoading)
                                    const Center(
                                        child: CircularProgressIndicator())
                                  else
                                    MultiSelectDialogField<String>(
                                      items: _societyGroups.keys
                                          .map((s) =>
                                              MultiSelectItem<String>(s, s))
                                          .toList(),
                                      initialValue: _selectedSocieties,
                                      title: const Text("Select Societies"),
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.deepPurple.shade200,
                                        ),
                                      ),
                                      buttonText:
                                          const Text("Choose Societies"),
                                      onConfirm: (values) {
                                        setState(() {
                                          _selectedSocieties = values;
                                          _selectedHead = null;
                                        });
                                      },
                                      validator: (values) {
                                        if (_sendToOption ==
                                                "specific_society" &&
                                            (values == null ||
                                                values.isEmpty)) {
                                          return "Select at least one society";
                                        }
                                        return null;
                                      },
                                    ),
                                  Gap.s16H(),
                                ],

                                // Image Section
                                _sectionLabel("Image (optional)"),
                                Gap.s8H(),

                                if (_imageFile != null)
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _imageFile!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            onPressed: _clearImage,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  GestureDetector(
                                    onTap: _selectImage,
                                    child: Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.shade50,
                                        border: Border.all(
                                            color: Colors.deepPurple.shade200),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.add_a_photo,
                                            size: 40, color: Colors.deepPurple),
                                      ),
                                    ),
                                  ),

                                Gap.s24H(),

                                // Text Fields
                                _buildTextField(_titleController, "Title"),
                                Gap.s16H(),

                                _buildTextField(
                                    _descriptionController, "Description"),
                                Gap.s16H(),

                                _buildTextField(
                                    _contentController, "Full Content",
                                    maxLines: 5),
                                Gap.s16H(),

                                // ---------- PDF Section ----------
                                _sectionLabel("Attach PDF (optional)"),
                                Gap.s8H(),
                                _buildPdfSelector(),

                                Gap.s24H(),

                                // ---------- Submit ----------
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: _isSubmitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.check_circle_outline,
                                            color: Colors.white),
                                    label: Text(
                                      _isSubmitting
                                          ? "Submitting..."
                                          : "Submit Announcement",
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    onPressed:
                                        _isSubmitting ? null : _submitForm,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Floating "Hide Keyboard" Button
                    if (isKeyboardVisible)
                      Positioned(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.deepPurple.shade300,
                          onPressed: () => FocusScope.of(context).unfocus(),
                          child: const Icon(Icons.keyboard_hide,
                              color: Colors.white),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  //  Helper Widgets

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      validator: (v) => v == null || v.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildPdfSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, size: 32, color: Colors.deepPurple),
          Gap.s10W(),
          Expanded(
            child: Text(
              _pdfFile != null
                  ? _pdfFile!.path.split('/').last
                  : 'No PDF selected',
              style: TextStyle(
                fontSize: 14,
                color: _pdfFile != null ? Colors.black : Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Gap.s8W(),
          if (_pdfFile != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.redAccent),
              onPressed: _clearPdf,
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _pickPdf,
              icon:
                  const Icon(Icons.upload_file, color: Colors.white, size: 18),
              label: const Text('Select PDF',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple.shade700,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.deepPurple.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  // Selecting Image
  void _selectImage() {
    showImageSourceDialog(
      context: context,
      onImageSelected: (source) {
        _pickImage(source);
      },
    );
  }
}

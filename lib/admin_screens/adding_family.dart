import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mmsn/app/globals/app_constants.dart';

class FamilyFormPage extends StatefulWidget {
  const FamilyFormPage({super.key});

  @override
  _FamilyFormPageState createState() => _FamilyFormPageState();
}

class _FamilyFormPageState extends State<FamilyFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Head Details
  TextEditingController addressController = TextEditingController();
  TextEditingController nativePlaceController = TextEditingController();
  TextEditingController societyNameController = TextEditingController();
  TextEditingController headNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController occupationAddressController = TextEditingController();

  // File? headImage;
  // final ImagePicker _picker = ImagePicker();

  // Future<void> pickHeadImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       headImage = File(pickedFile.path);
  //     });
  //   }
  // }

  List<Map<String, dynamic>> familyMembers = [];
  String? selectedEditor;

  void addMember() {
    setState(() {
      familyMembers.add({
        "name": TextEditingController(),
        "relation": "", // <- keep this as String, not controller
        "dob": TextEditingController(),
        "phone": TextEditingController(),
        "education": TextEditingController(),
        "occupation": TextEditingController(),
        "occupationAddress": TextEditingController(),
        "image": null,
        "isEditor": false,
      });
    });
  }

  void removeMember(int index) {
    setState(() {
      familyMembers.removeAt(index);
      // Reset selected editor if removed
      if (selectedEditor != null) {
        if (!_getEditorList().contains(selectedEditor)) {
          selectedEditor = null;
        }
      }
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

    // If the field already has a date, parse it and use it as initial date
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      } catch (e) {
        // If parsing fails, use current date
        initialDate = DateTime.now();
      }
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Future<void> pickMemberImage(int index) async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       familyMembers[index]["image"] = File(pickedFile.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Family Registration"),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Head of Family", Icons.person),
              // SizedBox(height: 12),
              // _buildImagePicker(headImage, pickHeadImage),
              SizedBox(height: 16),
              _buildTextField(
                headNameController,
                "Full Name",
                Icons.person_outline,
              ),
              _buildTextField(
                phoneController,
                "Phone Number",
                Icons.phone,
                keyboard: TextInputType.phone,
                maxLength: 10,
              ),
              _buildDateField(dobController, "Date of Birth", Icons.cake),
              _buildTextField(
                addressController,
                "Address",
                Icons.home,
                maxLines: 2,
              ),
              _buildTextField(
                nativePlaceController,
                "Native Place",
                Icons.location_city,
              ),
              _buildTextField(
                societyNameController,
                "Society Name",
                Icons.apartment,
              ),
              _buildTextField(
                educationController,
                "Education",
                Icons.school,
              ),
              _buildTextField(
                occupationController,
                "Occupation",
                Icons.work,
              ),
              _buildTextField(
                occupationAddressController,
                "Occupation Address",
                Icons.business,
                maxLines: 2,
              ),
              SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 16),
              _buildSectionHeader("Family Members", Icons.group),
              SizedBox(height: 12),
              ...familyMembers.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> member = entry.value;
                return _memberWidget(member, index);
              }),
              SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: addMember,
                  icon: Icon(Icons.add),
                  label: Text("Add Family Member"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 16),
              _buildSectionHeader("Select Family Editor", Icons.edit),
              SizedBox(height: 12),
              _buildEditorDropdown(),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedEditor == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select a family editor"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Form Submitted Successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    child: Text(
                      "Submit",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
      ],
    );
  }

  // Widget _buildImagePicker(File? image, VoidCallback onPick) {
  //   return Center(
  //     child: GestureDetector(
  //       onTap: onPick,
  //       child: Container(
  //         width: 120,
  //         height: 120,
  //         decoration: BoxDecoration(
  //           color: Colors.grey[200],
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Colors.teal, width: 2),
  //         ),
  //         child: image != null
  //             ? ClipRRect(
  //                 borderRadius: BorderRadius.circular(10),
  //                 child: Image.file(image, fit: BoxFit.cover),
  //               )
  //             : Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.camera_alt, size: 40, color: Colors.teal),
  //                   SizedBox(height: 8),
  //                   Text(
  //                     "Upload Photo",
  //                     style: TextStyle(color: Colors.teal),
  //                   ),
  //                 ],
  //               ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboard,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                if (label.contains("Phone") && value.length != 10) {
                  return "Please enter a valid 10-digit phone number";
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, controller),
        validator: (value) {
          if (value == null || value.isEmpty) return "This field is required";
          return null;
        },
      ),
    );
  }

  Widget _buildEditorDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedEditor,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.admin_panel_settings, color: Colors.teal),
        ),
        hint: Text("Choose who can edit family data"),
        items: _getEditorList().map((name) {
          return DropdownMenuItem(
            value: name,
            child: Text(name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedEditor = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select a family editor";
          }
          return null;
        },
      ),
    );
  }

  List<String> _getEditorList() {
    List<String> names = [];

    // Add head name if not empty
    if (headNameController.text.trim().isNotEmpty) {
      names.add(headNameController.text.trim());
    }

    // Add family member names if not empty
    for (var mem in familyMembers) {
      String memberName = mem["name"].text.trim();
      if (memberName.isNotEmpty) {
        names.add(memberName);
      }
    }

    return names;
  }

  Widget _buildDropdownField(
    String? value,
    String label,
    IconData icon,
    List<String> items, {
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value?.isNotEmpty == true ? value : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
        dropdownColor: Colors.white,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select $label";
          }
          return null;
        },
      ),
    );
  }

  Widget _memberWidget(Map<String, dynamic> mem, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Member ${index + 1}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => removeMember(index),
                  tooltip: "Remove member",
                ),
              ],
            ),
            SizedBox(height: 12),
            // Center(
            //   child: GestureDetector(
            //     onTap: () => pickMemberImage(index),
            //     child: Container(
            //       width: 100,
            //       height: 100,
            //       decoration: BoxDecoration(
            //         color: Colors.grey[200],
            //         borderRadius: BorderRadius.circular(12),
            //         border: Border.all(color: Colors.teal, width: 2),
            //       ),
            //       child: mem["image"] != null
            //           ? ClipRRect(
            //               borderRadius: BorderRadius.circular(10),
            //               child: Image.file(mem["image"], fit: BoxFit.cover),
            //             )
            //           : Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(Icons.camera_alt, size: 32, color: Colors.teal),
            //                 SizedBox(height: 4),
            //                 Text(
            //                   "Add Photo",
            //                   style: TextStyle(color: Colors.teal, fontSize: 12),
            //                 ),
            //               ],
            //             ),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 16),
            _buildTextField(
              mem["name"],
              "Full Name",
              Icons.person_outline,
            ),
            _buildDropdownField(
              mem["relation"],
              "Relation with Head",
              Icons.family_restroom,
              relationList,
              onChanged: (value) {
                setState(() {
                  mem["relation"] = value ?? '';
                });
              },
            ),
            _buildDateField(
              mem["dob"],
              "Date of Birth",
              Icons.cake,
            ),
            _buildTextField(
              mem["phone"],
              "Phone Number",
              Icons.phone,
              keyboard: TextInputType.phone,
              maxLength: 10,
              isRequired: false,
            ),
            _buildTextField(
              mem["education"],
              "Education",
              Icons.school,
              isRequired: false,
            ),
            _buildTextField(
              mem["occupation"],
              "Occupation",
              Icons.work,
              isRequired: false,
            ),
            _buildTextField(
              mem["occupationAddress"],
              "Occupation Address",
              Icons.business,
              maxLines: 2,
              isRequired: false,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A reusable bottom sheet for selecting image source (camera/gallery)
Future<void> showImageSourceDialog({
  required BuildContext context,
  required Function(ImageSource) onImageSelected,
}) async {
  FocusScope.of(context).unfocus(); 

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              onImageSelected(ImageSource.camera);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.photo_library, color: Colors.deepPurpleAccent),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              onImageSelected(ImageSource.gallery);
            },
          ),
        ],
      ),
    ),
  );
}

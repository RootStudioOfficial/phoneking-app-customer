import 'dart:io';

import 'package:image_picker/image_picker.dart';

class PickerUtils {
  static Future<File?> takeImageFromCamera() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? photo = await imagePicker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        return null;
      }
      return File(photo.path);
    } catch (_) {
      rethrow;
    }
  }

  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } catch (_) {
      rethrow;
    }
  }
}

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../utils/permission_utils.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> takePhotoFromCamera() async {
    try {
      await PermissionUtils.requestCameraAndStoragePermissions();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConstants.imageQuality,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('${AppConstants.errorTakePhoto}: $e');
    }
  }

  static Future<File?> pickImageFromGallery() async {
    try {
      await PermissionUtils.requestCameraAndStoragePermissions();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: AppConstants.imageQuality,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('${AppConstants.errorSelectImage}: $e');
    }
  }
}

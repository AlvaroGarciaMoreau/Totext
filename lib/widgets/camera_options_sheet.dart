import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CameraOptionsSheet {
  static void show(BuildContext context, {
    required VoidCallback onTakePhoto,
    required VoidCallback onSelectGallery,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text(AppConstants.menuTakePhoto),
                onTap: () {
                  Navigator.pop(context);
                  onTakePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(AppConstants.menuSelectGallery),
                onTap: () {
                  Navigator.pop(context);
                  onSelectGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<void> requestCameraAndStoragePermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  static Future<bool> requestMicrophonePermission() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }
    return micStatus.isGranted;
  }
}

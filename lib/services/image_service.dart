import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> captureImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.rear,
    );

    return file?.path;
  }
}

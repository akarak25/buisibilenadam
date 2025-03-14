import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  late List<CameraDescription> cameras;
  CameraController? controller;
  bool isInitialized = false;

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      controller = CameraController(
        cameras[0], // Arka kamera
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller!.initialize();
      isInitialized = true;
    } catch (e) {
      throw Exception('Kamera başlatılamadı: $e');
    }
  }

  Future<File?> takePicture() async {
    if (!isInitialized || controller == null) {
      throw Exception('Kamera başlatılmadı');
    }

    try {
      final XFile file = await controller!.takePicture();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(file.path);
      final File savedImage = File('${appDir.path}/$fileName');
      
      if (await savedImage.exists()) {
        await savedImage.delete();
      }
      
      await File(file.path).copy(savedImage.path);
      return savedImage;
    } catch (e) {
      throw Exception('Fotoğraf çekilemedi: $e');
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final File savedImage = File('${appDir.path}/$fileName');
      
      if (await savedImage.exists()) {
        await savedImage.delete();
      }
      
      await File(pickedFile.path).copy(savedImage.path);
      return savedImage;
    } catch (e) {
      throw Exception('Galeriden resim seçilemedi: $e');
    }
  }

  void dispose() {
    controller?.dispose();
  }
}

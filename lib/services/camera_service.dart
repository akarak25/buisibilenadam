import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  late List<CameraDescription> cameras;
  CameraController? controller;
  bool isInitialized = false;
  
  // Optimal kamera ayarları
  bool _flashEnabled = false;
  double _zoomLevel = 1.0;
  ExposureMode _exposureMode = ExposureMode.auto;
  FocusMode _focusMode = FocusMode.auto;

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      controller = CameraController(
        cameras[0], // Arka kamera
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false, // Ses kaydını devre dışı bırak
      );
      await controller!.initialize();
      
      // En iyi el fotoğrafı çekmek için optimal kamera ayarları
      await _configureController();
      
      isInitialized = true;
    } catch (e) {
      throw Exception('Kamera başlatılamadı: $e');
    }
  }
  
  // Kamera ayarlarını yapılandır
  Future<void> _configureController() async {
    if (controller == null) return;
    
    try {
      // Auto focus modunu ayarla
      await controller!.setFocusMode(_focusMode);
      
      // Auto exposure modunu ayarla
      await controller!.setExposureMode(_exposureMode);
      
      // El fotoğrafı çekmek için flash'i kapalı tut (yansıma önlemek için)
      try {
        await controller!.setFlashMode(FlashMode.off);
      } catch (e) {
        print('Flash modu ayarlanamıyor: $e');
      }
    } catch (e) {
      print('Kamera ayarları yapılandırma hatası: $e');
    }
  }
  
  // Işık durumunu kontrol et
  Future<bool> hasGoodLighting() async {
    if (controller == null) return false;
    
    try {
      // Basit bir kontrol - otomatik olarak iyi ışıklandırma varsay
      return true;
    } catch (e) {
      print('Işık kontrolü hatası: $e');
      return false;
    }
  }

  Future<File?> takePicture() async {
    if (!isInitialized || controller == null) {
      throw Exception('Kamera başlatılmadı');
    }

    try {
      // Çekim öncesi optimal ayarları yap
      await controller!.setFocusMode(FocusMode.locked);
      await controller!.setExposureMode(ExposureMode.locked);
      
      // Fotoğrafı çek
      final XFile file = await controller!.takePicture();
      
      // Çekim sonrası ayarları sıfırla
      await controller!.setFocusMode(_focusMode);
      await controller!.setExposureMode(_exposureMode);
      
      // Fotoğrafı kaydet
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

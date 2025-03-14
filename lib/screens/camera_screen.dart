import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/services/camera_service.dart';
import 'package:palm_analysis/screens/analysis_screen.dart';
import 'package:palm_analysis/widgets/camera_guide_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isCameraReady = false;
  bool _isProcessing = false;
  double _currentExposure = 0.0;
  bool _isHandDetected = false;
  
  // El pozisyonu rehberinin durumu
  bool _isHandAligned = false;
  
  // Işık durumu
  bool _hasGoodLighting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    
    // Test için: Kamera çalıştıktan 3 saniye sonra el algılamayı simüle et
    Future.delayed(const Duration(seconds: 3), _simulateHandDetection);
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {
        _isCameraReady = true;
      });
      
      // Kamera başlatıldıktan sonra ışık seviyesini kontrol etmeye başla
      _startLightLevelDetection();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamera başlatılamadı: $e')),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama durumu değiştiğinde kamerayı yönet
    if (!_isCameraReady || _cameraService.controller == null) return;

    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
      _isCameraReady = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }
  
  // Işık seviyesini kontrol etme
  void _startLightLevelDetection() {
    if (!_isCameraReady || _cameraService.controller == null) return;
    
    // Basit bir simülasyon - gerçek uygulamada kamera parametrelerinden analiz yapılabilir
    try {
      if (mounted) {
        _cameraService.hasGoodLighting().then((bool hasGoodLight) {
          setState(() {
            _hasGoodLighting = hasGoodLight;
          });
        });
      }
      
      // Her 2 saniyede bir ışık seviyesini kontrol et
      Future.delayed(const Duration(seconds: 2), _startLightLevelDetection);
    } catch (e) {
      print('Işık seviyesi ölçme hatası: $e');
    }
  }
  
  // El algılama fonksiyonu (burada basit bir simülasyon yapıyoruz)
  // Gerçek uygulamada tensorflow lite veya benzer bir kütüphane kullanabilirsiniz
  void _simulateHandDetection() {
    if (mounted) {
      setState(() {
        // Burada gerçek el algılama yapılmalı, şu an rastgele simüle ediyoruz
        _isHandDetected = true;
        _isHandAligned = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _isProcessing) return;

    // Eğer el pozisyonu hizalı değilse ve ışık yeterli değilse uyarı göster
    if (!_isHandAligned || !_hasGoodLighting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_isHandAligned 
                ? 'Lütfen elinizi rehber içine yerleştirin' 
                : 'Işık seviyesi düşük, daha aydınlık ortamda çekim yapın'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final File? imageFile = await _cameraService.takePicture();
      if (imageFile != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf çekilemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final File? imageFile = await _cameraService.pickImageFromGallery();
      if (imageFile != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Galeriden resim seçilemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Işık seviyesi göstergesi
  Widget _buildLightIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasGoodLighting ? Icons.wb_sunny : Icons.wb_cloudy,
            color: _hasGoodLighting ? Colors.yellow : Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            _hasGoodLighting 
                ? 'Işık seviyesi iyi' 
                : 'Daha fazla ışık gerekiyor',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('El Fotoğrafı Çek'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isCameraReady
                ? Stack(
                    children: [
                      // Kamera önizleme
                      CameraPreview(_cameraService.controller!),
                      
                      // Rehber overlay'i
                      CameraGuideOverlay(
                        isHandDetected: _isHandDetected,
                        isHandAligned: _isHandAligned,
                        hasGoodLighting: _hasGoodLighting,
                      ),
                      
                      // Işık durumu gösterge
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: _buildLightIndicator(),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
          _buildCameraControls(),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Galeri butonu
          IconButton(
            onPressed: _isProcessing ? null : _pickImageFromGallery,
            icon: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 32,
            ),
          ),
          // Fotoğraf çekme butonu
          GestureDetector(
            onTap: _isProcessing ? null : _takePicture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          ),
          // Kamera değiştirme
          IconButton(
            onPressed: _isProcessing
                ? null
                : () {
                    // Kamera değiştirme özelliği ileride eklenebilir
                  },
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

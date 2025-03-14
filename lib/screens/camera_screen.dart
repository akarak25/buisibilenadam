import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/services/camera_service.dart';
import 'package:palm_analysis/screens/analysis_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isCameraReady = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {
        _isCameraReady = true;
      });
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

  Future<void> _takePicture() async {
    if (!_isCameraReady || _isProcessing) return;

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
                ? CameraPreview(_cameraService.controller!)
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

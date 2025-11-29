import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/services/camera_service.dart';
import 'package:palm_analysis/screens/analysis_screen.dart';
import 'package:palm_analysis/widgets/camera_guide_overlay.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _isHandDetected = false;
  bool _isHandAligned = false;
  bool _hasGoodLighting = false;
  Timer? _lightDetectionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();

    // Simulate hand detection after 3 seconds
    Future.delayed(const Duration(seconds: 3), _simulateHandDetection);
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {
        _isCameraReady = true;
      });

      _startLightLevelDetection();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera initialization failed: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isCameraReady || _cameraService.controller == null) return;

    if (state == AppLifecycleState.inactive) {
      _lightDetectionTimer?.cancel();
      _cameraService.dispose();
      _isCameraReady = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _lightDetectionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  void _startLightLevelDetection() {
    if (!_isCameraReady || _cameraService.controller == null) return;

    // Cancel any existing timer
    _lightDetectionTimer?.cancel();

    // Initial check
    _checkLightLevel();

    // Start periodic timer
    _lightDetectionTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkLightLevel(),
    );
  }

  void _checkLightLevel() {
    if (!mounted || !_isCameraReady || _cameraService.controller == null) {
      _lightDetectionTimer?.cancel();
      return;
    }

    try {
      _cameraService.hasGoodLighting().then((bool hasGoodLight) {
        if (mounted) {
          setState(() {
            _hasGoodLighting = hasGoodLight;
          });
        }
      });
    } catch (e) {
      debugPrint('Light level detection error: $e');
    }
  }

  void _simulateHandDetection() {
    if (mounted) {
      setState(() {
        _isHandDetected = true;
        _isHandAligned = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _isProcessing) return;

    if (!_isHandAligned || !_hasGoodLighting) {
      final lang = AppLocalizations.of(context).currentLanguage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_isHandAligned ? lang.placeYourHand : lang.lightLevel,
          ),
          backgroundColor: AppTheme.warningAmber,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).currentLanguage.generalError),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
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
    final lang = AppLocalizations.of(context).currentLanguage;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or loading
          _isCameraReady
              ? Stack(
                  children: [
                    // Camera preview
                    Positioned.fill(
                      child: CameraPreview(_cameraService.controller!),
                    ),

                    // Guide overlay
                    CameraGuideOverlay(
                      isHandDetected: _isHandDetected,
                      isHandAligned: _isHandAligned,
                      hasGoodLighting: _hasGoodLighting,
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryIndigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading camera...',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

          // Top bar with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      // Back button
                      _buildGlassButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Text(
                        lang.takePicture,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Light indicator
                      _buildLightIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hint text
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lang.placeYourHand,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery button
                          _buildControlButton(
                            icon: Icons.photo_library_rounded,
                            label: lang.selectFromGallery,
                            onTap:
                                _isProcessing ? null : _pickImageFromGallery,
                          ),
                          // Capture button
                          _buildCaptureButton(),
                          // Flip camera (placeholder)
                          _buildControlButton(
                            icon: Icons.flip_camera_ios_rounded,
                            label: 'Flip',
                            onTap: null, // Feature to be added
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _hasGoodLighting ? Icons.wb_sunny_rounded : Icons.wb_cloudy,
                color: _hasGoodLighting ? Colors.amber : Colors.white60,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _hasGoodLighting ? 'Good' : 'Low',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _hasGoodLighting ? Colors.amber : Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDisabled ? 0.1 : 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: isDisabled ? 0.3 : 1),
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: isDisabled ? 0.3 : 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _takePicture,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: Center(
            child: _isProcessing
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }
}

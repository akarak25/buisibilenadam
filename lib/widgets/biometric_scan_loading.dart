import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';

/// Professional biometric scanning animation widget
/// Creates a laboratory/scientific scanning experience for palm analysis
class BiometricScanLoading extends StatefulWidget {
  final String? imagePath;
  final VoidCallback? onComplete;
  final bool isApiComplete; // API tamamlandığında true olur

  const BiometricScanLoading({
    super.key,
    this.imagePath,
    this.onComplete,
    this.isApiComplete = false,
  });

  @override
  State<BiometricScanLoading> createState() => _BiometricScanLoadingState();
}

class _BiometricScanLoadingState extends State<BiometricScanLoading>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  final List<ScanStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startScanSequence();
  }

  void _initializeAnimations() {
    // Scan line animation - moves up and down
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    _scanLineController.repeat(reverse: true);

    // Pulse animation for active step
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Progress controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _startScanSequence() {
    // Initialize steps based on language (will be set in build)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _advanceStep();
    });
  }

  void _advanceStep() {
    if (!mounted) return;

    if (_currentStep < _steps.length) {
      setState(() {
        if (_currentStep > 0) {
          _steps[_currentStep - 1] = _steps[_currentStep - 1].copyWith(
            status: StepStatus.completed,
          );
        }
        if (_currentStep < _steps.length) {
          _steps[_currentStep] = _steps[_currentStep].copyWith(
            status: StepStatus.processing,
          );
        }
        _currentStep++;
      });

      // Advance to next step after delay
      final delay = _steps[_currentStep - 1].duration;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted && _currentStep < _steps.length) {
          _advanceStep();
        } else if (mounted && _currentStep == _steps.length) {
          // Son adım: API tamamlanana kadar processing'de kal
          if (widget.isApiComplete) {
            setState(() {
              _steps[_currentStep - 1] = _steps[_currentStep - 1].copyWith(
                status: StepStatus.completed,
              );
            });
          }
          // API bitmeden completed işaretleme - didUpdateWidget'ta kontrol edilecek
        }
      });
    }
  }

  @override
  void didUpdateWidget(BiometricScanLoading oldWidget) {
    super.didUpdateWidget(oldWidget);

    // API tamamlandığında son adımı completed yap
    if (widget.isApiComplete && !oldWidget.isApiComplete) {
      if (_steps.isNotEmpty && _currentStep == _steps.length) {
        setState(() {
          _steps[_currentStep - 1] = _steps[_currentStep - 1].copyWith(
            status: StepStatus.completed,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  List<ScanStep> _buildSteps(bool isTurkish) {
    if (isTurkish) {
      return [
        ScanStep(
          icon: Icons.document_scanner_outlined,
          title: 'Avuç Yüzeyi Taranıyor',
          subtitle: 'Biyometrik veri toplanıyor...',
          duration: 1500,
        ),
        ScanStep(
          icon: Icons.timeline_outlined,
          title: 'Çizgiler Tespit Ediliyor',
          subtitle: 'Ana çizgiler belirleniyor...',
          duration: 1800,
        ),
        ScanStep(
          icon: Icons.grid_on_outlined,
          title: 'Geometri Analiz Ediliyor',
          subtitle: 'Çizgi açıları ve uzunlukları hesaplanıyor...',
          duration: 2000,
        ),
        ScanStep(
          icon: Icons.fingerprint_outlined,
          title: 'Biyometrik Veri İşleniyor',
          subtitle: 'Kişisel özellikler çıkarılıyor...',
          duration: 2200,
        ),
        ScanStep(
          icon: Icons.psychology_outlined,
          title: 'AI Raporu Oluşturuluyor',
          subtitle: 'Yapay zeka analizi tamamlanıyor...',
          duration: 2500,
        ),
      ];
    } else {
      return [
        ScanStep(
          icon: Icons.document_scanner_outlined,
          title: 'Scanning Palm Surface',
          subtitle: 'Collecting biometric data...',
          duration: 1500,
        ),
        ScanStep(
          icon: Icons.timeline_outlined,
          title: 'Detecting Lines',
          subtitle: 'Identifying major lines...',
          duration: 1800,
        ),
        ScanStep(
          icon: Icons.grid_on_outlined,
          title: 'Analyzing Geometry',
          subtitle: 'Calculating line angles and lengths...',
          duration: 2000,
        ),
        ScanStep(
          icon: Icons.fingerprint_outlined,
          title: 'Processing Biometrics',
          subtitle: 'Extracting personal characteristics...',
          duration: 2200,
        ),
        ScanStep(
          icon: Icons.psychology_outlined,
          title: 'Generating AI Report',
          subtitle: 'AI analysis completing...',
          duration: 2500,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    // Initialize steps if empty
    if (_steps.isEmpty) {
      _steps.addAll(_buildSteps(isTurkish));
      // Start the sequence
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentStep == 0) {
          _advanceStep();
        }
      });
    }

    final completedSteps = _steps.where((s) => s.status == StepStatus.completed).length;
    double progress = _steps.isEmpty ? 0.0 : completedSteps / _steps.length;

    // API tamamlanana kadar %95'te tut
    if (progress >= 1.0 && !widget.isApiComplete) {
      progress = 0.95;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with futuristic styling
          _buildHeader(isTurkish),
          const SizedBox(height: 24),

          // Scan visualization area
          _buildScanVisualization(),
          const SizedBox(height: 24),

          // Progress bar
          _buildProgressBar(progress, isTurkish),
          const SizedBox(height: 20),

          // Step indicators
          _buildStepList(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isTurkish) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated pulse icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryIndigo.withValues(alpha: 0.8),
                      AppTheme.primaryPurple.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTurkish ? 'BİYOMETRİK ANALİZ' : 'BIOMETRIC ANALYSIS',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Text(
              isTurkish ? 'Yapay Zeka Destekli' : 'Powered by AI',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.primaryIndigo,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanVisualization() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            size: const Size(double.infinity, 120),
            painter: GridPainter(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
            ),
          ),

          // Scan line
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top: _scanLineAnimation.value * 100,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryIndigo,
                        AppTheme.primaryPurple,
                        AppTheme.primaryIndigo,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryIndigo.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Center palm icon
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.3 + (_pulseAnimation.value * 0.2),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppTheme.primaryIndigo,
                        AppTheme.primaryPurple,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.back_hand_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Corner markers
          ..._buildCornerMarkers(),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerSize = 20.0;
    const color = AppTheme.primaryIndigo;

    return [
      // Top left
      Positioned(
        top: 0,
        left: 0,
        child: _CornerMarker(size: markerSize, color: color, corner: Corner.topLeft),
      ),
      // Top right
      Positioned(
        top: 0,
        right: 0,
        child: _CornerMarker(size: markerSize, color: color, corner: Corner.topRight),
      ),
      // Bottom left
      Positioned(
        bottom: 0,
        left: 0,
        child: _CornerMarker(size: markerSize, color: color, corner: Corner.bottomLeft),
      ),
      // Bottom right
      Positioned(
        bottom: 0,
        right: 0,
        child: _CornerMarker(size: markerSize, color: color, corner: Corner.bottomRight),
      ),
    ];
  }

  Widget _buildProgressBar(double progress, bool isTurkish) {
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isTurkish ? 'İşlem Durumu' : 'Processing Status',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            Text(
              '$percentage%',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryIndigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300),
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepList() {
    return Column(
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;

        return _StepItem(
          step: step,
          isLast: index == _steps.length - 1,
          pulseAnimation: _pulseAnimation,
        );
      }).toList(),
    );
  }
}

class _StepItem extends StatelessWidget {
  final ScanStep step;
  final bool isLast;
  final Animation<double> pulseAnimation;

  const _StepItem({
    required this.step,
    required this.isLast,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = step.status == StepStatus.processing;
    final isCompleted = step.status == StepStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Status indicator
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppTheme.successGreen.withValues(alpha: 0.2)
                      : isActive
                          ? AppTheme.primaryIndigo.withValues(alpha: 0.2 * pulseAnimation.value)
                          : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.successGreen
                        : isActive
                            ? AppTheme.primaryIndigo
                            : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppTheme.successGreen,
                        )
                      : isActive
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.primaryIndigo,
                                ),
                              ),
                            )
                          : Icon(
                              step.icon,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isCompleted
                        ? AppTheme.successGreen
                        : isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                if (isActive)
                  Text(
                    step.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerMarker extends StatelessWidget {
  final double size;
  final Color color;
  final Corner corner;

  const _CornerMarker({
    required this.size,
    required this.color,
    required this.corner,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CornerMarkerPainter(color: color, corner: corner),
    );
  }
}

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class CornerMarkerPainter extends CustomPainter {
  final Color color;
  final Corner corner;

  CornerMarkerPainter({required this.color, required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    switch (corner) {
      case Corner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case Corner.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 20.0;

    // Vertical lines
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum StepStatus { pending, processing, completed }

class ScanStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final int duration;
  final StepStatus status;

  ScanStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.duration,
    this.status = StepStatus.pending,
  });

  ScanStep copyWith({
    IconData? icon,
    String? title,
    String? subtitle,
    int? duration,
    StepStatus? status,
  }) {
    return ScanStep(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }
}

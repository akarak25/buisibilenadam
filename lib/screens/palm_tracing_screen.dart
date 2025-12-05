import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/analysis_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

/// Interactive palm line tracing screen
/// User traces their palm lines on the captured image before analysis
/// This creates user engagement and "tool-like" experience for Apple
class PalmTracingScreen extends StatefulWidget {
  final File imageFile;

  const PalmTracingScreen({super.key, required this.imageFile});

  @override
  State<PalmTracingScreen> createState() => _PalmTracingScreenState();
}

class _PalmTracingScreenState extends State<PalmTracingScreen>
    with TickerProviderStateMixin {
  final List<TracingLine> _lines = [];
  List<Offset> _currentLine = [];
  int _currentStep = 0;
  bool _isTracing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<TracingStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<TracingStep> _buildSteps(bool isTurkish) {
    if (isTurkish) {
      return [
        TracingStep(
          name: 'Kalp Çizgisi',
          instruction: 'Serçe parmağınızın altından işaret parmağına doğru çizin',
          color: const Color(0xFFEC4899),
          icon: Icons.favorite_outline,
        ),
        TracingStep(
          name: 'Akıl Çizgisi',
          instruction: 'Kalp çizgisinin altında, yatay olarak çizin',
          color: const Color(0xFF3B82F6),
          icon: Icons.psychology_outlined,
        ),
        TracingStep(
          name: 'Yaşam Çizgisi',
          instruction: 'Başparmağınızın etrafını çevreleyen eğri çizgiyi takip edin',
          color: const Color(0xFF22C55E),
          icon: Icons.favorite,
        ),
      ];
    } else {
      return [
        TracingStep(
          name: 'Heart Line',
          instruction: 'Trace from below your pinky finger towards your index finger',
          color: const Color(0xFFEC4899),
          icon: Icons.favorite_outline,
        ),
        TracingStep(
          name: 'Head Line',
          instruction: 'Trace horizontally below the heart line',
          color: const Color(0xFF3B82F6),
          icon: Icons.psychology_outlined,
        ),
        TracingStep(
          name: 'Life Line',
          instruction: 'Trace the curved line that wraps around your thumb',
          color: const Color(0xFF22C55E),
          icon: Icons.favorite,
        ),
      ];
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_currentStep >= _steps.length) return;

    setState(() {
      _isTracing = true;
      _currentLine = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isTracing || _currentStep >= _steps.length) return;

    setState(() {
      _currentLine.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isTracing || _currentStep >= _steps.length) return;

    setState(() {
      _isTracing = false;

      // Only save if line has enough points
      if (_currentLine.length > 10) {
        _lines.add(TracingLine(
          points: List.from(_currentLine),
          color: _steps[_currentStep].color,
          name: _steps[_currentStep].name,
        ));
        _currentStep++;
      }
      _currentLine = [];
    });
  }

  void _undoLastLine() {
    if (_lines.isEmpty) return;

    setState(() {
      _lines.removeLast();
      _currentStep = _lines.length;
    });
  }

  void _skipTracing() {
    _proceedToAnalysis();
  }

  void _proceedToAnalysis() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(imageFile: widget.imageFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    // Initialize steps
    if (_steps.isEmpty) {
      _steps.addAll(_buildSteps(isTurkish));
    }

    final isComplete = _currentStep >= _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isTurkish),

            // Current step instruction
            if (!isComplete) _buildStepInstruction(),

            // Image with tracing canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTracingArea(),
              ),
            ),

            // Bottom controls
            _buildBottomControls(isTurkish, isComplete),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTurkish) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTurkish ? 'ÇİZGİ TESPİTİ' : 'LINE DETECTION',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  isTurkish
                      ? 'Temel çizgilerinizi işaretleyin'
                      : 'Mark your major lines',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // Skip button
          TextButton(
            onPressed: _skipTracing,
            child: Text(
              isTurkish ? 'Atla' : 'Skip',
              style: GoogleFonts.inter(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepInstruction() {
    final step = _steps[_currentStep];

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: step.color.withValues(alpha: 0.1 * _pulseAnimation.value),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: step.color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  color: step.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_currentStep + 1}/${_steps.length}',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            color: step.color,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          step.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.instruction,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTracingArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Palm image
          Image.file(
            widget.imageFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white30,
                  ),
                ),
              );
            },
          ),

          // Grid overlay for professional look
          CustomPaint(
            painter: _GridOverlayPainter(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
            ),
          ),

          // Tracing canvas
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: _TracingPainter(
                lines: _lines,
                currentLine: _currentLine,
                currentColor: _currentStep < _steps.length
                    ? _steps[_currentStep].color
                    : Colors.white,
              ),
            ),
          ),

          // Corner markers
          ..._buildCornerMarkers(),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const color = AppTheme.primaryIndigo;

    return [
      Positioned(
        top: 0,
        left: 0,
        child: _CornerMarker(color: color),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Transform.rotate(
          angle: 1.5708,
          child: _CornerMarker(color: color),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Transform.rotate(
          angle: -1.5708,
          child: _CornerMarker(color: color),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Transform.rotate(
          angle: 3.1416,
          child: _CornerMarker(color: color),
        ),
      ),
    ];
  }

  Widget _buildBottomControls(bool isTurkish, bool isComplete) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Line legend
          if (_lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 16,
                children: _lines.map((line) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: line.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        line.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppTheme.successGreen,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

          // Action buttons
          Row(
            children: [
              // Undo button
              if (_lines.isNotEmpty)
                Expanded(
                  child: GestureDetector(
                    onTap: _undoLastLine,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.undo,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTurkish ? 'Geri Al' : 'Undo',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Proceed button
              Expanded(
                flex: _lines.isNotEmpty ? 2 : 1,
                child: GestureDetector(
                  onTap: _proceedToAnalysis,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isComplete
                          ? AppTheme.successGradient
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isComplete
                                  ? AppTheme.successGreen
                                  : AppTheme.primaryIndigo)
                              .withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isComplete
                              ? Icons.check_circle_outline
                              : Icons.science_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isComplete
                              ? (isTurkish ? 'Analizi Başlat' : 'Start Analysis')
                              : (isTurkish
                                  ? 'Analiz Et (${3 - _currentStep} kaldı)'
                                  : 'Analyze (${3 - _currentStep} left)'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TracingStep {
  final String name;
  final String instruction;
  final Color color;
  final IconData icon;

  TracingStep({
    required this.name,
    required this.instruction,
    required this.color,
    required this.icon,
  });
}

class TracingLine {
  final List<Offset> points;
  final Color color;
  final String name;

  TracingLine({
    required this.points,
    required this.color,
    required this.name,
  });
}

class _TracingPainter extends CustomPainter {
  final List<TracingLine> lines;
  final List<Offset> currentLine;
  final Color currentColor;

  _TracingPainter({
    required this.lines,
    required this.currentLine,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed lines
    for (final line in lines) {
      _drawLine(canvas, line.points, line.color);
    }

    // Draw current line
    if (currentLine.isNotEmpty) {
      _drawLine(canvas, currentLine, currentColor);
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw glow first
    canvas.drawPath(path, glowPaint);
    // Draw main line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) {
    return true;
  }
}

class _GridOverlayPainter extends CustomPainter {
  final Color color;

  _GridOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerMarker extends StatelessWidget {
  final Color color;

  const _CornerMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(color: color),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;

  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

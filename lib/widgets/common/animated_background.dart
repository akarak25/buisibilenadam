import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';

/// Animated gradient background matching web design
class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Overlay for softer look
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),

          // Animated blobs
          if (showBlobs) ...[
            Positioned(
              top: -100,
              right: -100,
              child: _AnimatedBlob(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                size: 300,
                delay: Duration.zero,
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _AnimatedBlob(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                size: 250,
                delay: const Duration(seconds: 2),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              right: -80,
              child: _AnimatedBlob(
                color: AppTheme.accentSky.withValues(alpha: 0.08),
                size: 200,
                delay: const Duration(seconds: 4),
              ),
            ),
          ],

          // Main content
          child,
        ],
      ),
    );
  }
}

/// Animated blob for background decoration
class _AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;
  final Duration delay;

  const _AnimatedBlob({
    required this.color,
    required this.size,
    required this.delay,
  });

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        return Transform.translate(
          offset: Offset(
            30 * (value - 0.5),
            -50 * value + 20 * (1 - value),
          ),
          child: Transform.scale(
            scale: 0.9 + 0.2 * value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simple gradient background without animation
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundLight,
            AppTheme.backgroundEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}

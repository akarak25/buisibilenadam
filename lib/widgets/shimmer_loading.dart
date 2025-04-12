import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Analiz başlığı
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[100]!,
                    Colors.grey[300]!,
                  ],
                  stops: [
                    0.0,
                    _animation.value,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // İçerik satırları
        ...List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[100]!,
                        Colors.grey[300]!,
                      ],
                      stops: [
                        0.0,
                        _animation.value,
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Alt başlık
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[100]!,
                    Colors.grey[300]!,
                  ],
                  stops: [
                    0.0,
                    _animation.value,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // Daha fazla içerik satırı
        ...List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Son satır daha kısa
                final width = index == 3
                    ? MediaQuery.of(context).size.width * 0.6
                    : double.infinity;
                    
                return Container(
                  width: width,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[100]!,
                        Colors.grey[300]!,
                      ],
                      stops: [
                        0.0,
                        _animation.value,
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Yükleniyor metni
        Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).currentLanguage.analyzingPalm,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

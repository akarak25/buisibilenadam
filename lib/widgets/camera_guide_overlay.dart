import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class CameraGuideOverlay extends StatelessWidget {
  final bool isHandDetected;
  final bool isHandAligned;
  final bool hasGoodLighting;

  const CameraGuideOverlay({
    super.key,
    required this.isHandDetected,
    required this.isHandAligned,
    required this.hasGoodLighting,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // El rehberi çerçevesi
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8 * 1.3, // 4:3 oranı yaklaşık
            decoration: BoxDecoration(
              border: Border.all(
                color: _getBorderColor(),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.back_hand_outlined,
                  color: Colors.white54,
                  size: 60,
                ),
                const SizedBox(height: 20),
                if (!isHandDetected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AppLocalizations.of(context).currentLanguage.placeYourHand,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Alt kısımda rehber metni
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatusItem(
                  context: context,
                  icon: Icons.pan_tool_outlined,
                  translationKey: 'handDetection',
                  isActive: isHandDetected,
                ),
                const SizedBox(height: 8),
                _buildStatusItem(
                  context: context,
                  icon: Icons.center_focus_strong,
                  translationKey: 'handPosition',
                  isActive: isHandAligned,
                ),
                const SizedBox(height: 8),
                _buildStatusItem(
                  context: context,
                  icon: Icons.wb_sunny,
                  translationKey: 'lightLevel',
                  isActive: hasGoodLighting,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required BuildContext context,
    required IconData icon,
    required String translationKey,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isActive ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          // Dil desteği için uygun anahtarı seç
          translationKey == 'handDetection'
              ? AppLocalizations.of(context).currentLanguage.handDetection
              : translationKey == 'handPosition'
                  ? AppLocalizations.of(context).currentLanguage.handPosition
                  : AppLocalizations.of(context).currentLanguage.lightLevel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getBorderColor() {
    if (isHandAligned && hasGoodLighting) {
      return Colors.green;
    } else if (isHandDetected) {
      return Colors.yellow;
    } else {
      return Colors.white54;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/utils/constants.dart';
import 'package:palm_analysis/screens/camera_screen.dart';
import 'package:palm_analysis/screens/history_screen.dart';
import 'package:palm_analysis/screens/language_settings_screen.dart';
import 'package:palm_analysis/screens/premium_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palm_analysis/services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _totalAnalyses = 0;
  bool _isPremium = false;
  int _remainingQueries = 0;
  final UsageService _usageService = UsageService();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat(reverse: true);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Toplam analiz sayısını yükle
      final prefs = await SharedPreferences.getInstance();
      final totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      
      // Premium durumunu ve kalan sorgu hakkını yükle
      final isPremium = await _usageService.isPremium();
      final remainingQueries = await _usageService.getRemainingQueries();
      
      if (mounted) {
        setState(() {
          _totalAnalyses = totalAnalyses;
          _isPremium = isPremium;
          _remainingQueries = remainingQueries;
        });
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language,
              color: AppTheme.primaryColor,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LanguageSettingsScreen(),
                ),
              );
            },
            tooltip: AppLocalizations.of(context).currentLanguage.languageSettings,
            padding: const EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).currentLanguage.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).currentLanguage.appDescription,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColorLight,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CameraScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.back_hand_outlined,
                                  size: 80,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context).currentLanguage.analyzeHand,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        AppLocalizations.of(context).currentLanguage.takePicture,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textColorLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Premium durumu ve kalan sorgular
              _buildPremiumStatusCard(),
              
              const SizedBox(height: 16),
              
              // Analiz Geçmişi butonu
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  ).then((_) => _loadData());
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.history,
                              color: AppTheme.primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              AppLocalizations.of(context).currentLanguage.analysisHistory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$_totalAnalyses',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumStatusCard() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PremiumScreen()),
        ).then((_) => _loadData());
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _isPremium ? Colors.amber.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isPremium ? Icons.star : Icons.star_border,
                    color: _isPremium ? Colors.amber : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPremium 
                          ? AppLocalizations.of(context).currentLanguage.premiumActive
                          : AppLocalizations.of(context).currentLanguage.premium,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isPremium ? Colors.amber.shade800 : AppTheme.textColor,
                        ),
                      ),
                      if (!_isPremium)
                        Text(
                          AppLocalizations.of(context).currentLanguage.remainingAnalyses
                            .replaceAll('{count}', _remainingQueries.toString()),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textColorLight,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _isPremium ? Colors.amber.shade800 : AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

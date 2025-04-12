import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:palm_analysis/services/billing_service.dart';
import 'package:palm_analysis/services/usage_service.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final BillingService _billingService = BillingService();
  final UsageService _usageService = UsageService();
  bool _isLoading = false;
  bool _isPremium = false;
  int _remainingQueries = 0;
  ProductDetails? _monthlySubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _billingService.initialize();
      
      final isPremium = await _billingService.isPremium();
      final remainingQueries = await _usageService.getRemainingQueries();
      final monthlySubscription = _billingService.getMonthlySubscriptionDetails();
      
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
          _remainingQueries = remainingQueries;
          _monthlySubscription = monthlySubscription;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Premium ekranı başlatma hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _subscribe() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final success = await _billingService.buyMonthlySubscription();
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).currentLanguage.purchaseError)),
        );
      }
      
      // Satın alma durumu güncellendikten sonra ekranı yenilemek için 2 saniye bekleyin
      await Future.delayed(const Duration(seconds: 2));
      await _initialize();
    } catch (e) {
      print('Abonelik hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abonelik işlemi sırasında bir hata oluştu: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _billingService.restorePurchases();
      
      // Satın alma durumu güncellendikten sonra ekranı yenilemek için 2 saniye bekleyin
      await Future.delayed(const Duration(seconds: 2));
      await _initialize();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).currentLanguage.purchaseRestored)),
      );
    } catch (e) {
      print('Satın alma geri yükleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Satın almalar geri yüklenirken bir hata oluştu: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).currentLanguage.premium),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Premium ikon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isPremium ? Colors.amber.shade100 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPremium ? Icons.star : Icons.star_border,
                        size: 80,
                        color: _isPremium ? Colors.amber : Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Premium durum başlığı
                    Text(
                      _isPremium
                          ? AppLocalizations.of(context).currentLanguage.premiumActive
                          : AppLocalizations.of(context).currentLanguage.premiumInactive,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Kalan analizler
                    if (!_isPremium)
                      Text(
                        AppLocalizations.of(context).currentLanguage.remainingAnalyses.replaceAll(
                          '{count}', _remainingQueries.toString()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    
                    const SizedBox(height: 36),
                    
                    // Avantajlar listesi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).currentLanguage.premiumFeatures,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            context,
                            Icons.repeat,
                            AppLocalizations.of(context).currentLanguage.unlimitedAnalyses,
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.cancel_outlined,
                            AppLocalizations.of(context).currentLanguage.noAds,
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.compare_arrows,
                            AppLocalizations.of(context).currentLanguage.compareAnalyses,
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.support_agent,
                            AppLocalizations.of(context).currentLanguage.prioritySupport,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 36),
                    
                    // Abonelik bilgileri
                    if (!_isPremium && _monthlySubscription != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _monthlySubscription!.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _monthlySubscription!.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _monthlySubscription!.price,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Abonelik butonu
                    if (!_isPremium)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _subscribe,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).currentLanguage.subscribe,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Restore purchases button
                    TextButton(
                      onPressed: _restorePurchases,
                      child: Text(
                        AppLocalizations.of(context).currentLanguage.restorePurchases,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Geri dönme butonu
                    if (_isPremium || _remainingQueries > 0)
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          AppLocalizations.of(context).currentLanguage.backToApp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

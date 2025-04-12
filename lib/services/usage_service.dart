import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palm_analysis/models/user_usage.dart';

class UsageService {
  static const String _userUsageKey = 'user_usage';
  
  UserUsage? _cachedUsage;
  
  // Singleton pattern
  static final UsageService _instance = UsageService._internal();
  factory UsageService() => _instance;
  UsageService._internal();

  Future<UserUsage> getUserUsage() async {
    if (_cachedUsage != null) {
      _cachedUsage!.checkSubscriptionStatus();
      return _cachedUsage!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final usageJson = prefs.getString(_userUsageKey);
    
    if (usageJson == null) {
      _cachedUsage = UserUsage();
      await _saveUsage(_cachedUsage!);
      return _cachedUsage!;
    }
    
    try {
      _cachedUsage = UserUsage.fromJson(jsonDecode(usageJson));
      _cachedUsage!.checkSubscriptionStatus();
      return _cachedUsage!;
    } catch (e) {
      print('Kullanıcı kullanım bilgisi çözümlenirken hata: $e');
      _cachedUsage = UserUsage();
      await _saveUsage(_cachedUsage!);
      return _cachedUsage!;
    }
  }
  
  Future<void> _saveUsage(UserUsage usage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userUsageKey, jsonEncode(usage.toJson()));
  }
  
  Future<bool> canPerformAnalysis() async {
    final usage = await getUserUsage();
    return usage.hasAvailableQueries;
  }
  
  Future<void> incrementUsage() async {
    final usage = await getUserUsage();
    usage.incrementUsage();
    await _saveUsage(usage);
  }
  
  Future<void> activatePremium(String subscriptionId, DateTime expiryDate) async {
    final usage = await getUserUsage();
    usage.activatePremium(subscriptionId, expiryDate);
    await _saveUsage(usage);
  }
  
  Future<void> deactivatePremium() async {
    final usage = await getUserUsage();
    usage.deactivatePremium();
    await _saveUsage(usage);
  }
  
  Future<int> getRemainingQueries() async {
    final usage = await getUserUsage();
    if (usage.isPremium) return -1; // Sınırsız
    return usage.maxFreeQueries - usage.usedQueries;
  }
  
  Future<bool> isPremium() async {
    final usage = await getUserUsage();
    return usage.isPremium;
  }
}

class UserUsage {
  int usedQueries;
  int maxFreeQueries;
  bool isPremium;
  DateTime lastResetDate;
  String? subscriptionId;
  DateTime? subscriptionExpiryDate;

  UserUsage({
    this.usedQueries = 0,
    this.maxFreeQueries = 3,
    this.isPremium = false,
    DateTime? lastResetDate,
    this.subscriptionId,
    this.subscriptionExpiryDate,
  }) : lastResetDate = lastResetDate ?? DateTime.now();

  factory UserUsage.fromJson(Map<String, dynamic> json) {
    return UserUsage(
      usedQueries: json['usedQueries'] ?? 0,
      maxFreeQueries: json['maxFreeQueries'] ?? 3,
      isPremium: json['isPremium'] ?? false,
      lastResetDate: json['lastResetDate'] != null 
          ? DateTime.parse(json['lastResetDate'])
          : DateTime.now(),
      subscriptionId: json['subscriptionId'],
      subscriptionExpiryDate: json['subscriptionExpiryDate'] != null 
          ? DateTime.parse(json['subscriptionExpiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usedQueries': usedQueries,
      'maxFreeQueries': maxFreeQueries,
      'isPremium': isPremium,
      'lastResetDate': lastResetDate.toIso8601String(),
      'subscriptionId': subscriptionId,
      'subscriptionExpiryDate': subscriptionExpiryDate?.toIso8601String(),
    };
  }

  bool get hasAvailableQueries {
    if (isPremium) return true;
    
    // Ay değişmiş mi kontrol et
    final now = DateTime.now();
    final lastMonth = lastResetDate.month;
    final lastYear = lastResetDate.year;
    final currentMonth = now.month;
    final currentYear = now.year;
    
    // Eğer ay değiştiyse sorgu sayısını sıfırla
    if (currentMonth != lastMonth || currentYear != lastYear) {
      usedQueries = 0;
      lastResetDate = now;
      return true;
    }
    
    return usedQueries < maxFreeQueries;
  }

  void incrementUsage() {
    if (!isPremium) {
      usedQueries++;
    }
  }

  void activatePremium(String subscriptionId, DateTime expiryDate) {
    this.isPremium = true;
    this.subscriptionId = subscriptionId;
    this.subscriptionExpiryDate = expiryDate;
  }

  void deactivatePremium() {
    this.isPremium = false;
    this.subscriptionId = null;
    this.subscriptionExpiryDate = null;
  }

  bool get isSubscriptionExpired {
    if (subscriptionExpiryDate == null) return true;
    return DateTime.now().isAfter(subscriptionExpiryDate!);
  }

  void checkSubscriptionStatus() {
    if (isPremium && isSubscriptionExpired) {
      deactivatePremium();
    }
  }
}

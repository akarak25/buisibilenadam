import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:palm_analysis/services/usage_service.dart';

class BillingService {
  // Ürün ID'leri - bunları Google Play Console'da tanımlamalısınız
  static const String _monthlySubscriptionId = 'palm_analysis_monthly_subscription';
  
  // Satın alınabilir ürünler listesi
  List<ProductDetails> _products = [];
  
  // Servis örnekleri
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final UsageService _usageService = UsageService();
  
  // Stream abonelikleri
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Singleton pattern
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();
  
  Future<void> initialize() async {
    // IAP'nin kullanılabilir olup olmadığını kontrol et
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('Uygulama içi satın alma kullanılamıyor');
      return;
    }
    
    // Google Play Store için özel işlemler
    // Not: Yeni sürümlerde bekleyen satın almalar otomatik olarak etkinleştirilmiştir
    // enablePendingPurchases() metodu artık gerekli değildir
    
    // Satın alma güncellemelerini dinle
    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        print('Satın alma stream hatası: $error');
      },
    );
    
    // Ürünleri yükle
    await _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = {_monthlySubscriptionId};
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('Bulunamayan ürün ID\'leri: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
      
      if (_products.isEmpty) {
        print('Ürün bilgileri yüklenemedi. Lütfen ürün ID\'lerini kontrol edin.');
      } else {
        print('${_products.length} ürün başarıyla yüklendi');
      }
    } catch (e) {
      print('Ürün yükleme hatası: $e');
    }
  }
  
  Future<bool> buyMonthlySubscription() async {
    try {
      final ProductDetails? product = _findProductById(_monthlySubscriptionId);
      
      if (product == null) {
        print('Aylık abonelik ürünü bulunamadı');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null, // Kullanıcı kimliği gerekiyorsa ekleyin
      );
      
      return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Satın alma işlemi başlatılırken hata: $e');
      return false;
    }
  }
  
  ProductDetails? _findProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> isPremium() {
    return _usageService.isPremium();
  }
  
  ProductDetails? getMonthlySubscriptionDetails() {
    return _findProductById(_monthlySubscriptionId);
  }
  
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Bekleyen satın alma - bir yükleme göstergesi gösterilebilir
        print('Satın alma beklemede: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Satın alma hatası
        print('Satın alma hatası: ${purchaseDetails.error?.message}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased || 
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Satın alma başarılı veya geri yüklendi
        print('Satın alma başarılı: ${purchaseDetails.productID}');
        
        if (purchaseDetails.productID == _monthlySubscriptionId) {
          // Aboneliği kullanıcıya ver
          
          // Genellikle burada gelişmiş doğrulama yapılmalıdır
          bool validPurchase = await _verifyPurchase(purchaseDetails);
          
          if (validPurchase) {
            // Abonelik bitiş tarihi - Gerçek uygulamada bu veri genellikle 
            // satın alma nesnesinin içinde veya kendi geri ucunuzdan alınır
            final DateTime now = DateTime.now();
            final DateTime expiryDate = DateTime(now.year, now.month + 1, now.day);
            
            await _usageService.activatePremium(
              purchaseDetails.purchaseID ?? 'unknown',
              expiryDate
            );
          }
        }
        
        // Google Play Store'a satın almanın tamamlandığını bildirin
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        print('Satın alma iptal edildi: ${purchaseDetails.productID}');
      }
    }
  }
  
  // Güvenlik için satın alma doğrulama
  // Gerçek uygulamada, bu genellikle bir sunucu tarafından yapılır
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Gerçek uygulamada, bu daha karmaşık bir doğrulama olmalıdır
    // Genellikle kendi backend'inize bir istek göndererek satın alma makbuzunu doğrularsınız
    return purchaseDetails.status == PurchaseStatus.purchased;
  }
  
  void dispose() {
    _subscription?.cancel();
  }
  
  // Mevcut abonelikleri ve satın almaları geri yükle
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }
}

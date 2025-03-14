import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Sistemin durum çubuğu rengini ayarla
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    // Ekran yönelimini dikey olarak sabitle
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // .env dosyasını yüklemeyi dene, hata yakalanırsa da uygulama çökmesin
    try {
      await dotenv.load();
    } catch (e) {
      print("Env dosyası yüklenemedi: $e");
      // Uygulama burada çökmesin, devam etsin
    }
    
    // Tarih formatlaması için yerel dil desteğini yüklemeyi dene
    try {
      await initializeDateFormatting('tr_TR', null);
    } catch (e) {
      print("Tarih formatlaması yüklenemedi: $e");
      // Uygulama burada çökmesin, devam etsin
    }
    
    runApp(const PalmAnalysisApp());
  } catch (e, stackTrace) {
    print("Uygulama başlatılırken hata: $e");
    print("Stack trace: $stackTrace");
    
    // Basit bir hata ekranı göster
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Uygulama başlatılamadı: $e"),
        ),
      ),
    ));
  }
}

class PalmAnalysisApp extends StatelessWidget {
  const PalmAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        title: 'El Çizgisi Analizi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      );
    } catch (e) {
      // UI oluşturulurken hata olursa basit bir hata ekranı göster
      return MaterialApp(
        title: 'Hata',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Hata')),
          body: Center(
            child: Text('UI oluşturulurken hata oluştu: $e'),
          ),
        ),
      );
    }
  }
}

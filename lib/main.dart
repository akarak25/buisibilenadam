import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

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
    
    // .env dosyasını yüklemeyi dene, başarısız olursa alternatif yöntemle ilerle
    bool envLoaded = false;
    try {
      await dotenv.load();
      envLoaded = true;
      print(".env dosyası başarıyla yüklendi");
    } catch (e) {
      print(".env dosyası yüklenemedi: $e");
      // Alternatif olarak uygulama içinde varsayılan değerler kullanılacak
    }
    
    if (!envLoaded) {
      try {
        // Uygulama bellek alanında env dosyası oluşturmayı dene
        final appDocDir = await getApplicationDocumentsDirectory();
        final envFile = File('${appDocDir.path}/.env');
        
        if (!await envFile.exists()) {
          await envFile.writeAsString('CLAUDE_API_KEY=dummy_key_for_testing');
          print("Geçici .env dosyası oluşturuldu: ${envFile.path}");
        }
        
        await dotenv.load(fileName: envFile.path);
        print("Alternatif .env dosyası yüklendi");
      } catch (envError) {
        print("Alternatif .env yükleme başarısız oldu: $envError");
        // Bu durumda da uygulama çalışmaya devam etmeli
      }
    }
    
    // Tarih formatlaması için yerel dil desteğini yüklemeyi dene
    try {
      await initializeDateFormatting('tr_TR', null);
      print("Tarih formatlaması başarıyla yüklendi");
    } catch (e) {
      print("Tarih formatlaması yüklenemedi: $e");
      // Uygulama burada çökmesin, devam etsin
    }
    
    runApp(const PalmAnalysisApp());
  } catch (e, stackTrace) {
    print("Uygulama başlatılırken hata: $e");
    print("Stack trace: $stackTrace");
    
    // Daha anlaşılır bir hata ekranı göster
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Uygulama Başlatılamadı",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hata: $e",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Lütfen uygulamayı yeniden başlatın veya geliştiriciyle iletişime geçin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
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
      // UI oluşturulurken hata olursa daha iyi bir hata ekranı göster
      return MaterialApp(
        title: 'Hata',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Arayüz Yüklenemedi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Hata: $e",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Lütfen uygulamayı yeniden başlatın veya geliştiriciyle iletişime geçin.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

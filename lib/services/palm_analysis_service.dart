import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PalmAnalysisService {
  final String apiKey;

  PalmAnalysisService({String? apiKey})
    : apiKey = apiKey ?? dotenv.get('CLAUDE_API_KEY', fallback: 'dummy_key_for_testing');

  // Claude API anahtarının geçerli olup olmadığını kontrol et
  bool _isApiKeyValid() {
    // API anahtarı boş değilse ve varsayılan değer değilse geçerli kabul et
    return apiKey.isNotEmpty && apiKey != 'dummy_key_for_testing' && apiKey != 'your_claude_api_key_here';
  }

  Future<String> analyzeHandImage(File imageFile) async {
    try {
      // API anahtarı geçerli değilse hata mesajı döndür
      if (!_isApiKeyValid()) {
        return '# API Anahtarı Geçerli Değil\n\nLütfen .env dosyasında geçerli bir Claude API anahtarı tanımlayın. API anahtarınızı https://console.anthropic.com adresinden alabilirsiniz.\n\nBu uygulama demo modunda çalışıyor. Lütfen gerçek bir analiz için API anahtarı ekleyin.';
      }
      
      // Görüntü dosyasının varlığını kontrol et
      if (!await imageFile.exists()) {
        return '# Dosya Bulunamadı\n\nAnaliz edilecek görüntü bulunamadı. Lütfen tekrar bir fotoğraf çekin veya seçin.';
      }
      
      // Dosya boyutunu kontrol et
      final fileSize = await imageFile.length();
      if (fileSize <= 0) {
        return '# Geçersiz Dosya\n\nFotoğraf boş veya bozuk. Lütfen yeni bir fotoğraf çekin.';
      }

      // Görüntüyü base64'e dönüştür
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      try {
        
        
        // API'nin yanıt vermeme durumunu ele almak için timeout koy
        final response = await http.post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json; charset=utf-8',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': 'claude-3-7-sonnet-20250219',
            'max_tokens': 1000,
            'temperature': 0.5,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text':
                        '${Constants.systemPrompt}\n\nBu avuç içi fotoğrafımı analiz et ve el çizgilerim hakkında detaylı bilgi ver. Her el çizgisinin başlığını ## EL ÇİZGİSİ ## formatında belirt, örneğin "## KADER ÇİZGİSİ ##" şeklinde yazıp sonrasında yorumunu yap. Başlıkları büyük harflerle belirtmen önemli. Numaralı maddeler kullanıyorsan, 1., 2., 3. gibi düzgün formatlama kullan.',
                  },
                  {
                    'type': 'image',
                    'source': {
                      'type': 'base64',
                      'media_type': 'image/jpeg',
                      'data': base64Image,
                    },
                  },
                ],
              },
            ],
          }),
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          throw Exception("API yanıt vermedi, bağlantı zaman aşımına uğradı.");
        });

        if (response.statusCode == 200) {
          try {
            // UTF-8 kodlamasıyla yanıtı doğru şekilde çöz
            final jsonBody = utf8.decode(response.bodyBytes);
            final data = jsonDecode(jsonBody);

            // API yanıtının içeriğini al
            if (data.containsKey('content') &&
                data['content'] is List &&
                data['content'].isNotEmpty &&
                data['content'][0].containsKey('text')) {
              // Claude API'sinden gelen metin yanıtı
              String textContent = data['content'][0]['text'];
              
              // Sıralı listelerdeki numaralara boşluk ekle
              textContent = textContent.replaceAllMapped(
                RegExp(r'(\d+)\.(\S)'),
                (match) => '${match.group(1)}. ${match.group(2)}'
              );
              
              // Tek satırdaki listeleri ayrı satırlara böl
              textContent = textContent.replaceAllMapped(
                RegExp(r'(\d+)\. ([^\n]+?)(?=(\d+)\. |$)'),
                (match) => '${match.group(1)}. ${match.group(2)}\n'
              );
              
              return textContent;
            } else {
              print("API yanıtı beklenen formatta değil: $data");
              return "API yanıtı beklenmeyen formatta. Lütfen tekrar deneyin.";
            }
          } catch (e) {
            print("Yanıt işleme hatası: $e");
            return "Yanıt işlenirken hata oluştu: $e";
          }
        } else {
          print("API yanıt kodu hatalı: ${response.statusCode}");
          return "API isteği başarısız oldu: ${response.statusCode}. Lütfen daha sonra tekrar deneyin.";
        }
      } catch (e) {
        print("HTTP isteği hatası: $e");
        return "API'ye bağlanırken bir hata oluştu. İnternet bağlantınızı kontrol edin ve tekrar deneyin.";
      }
    } catch (e) {
      print("Genel analiz hatası: $e");
      return "El analizi sırasında bir hata oluştu: $e. Lütfen tekrar deneyin.";
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PalmAnalysisService {
  final String apiKey;

  PalmAnalysisService({String? apiKey})
    : apiKey = apiKey ?? dotenv.get('CLAUDE_API_KEY', fallback: '');

  Future<String> analyzeHandImage(File imageFile) async {
    try {
      // API anahtarı boşsa hata mesajı döndür
      if (apiKey.isEmpty) {
        return '# API Anahtarı Eksik\n\nLütfen .env dosyasında geçerli bir Claude API anahtarı tanımlayın.';
      }

      // Görüntüyü base64'e dönüştür
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      try {
        // UTF-8 karakter kodlamasını doğru şekilde kullanarak API isteği gönder
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
                        '${Constants.systemPrompt}\n\nBu avuç içi fotoğrafımı analiz et ve el çizgilerim hakkında detaylı bilgi ver. Her el çizgisinin başlığını ## EL ÇİZGİSİ ## formatında belirt, örneğin "## KADER ÇİZGİSİ ##" şeklinde yazıp sonrasında yorumunu yap. Başlıkları büyük harflerle belirtmen önemli.',
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
        );

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
              // Metin içeriğini doğrudan dön
              return data['content'][0]['text'];
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

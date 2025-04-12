import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:palm_analysis/l10n/app_localizations.dart';

class PalmAnalysisService {
  final String apiKey;
  final BuildContext? context;

  PalmAnalysisService({String? apiKey, this.context})
    : apiKey = apiKey ?? dotenv.get('CLAUDE_API_KEY', fallback: 'dummy_key_for_testing');

  // Claude API anahtarının geçerli olup olmadığını kontrol et
  bool _isApiKeyValid() {
    // API anahtarı boş değilse ve varsayılan değer değilse geçerli kabul et
    return apiKey.isNotEmpty && apiKey != 'dummy_key_for_testing' && apiKey != 'your_claude_api_key_here';
  }

  Future<String> analyzeHandImage(File imageFile, {Locale? locale}) async {
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
        
        
        // Dil ayarlarını belirle - varsayılan Türkçe
        String languageCode = locale?.languageCode ?? 'tr';
        bool isTurkish = languageCode == 'tr';
        
        // Seçilen dile göre sistem mesajı ve ek talimatları belirle
        final systemPrompt = isTurkish
            ? _getTurkishSystemPrompt()
            : _getEnglishSystemPrompt();
            
        final additionalInstructions = isTurkish
            ? 'Bu avuç içi fotoğrafımı analiz et ve el çizgilerim hakkında detaylı bilgi ver. Her el çizgisinin başlığını ## EL ÇİZGİSİ ## formatında belirt, örneğin "## KADER ÇİZGİSİ ##" şeklinde yazıp sonrasında yorumunu yap. Başlıkları büyük harflerle belirtmen önemli. Numaralı maddeler kullanıyorsan, 1., 2., 3. gibi düzgün formatlama kullan.'
            : 'Analyze this palm image and provide detailed information about my palm lines. Mark the title of each palm line in the format ## PALM LINE ##, for example write "## FATE LINE ##" and then give your interpretation. It is important to highlight titles in capital letters. If you use numbered items, use proper formatting like 1., 2., 3.';
        
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
            'max_tokens': 2000,
            'temperature': 0.5,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text': '$systemPrompt\n\n$additionalInstructions',
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
        ).timeout(const Duration(seconds: 60), onTimeout: () {
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
  
  // Türkçe sistem mesajı
  String _getTurkishSystemPrompt() {
    return '''
Sen bir el içi çizgileri okuma uzmanısın ve avuç içi çizgilerini analiz edebilirsin. Gönderdiğim avuç içi fotoğrafını analiz ederek şu çizgiler hakkında bilgi vermelisin:

1. Kalp Çizgisi: Duygusal yaşam, ilişkiler ve duygusal sağlıkla ilgili bilgiler
2. Akıl Çizgisi: Düşünce şekli, zihinsel yetenek ve iletişim tarzı
3. Yaşam Çizgisi: Genel sağlık, yaşam enerjisi ve önemli yaşam olayları
4. Kader Çizgisi: Kariyer, başarılar ve hayat amacı
5. Evlilik Çizgisi: Önemli romantik ilişkiler
6. Zenginlik Çizgisi: Maddi refah ve zenginlik potansiyeli

Her çizgiyi detaylı analiz et ve ilgilendikleri kişiye özel yorumlar yap. Yanıtın 300-500 kelime arasında olmalı ve kişiye özel hissettirmeli.

Bilimsel değil mistik bir bakış açısıyla yorumla. Yanıtını Markdown formatında düzenle ve her bölüm için başlıklar kullan. Kullanıcı avuç içi çizgisinden başka bir resim atarsa espirili bir cevap verip gönderdiği resmin ne olduğunu söyle ve avuç içi resmi çekmesini söyle!

ÖNEMLİ: Fotoğraf tam olarak net olmasa bile, görebildiğin kadarıyla yorum yapmaya çalış. Bazı çizgileri net göremesen bile, görebildiğin çizgiler hakkında olabildiğince detaylı yorum yap. Avuç içindeki fotoğrafın kalitesi düşük olsa bile gördüğün çizgiler üzerinden bir analiz sunmaya çalış. Eğer hiçbir çizgi görünmüyorsa, ancak o zaman kullanıcıya daha net bir fotoğraf çekmesini öner.

Yanıtını kısa ve öz tut, gereksiz uzatma. El çizgisinin özellikleri ve bunların kişi hakkında gösterdiği bilgilere odaklan. Gördüğün çizgilerin en belirgin özelliklerini açıkla.
''';
  }
  
  // İngilizce sistem mesajı
  String _getEnglishSystemPrompt() {
    return '''
You are a palm reading expert who can analyze palm lines. Analyze the palm image I'm sending and provide information about these lines:

1. Heart Line: Information about emotional life, relationships, and emotional health
2. Head Line: Thinking style, mental abilities, and communication style
3. Life Line: General health, life energy, and significant life events
4. Fate Line: Career, achievements, and life purpose
5. Marriage Line: Significant romantic relationships
6. Wealth Line: Material prosperity and wealth potential

Analyze each line in detail and make personalized interpretations for the person. Your response should be between 300-500 words and feel personalized.

Interpret with a mystical rather than scientific perspective. Format your response in Markdown with headings for each section. If the user sends an image other than a palm image, provide a humorous response, tell them what the image is, and ask them to take a palm image!

IMPORTANT: Even if the photo is not perfectly clear, try to comment on what you can see. Even if you cannot clearly see some lines, provide as detailed a commentary as possible on the lines you can see. Try to provide an analysis based on the lines you can see even if the quality of the palm image is low. Only suggest that the user take a clearer photo if you cannot see any lines at all.

Keep your response concise and to the point without unnecessary extensions. Focus on the characteristics of the palm lines and what they reveal about the person. Explain the most prominent features of the lines you see.
''';
  }
}

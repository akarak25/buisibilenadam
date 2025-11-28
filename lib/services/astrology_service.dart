import 'dart:math';

/// Moon phase enum
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

/// Zodiac sign enum
enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

/// Astrology service for moon phases and zodiac calculations
class AstrologyService {
  static final AstrologyService _instance = AstrologyService._internal();
  factory AstrologyService() => _instance;
  AstrologyService._internal();

  /// Calculate current moon phase
  MoonPhase getCurrentMoonPhase() {
    final now = DateTime.now();
    final daysSinceNew = _calculateMoonAge(now);

    // Moon cycle is approximately 29.53 days
    final phase = (daysSinceNew / 29.53) * 8;
    final phaseIndex = phase.floor() % 8;

    return MoonPhase.values[phaseIndex];
  }

  /// Calculate moon age in days since last new moon
  double _calculateMoonAge(DateTime date) {
    // Reference new moon: January 6, 2000, 18:14 UTC
    final referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
    final daysSinceReference = date.difference(referenceNewMoon).inSeconds / 86400.0;

    // Moon cycle is approximately 29.53 days
    const lunarCycle = 29.530588853;
    final moonAge = daysSinceReference % lunarCycle;

    return moonAge;
  }

  /// Get moon phase name in Turkish
  String getMoonPhaseTr(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Yeni Ay';
      case MoonPhase.waxingCrescent:
        return 'Hilal (Büyüyen)';
      case MoonPhase.firstQuarter:
        return 'İlk Dördün';
      case MoonPhase.waxingGibbous:
        return 'Şişkin Ay (Büyüyen)';
      case MoonPhase.fullMoon:
        return 'Dolunay';
      case MoonPhase.waningGibbous:
        return 'Şişkin Ay (Küçülen)';
      case MoonPhase.lastQuarter:
        return 'Son Dördün';
      case MoonPhase.waningCrescent:
        return 'Hilal (Küçülen)';
    }
  }

  /// Get moon phase name in English
  String getMoonPhaseEn(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'New Moon';
      case MoonPhase.waxingCrescent:
        return 'Waxing Crescent';
      case MoonPhase.firstQuarter:
        return 'First Quarter';
      case MoonPhase.waxingGibbous:
        return 'Waxing Gibbous';
      case MoonPhase.fullMoon:
        return 'Full Moon';
      case MoonPhase.waningGibbous:
        return 'Waning Gibbous';
      case MoonPhase.lastQuarter:
        return 'Last Quarter';
      case MoonPhase.waningCrescent:
        return 'Waning Crescent';
    }
  }

  /// Get moon phase icon
  String getMoonPhaseIcon(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return '🌑';
      case MoonPhase.waxingCrescent:
        return '🌒';
      case MoonPhase.firstQuarter:
        return '🌓';
      case MoonPhase.waxingGibbous:
        return '🌔';
      case MoonPhase.fullMoon:
        return '🌕';
      case MoonPhase.waningGibbous:
        return '🌖';
      case MoonPhase.lastQuarter:
        return '🌗';
      case MoonPhase.waningCrescent:
        return '🌘';
    }
  }

  /// Calculate moon's current zodiac sign
  ZodiacSign getMoonSign() {
    final now = DateTime.now();
    final moonAge = _calculateMoonAge(now);

    // Moon moves through each zodiac sign in about 2.5 days
    // 12 signs in 29.53 days = ~2.46 days per sign
    final signIndex = ((moonAge / 29.53) * 12).floor() % 12;

    return ZodiacSign.values[signIndex];
  }

  /// Get zodiac sign name in Turkish
  String getZodiacSignTr(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return 'Koç';
      case ZodiacSign.taurus:
        return 'Boğa';
      case ZodiacSign.gemini:
        return 'İkizler';
      case ZodiacSign.cancer:
        return 'Yengeç';
      case ZodiacSign.leo:
        return 'Aslan';
      case ZodiacSign.virgo:
        return 'Başak';
      case ZodiacSign.libra:
        return 'Terazi';
      case ZodiacSign.scorpio:
        return 'Akrep';
      case ZodiacSign.sagittarius:
        return 'Yay';
      case ZodiacSign.capricorn:
        return 'Oğlak';
      case ZodiacSign.aquarius:
        return 'Kova';
      case ZodiacSign.pisces:
        return 'Balık';
    }
  }

  /// Get zodiac sign name in English
  String getZodiacSignEn(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return 'Aries';
      case ZodiacSign.taurus:
        return 'Taurus';
      case ZodiacSign.gemini:
        return 'Gemini';
      case ZodiacSign.cancer:
        return 'Cancer';
      case ZodiacSign.leo:
        return 'Leo';
      case ZodiacSign.virgo:
        return 'Virgo';
      case ZodiacSign.libra:
        return 'Libra';
      case ZodiacSign.scorpio:
        return 'Scorpio';
      case ZodiacSign.sagittarius:
        return 'Sagittarius';
      case ZodiacSign.capricorn:
        return 'Capricorn';
      case ZodiacSign.aquarius:
        return 'Aquarius';
      case ZodiacSign.pisces:
        return 'Pisces';
    }
  }

  /// Get zodiac sign icon
  String getZodiacSignIcon(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return '♈';
      case ZodiacSign.taurus:
        return '♉';
      case ZodiacSign.gemini:
        return '♊';
      case ZodiacSign.cancer:
        return '♋';
      case ZodiacSign.leo:
        return '♌';
      case ZodiacSign.virgo:
        return '♍';
      case ZodiacSign.libra:
        return '♎';
      case ZodiacSign.scorpio:
        return '♏';
      case ZodiacSign.sagittarius:
        return '♐';
      case ZodiacSign.capricorn:
        return '♑';
      case ZodiacSign.aquarius:
        return '♒';
      case ZodiacSign.pisces:
        return '♓';
    }
  }

  /// Get daily palm insight based on moon sign (Turkish) - For users WITH palm analysis
  String getDailyInsightTr(ZodiacSign moonSign) {
    switch (moonSign) {
      case ZodiacSign.aries:
        return 'Bugün Kalp Çizginiz aktif! Duygusal kararlar almak için ideal bir gün.';
      case ZodiacSign.taurus:
        return 'Venüs Tepeniz ön planda. Sanatsal ve romantik enerjiler güçlü.';
      case ZodiacSign.gemini:
        return 'Akıl Çizginiz parlıyor! İletişim ve öğrenme için mükemmel bir gün.';
      case ZodiacSign.cancer:
        return 'Ay Tepeniz hassas. Sezgilerinize güvenin, içsel sesinizi dinleyin.';
      case ZodiacSign.leo:
        return 'Güneş Çizginiz aktif! Yaratıcılık ve özgüven dorukta.';
      case ZodiacSign.virgo:
        return 'Sağlık Çizginiz ön planda. Kendinize bakım için ideal gün.';
      case ZodiacSign.libra:
        return 'Evlilik Çizgileriniz parlıyor. İlişkilerde denge ve uyum arayın.';
      case ZodiacSign.scorpio:
        return 'Kader Çizginiz güçlü! Derin dönüşümler için hazır olun.';
      case ZodiacSign.sagittarius:
        return 'Jüpiter Tepeniz aktif. Macera ve keşif zamanı!';
      case ZodiacSign.capricorn:
        return 'Satürn Tepeniz güçlü. Kariyer hedeflerinize odaklanın.';
      case ZodiacSign.aquarius:
        return 'Sezgi Çizginiz parlıyor! Yenilikçi fikirler için açık olun.';
      case ZodiacSign.pisces:
        return 'Ay Tepeniz çok hassas. Rüyalarınız önemli mesajlar taşıyabilir.';
    }
  }

  /// Get daily palm insight based on moon sign (English) - For users WITH palm analysis
  String getDailyInsightEn(ZodiacSign moonSign) {
    switch (moonSign) {
      case ZodiacSign.aries:
        return 'Your Heart Line is active today! Ideal day for emotional decisions.';
      case ZodiacSign.taurus:
        return 'Your Mount of Venus is prominent. Artistic and romantic energies are strong.';
      case ZodiacSign.gemini:
        return 'Your Head Line is shining! Perfect day for communication and learning.';
      case ZodiacSign.cancer:
        return 'Your Mount of Moon is sensitive. Trust your intuition, listen to your inner voice.';
      case ZodiacSign.leo:
        return 'Your Sun Line is active! Creativity and confidence are at peak.';
      case ZodiacSign.virgo:
        return 'Your Health Line is prominent. Ideal day for self-care.';
      case ZodiacSign.libra:
        return 'Your Marriage Lines are glowing. Seek balance and harmony in relationships.';
      case ZodiacSign.scorpio:
        return 'Your Fate Line is strong! Be ready for deep transformations.';
      case ZodiacSign.sagittarius:
        return 'Your Mount of Jupiter is active. Time for adventure and exploration!';
      case ZodiacSign.capricorn:
        return 'Your Mount of Saturn is strong. Focus on career goals.';
      case ZodiacSign.aquarius:
        return 'Your Intuition Line is glowing! Be open to innovative ideas.';
      case ZodiacSign.pisces:
        return 'Your Mount of Moon is very sensitive. Your dreams may carry important messages.';
    }
  }

  /// Get general daily insight (NO palm references) - For users WITHOUT palm analysis
  String getGeneralDailyInsightTr(ZodiacSign moonSign) {
    switch (moonSign) {
      case ZodiacSign.aries:
        return 'Bugün cesaret ve inisiyatif enerjiniz yüksek! Yeni projelere başlamak için ideal.';
      case ZodiacSign.taurus:
        return 'Güzellik ve konfor arayışınız ön planda. Kendinizi şımartın.';
      case ZodiacSign.gemini:
        return 'İletişim ve öğrenme için harika bir gün! Yeni bilgiler keşfedin.';
      case ZodiacSign.cancer:
        return 'Duygusal derinlik ve sezgiler güçlü. İç sesinize kulak verin.';
      case ZodiacSign.leo:
        return 'Yaratıcılık ve özgüven dorukta! Kendinizi ifade etmekten çekinmeyin.';
      case ZodiacSign.virgo:
        return 'Detaylara dikkat ve öz bakım günü. Sağlığınıza özen gösterin.';
      case ZodiacSign.libra:
        return 'İlişkilerde uyum ve denge arayışı. Sevdiklerinizle kaliteli zaman geçirin.';
      case ZodiacSign.scorpio:
        return 'Derin düşünceler ve dönüşüm enerjisi. İçsel yolculuğa çıkın.';
      case ZodiacSign.sagittarius:
        return 'Macera ve keşif ruhu yüksek! Yeni deneyimlere açık olun.';
      case ZodiacSign.capricorn:
        return 'Kariyer ve hedefler ön planda. Uzun vadeli planlar yapın.';
      case ZodiacSign.aquarius:
        return 'Yenilikçi fikirler ve özgür düşünce. Sıra dışı çözümler bulun.';
      case ZodiacSign.pisces:
        return 'Hayal gücü ve ruhani bağlantılar güçlü. Rüyalarınıza dikkat edin.';
    }
  }

  /// Get general daily insight (NO palm references) - For users WITHOUT palm analysis
  String getGeneralDailyInsightEn(ZodiacSign moonSign) {
    switch (moonSign) {
      case ZodiacSign.aries:
        return 'Your courage and initiative energy is high today! Ideal for starting new projects.';
      case ZodiacSign.taurus:
        return 'Beauty and comfort seeking is prominent. Treat yourself today.';
      case ZodiacSign.gemini:
        return 'Great day for communication and learning! Discover new information.';
      case ZodiacSign.cancer:
        return 'Emotional depth and intuition are strong. Listen to your inner voice.';
      case ZodiacSign.leo:
        return 'Creativity and confidence at peak! Don\'t hesitate to express yourself.';
      case ZodiacSign.virgo:
        return 'Day for attention to detail and self-care. Take care of your health.';
      case ZodiacSign.libra:
        return 'Seeking harmony and balance in relationships. Spend quality time with loved ones.';
      case ZodiacSign.scorpio:
        return 'Deep thoughts and transformation energy. Embark on an inner journey.';
      case ZodiacSign.sagittarius:
        return 'Adventure and exploration spirit is high! Be open to new experiences.';
      case ZodiacSign.capricorn:
        return 'Career and goals are prominent. Make long-term plans.';
      case ZodiacSign.aquarius:
        return 'Innovative ideas and free thinking. Find unconventional solutions.';
      case ZodiacSign.pisces:
        return 'Imagination and spiritual connections are strong. Pay attention to your dreams.';
    }
  }

  /// Get moon phase palm insight (Turkish) - For users WITH palm analysis
  String getMoonPhaseInsightTr(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Yeni başlangıçlar için ideal! Kader Çizginiz yeni yollar açmaya hazır.';
      case MoonPhase.waxingCrescent:
        return 'Niyetlerinizi belirleyin. Yaşam Çizginiz büyüme enerjisi taşıyor.';
      case MoonPhase.firstQuarter:
        return 'Harekete geçme zamanı! Akıl Çizginiz kararlar için güçlü.';
      case MoonPhase.waxingGibbous:
        return 'Sabırlı olun, sonuçlar yaklaşıyor. Güneş Çizginiz parlamak üzere.';
      case MoonPhase.fullMoon:
        return 'Duygusal doruk noktası! Kalp Çizginiz en güçlü halinde.';
      case MoonPhase.waningGibbous:
        return 'Şükran zamanı. Venüs Tepeniz minnettarlık enerjisi taşıyor.';
      case MoonPhase.lastQuarter:
        return 'Bırakma zamanı. Eski kalıpları serbest bırakın.';
      case MoonPhase.waningCrescent:
        return 'Dinlenme ve yenilenme. Ay Tepeniz içsel huzur arıyor.';
    }
  }

  /// Get moon phase palm insight (English) - For users WITH palm analysis
  String getMoonPhaseInsightEn(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Ideal for new beginnings! Your Fate Line is ready to open new paths.';
      case MoonPhase.waxingCrescent:
        return 'Set your intentions. Your Life Line carries growth energy.';
      case MoonPhase.firstQuarter:
        return 'Time to take action! Your Head Line is strong for decisions.';
      case MoonPhase.waxingGibbous:
        return 'Be patient, results are approaching. Your Sun Line is about to shine.';
      case MoonPhase.fullMoon:
        return 'Emotional peak! Your Heart Line is at its strongest.';
      case MoonPhase.waningGibbous:
        return 'Time for gratitude. Your Mount of Venus carries thankfulness energy.';
      case MoonPhase.lastQuarter:
        return 'Time to let go. Release old patterns.';
      case MoonPhase.waningCrescent:
        return 'Rest and renewal. Your Mount of Moon seeks inner peace.';
    }
  }

  /// Get general moon phase insight (NO palm references) - For users WITHOUT palm analysis
  String getGeneralMoonPhaseInsightTr(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Yeni başlangıçlar için ideal! Bu dönem niyetlerinizi belirleyin.';
      case MoonPhase.waxingCrescent:
        return 'Niyetlerinizi hayata geçirme zamanı. Küçük adımlarla ilerleyin.';
      case MoonPhase.firstQuarter:
        return 'Harekete geçme zamanı! Kararlar almak için enerjiniz yüksek.';
      case MoonPhase.waxingGibbous:
        return 'Sabırlı olun, sonuçlar yaklaşıyor. Çalışmalarınız meyve verecek.';
      case MoonPhase.fullMoon:
        return 'Duygusal doruk noktası! Tamamlama ve kutlama zamanı.';
      case MoonPhase.waningGibbous:
        return 'Şükran zamanı. Sahip olduklarınız için minnettarlık hissedin.';
      case MoonPhase.lastQuarter:
        return 'Bırakma zamanı. Artık işe yaramayan şeyleri geride bırakın.';
      case MoonPhase.waningCrescent:
        return 'Dinlenme ve yenilenme. Kendinize zaman ayırın ve içsel huzur bulun.';
    }
  }

  /// Get general moon phase insight (NO palm references) - For users WITHOUT palm analysis
  String getGeneralMoonPhaseInsightEn(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Ideal for new beginnings! Set your intentions during this period.';
      case MoonPhase.waxingCrescent:
        return 'Time to put intentions into action. Take small steps forward.';
      case MoonPhase.firstQuarter:
        return 'Time to take action! Your energy for making decisions is high.';
      case MoonPhase.waxingGibbous:
        return 'Be patient, results are approaching. Your efforts will bear fruit.';
      case MoonPhase.fullMoon:
        return 'Emotional peak! Time for completion and celebration.';
      case MoonPhase.waningGibbous:
        return 'Time for gratitude. Feel thankful for what you have.';
      case MoonPhase.lastQuarter:
        return 'Time to let go. Leave behind what no longer serves you.';
      case MoonPhase.waningCrescent:
        return 'Rest and renewal. Take time for yourself and find inner peace.';
    }
  }

  /// Get days until next full moon
  int getDaysUntilFullMoon() {
    final moonAge = _calculateMoonAge(DateTime.now());
    const fullMoonDay = 14.765; // Full moon occurs around day 14.765 of the cycle

    if (moonAge < fullMoonDay) {
      return (fullMoonDay - moonAge).ceil();
    } else {
      return (29.53 - moonAge + fullMoonDay).ceil();
    }
  }

  /// Get days until next new moon
  int getDaysUntilNewMoon() {
    final moonAge = _calculateMoonAge(DateTime.now());
    return (29.53 - moonAge).ceil();
  }
}

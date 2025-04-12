class PalmAnalysis {
  final String analysis;
  final DateTime createdAt;
  final String? imagePath; // Resim dosyasının yolu

  PalmAnalysis({
    required this.analysis, 
    DateTime? createdAt,
    this.imagePath, // Resim dosyası yolu parametresi eklendi
  }) : createdAt = createdAt ?? DateTime.now();

  factory PalmAnalysis.fromJson(Map<String, dynamic> json) {
    return PalmAnalysis(
      analysis: json['analysis'],
      createdAt: DateTime.parse(json['createdAt']),
      imagePath: json['imagePath'], // JSON'dan resim yolunu al
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis, 
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath, // Resim yolunu JSON'a ekle
    };
  }
}

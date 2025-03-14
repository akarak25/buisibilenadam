class PalmAnalysis {
  final String analysis;
  final DateTime createdAt;

  PalmAnalysis({required this.analysis, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  factory PalmAnalysis.fromJson(Map<String, dynamic> json) {
    return PalmAnalysis(
      analysis: json['analysis'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'analysis': analysis, 'createdAt': createdAt.toIso8601String()};
  }
}

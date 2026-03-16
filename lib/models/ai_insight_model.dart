class AiInsightModel {
  final String insight;
  final String generatedAt;
  final bool cached;

  const AiInsightModel({
    required this.insight,
    required this.generatedAt,
    required this.cached,
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      insight: json['insight'] as String? ?? '',
      generatedAt: json['generated_at'] as String? ?? '',
      cached: json['cached'] as bool? ?? false,
    );
  }
}

class BudgetModel {
  final String id;
  final String contextId;
  final int amount;
  final String month; // "YYYY-MM"
  final DateTime createdAt;

  const BudgetModel({
    required this.id,
    required this.contextId,
    required this.amount,
    required this.month,
    required this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    // month comes as full ISO date "2025-03-01T00:00:00Z", extract "YYYY-MM"
    final rawMonth = json['month'] as String;
    final month = rawMonth.length >= 7 ? rawMonth.substring(0, 7) : rawMonth;
    return BudgetModel(
      id: json['id'] as String,
      contextId: json['context_id'] as String,
      amount: (json['amount'] as num).toInt(),
      month: month,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get formattedAmount {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }
}

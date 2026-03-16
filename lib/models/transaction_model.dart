class TransactionModel {
  final String id;
  final String userId;
  final String contextId;
  final int amount; // in Rupiah (smallest unit)
  final String category;
  final String? merchant;
  final String? notes;
  final String? receiptUrl;
  final bool isReimbursable;
  final String reimbursementStatus; // none/pending/approved/rejected
  final bool isPrivate;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.contextId,
    required this.amount,
    required this.category,
    this.merchant,
    this.notes,
    this.receiptUrl,
    required this.isReimbursable,
    required this.reimbursementStatus,
    required this.isPrivate,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contextId: json['context_id'] as String,
      amount: (json['amount'] as num).toInt(),
      category: json['category'] as String,
      merchant: json['merchant'] as String?,
      notes: json['notes'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      isReimbursable: json['is_reimbursable'] as bool? ?? false,
      reimbursementStatus: json['reimbursement_status'] as String? ?? 'none',
      isPrivate: json['is_private'] as bool? ?? false,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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

  String get formattedDate {
    final now = DateTime.now();
    final local = transactionDate.toLocal();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    if (diff == 0) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    } else if (diff == 1) {
      return 'Kemarin';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${local.day} ${months[local.month - 1]}';
  }

  String get reimbursementLabel {
    switch (reimbursementStatus) {
      case 'pending':
        return 'Tunggu Reimburse';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Pribadi';
    }
  }
}

class ReimbursementSummaryItem {
  final String status;
  final int count;
  final int totalAmount;

  const ReimbursementSummaryItem({
    required this.status,
    required this.count,
    required this.totalAmount,
  });

  factory ReimbursementSummaryItem.fromJson(Map<String, dynamic> json) {
    return ReimbursementSummaryItem(
      status: json['status'] as String,
      count: (json['count'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toInt(),
    );
  }

  String get formattedTotal {
    final s = totalAmount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }
}

class CategorySummaryItem {
  final String category;
  final int totalAmount;
  final int count;

  const CategorySummaryItem({
    required this.category,
    required this.totalAmount,
    required this.count,
  });

  factory CategorySummaryItem.fromJson(Map<String, dynamic> json) {
    return CategorySummaryItem(
      category: json['category'] as String,
      totalAmount: (json['total_amount'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );
  }

  String get formattedTotal {
    final s = totalAmount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }
}

class MonthlySummaryModel {
  final String month; // "YYYY-MM"
  final int totalAmount;
  final int count;

  const MonthlySummaryModel({
    required this.month,
    required this.totalAmount,
    required this.count,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      month: json['month'] as String,
      totalAmount: (json['total_amount'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );
  }

  String get formattedTotal {
    final s = totalAmount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }
}

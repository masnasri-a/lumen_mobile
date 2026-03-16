class ContextMemberModel {
  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // owner/admin/member
  final DateTime joinedAt;

  const ContextMemberModel({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  factory ContextMemberModel.fromJson(Map<String, dynamic> json) {
    return ContextMemberModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  String get roleLabel {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      default:
        return 'Member';
    }
  }
}

class FinanceContextModel {
  final String id;
  final String ownerId;
  final String type; // personal/couple/team
  final String name;
  final DateTime createdAt;
  final List<ContextMemberModel> members;

  const FinanceContextModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.name,
    required this.createdAt,
    this.members = const [],
  });

  factory FinanceContextModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>?;
    return FinanceContextModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      members: rawMembers
              ?.map((m) => ContextMemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isPersonal => type == 'personal';
  bool get isCouple => type == 'couple';
  bool get isTeam => type == 'team';
}

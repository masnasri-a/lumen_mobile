class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
      };
}

class UserData {
  final String userId;
  final String email;
  final String login;
  final String phone;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  UserData({
    required this.userId,
    required this.email,
    required this.login,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  // Геттер для проверки, является ли пользователь администратором
  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      login: json['login']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      role: json['role']?.toString() ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'login': login,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

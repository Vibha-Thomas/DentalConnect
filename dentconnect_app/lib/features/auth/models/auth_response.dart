class AuthResponse {
  final String userId;
  final String? email;
  final String? displayName;
  final String role;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.userId,
    this.email,
    this.displayName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        userId: json['userId'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
        role: json['role'] as String,
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  @override
  String toString() =>
      'AuthResponse(userId: $userId, email: $email, role: $role)';
}

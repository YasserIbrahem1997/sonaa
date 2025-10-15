class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? photoUrl;

  final String? userType; // ✅ جديد
  final bool isActive; // ✅ جديد

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.photoUrl,
    this.userType = 'individual', // ✅
    this.isActive = false, // ✅
  });

  factory UserModel.fromSupabaseUser(dynamic user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'],
      phoneNumber: user.userMetadata?['phone_number'],
      photoUrl: user.userMetadata?['avatar_url'],
      userType: user.userMetadata?['user_type'] ?? 'individual', // ✅
      isActive: user.userMetadata?['is_active'] ?? false, // ✅

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
    };
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // ========== Email & Password ==========

  // تسجيل دخول بالإيميل
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel.fromSupabaseUser(response.user);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // إنشاء حساب جديد
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String userType = 'individual',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo:
        'https://static.vecteezy.com/system/resources/previews/010/011/934/non_2x/has-been-unlock-login-success-concept-illustration-flat-design-eps10-modern-graphic-element-for-landing-page-empty-state-ui-infographic-icon-vector.jpg',
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'user_type': userType,
          'is_active': false,
        },
      );

      // ✅ لو رجع خطأ أن الإيميل مستخدم بالفعل
      if (response.user == null && response.session == null) {
        print("teeeeeeeeeeeeeeeeest");
        throw Exception('Email is already registered');
      }

      return response.user != null
          ? UserModel.fromSupabaseUser(response.user)
          : null;
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw Exception('This email is already registered');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }


  // ========== Google Sign-In ==========

  Future<UserModel?> signInWithGoogle() async {
    try {
      // Web Flow (الأسهل والأفضل)

      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.externalApplication,
        redirectTo: 'io.supabase.sonaa://login-callback',
      );

      // انتظر المستخدم يسجل دخول
      await Future.delayed(const Duration(seconds: 2));

      final user = _supabase.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ========== Phone Authentication ==========

  // إرسال OTP
  Future<void> sendOTP(String phoneNumber) async {
    try {
      // تنسيق الرقم (للأرقام المصرية)
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+2$formattedPhone';
      }

      await _supabase.auth.signInWithOtp(

        phone: formattedPhone,
      );
    } catch (e) {
      rethrow;
    }
  }

  // التحقق من OTP
  Future<UserModel?> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+2$formattedPhone';
      }

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        return UserModel.fromSupabaseUser(response.user);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ========== Utilities ==========

  // الحصول على المستخدم الحالي
  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabaseUser(user);
    }
    return null;
  }

  // التحقق من تسجيل الدخول
  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // الاستماع لتغييرات حالة المستخدم
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}

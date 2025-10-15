import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  // Controllers للـ Forms
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  AuthCubit({required this.authRepository}) : super(const AuthInitial()) {
    // تحقق من المستخدم الحالي عند البداية
    _checkCurrentUser();
  }

  // تحقق من المستخدم المسجل
  void _checkCurrentUser() {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(
        user: user,
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    }
  }

  // التبديل بين Login و Register
  void toggleTab(bool loginSelected) {
    if (state is AuthInitial || state is AuthError) {
      emit(AuthInitial(
        isLogin: loginSelected,
        showPassword: state.showPassword,
      ));
    }
  }
// في auth_cubit.dart - أضف:
  void selectUserType(String type) {
    if (state is AuthInitial) {
      emit(AuthInitial(
        isLogin: state.isLogin,
        showPassword: state.showPassword,
        selectedUserType: type, // ✅
      ));
    } else if (state is AuthError) {
      emit(AuthError(
        message: (state as AuthError).message,
        isLogin: state.isLogin,
        showPassword: state.showPassword,
        selectedUserType: type, // ✅
      ));
    }
  }
  // إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    if (state is AuthInitial) {
      emit(AuthInitial(
        isLogin: state.isLogin,
        showPassword: !state.showPassword,
      ));
    } else if (state is AuthError) {
      emit(AuthError(
        message: (state as AuthError).message,
        isLogin: state.isLogin,
        showPassword: !state.showPassword,
      ));
    }
  }

  // ========== Email Authentication ==========

  Future<void> signInWithEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      emit(AuthError(
        message: 'Please fill all fields',
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
      return;
    }

    emit(AuthLoading(isLogin: state.isLogin, showPassword: state.showPassword));

    try {
      final user = await authRepository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null) {
        emit(AuthAuthenticated(
          user: user,
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
        _clearControllers();
      } else {
        emit(AuthError(
          message: 'Invalid credentials',
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
      }
    } catch (e) {
      emit(AuthError(
        message: _getErrorMessage(e),
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    }
  }

  Future<void> signUpWithEmail() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        fullNameController.text.isEmpty || state.selectedUserType.isEmpty) {
      emit(AuthError(
        message: 'Please fill all required fields',
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
      return;
    }

    if (passwordController.text.length < 6) {
      emit(AuthError(
        message: 'Password must be at least 6 characters',
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
      return;
    }

    emit(AuthLoading(isLogin: state.isLogin, showPassword: state.showPassword));

    try {
      final user = await authRepository.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        userType: state.selectedUserType, // ✅ أضف هنا

      );

      if (user != null) {
        emit(AuthAuthenticated(
          user: user,
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
        _clearControllers();
       phoneController.clear();
      } else {
        emit(AuthError(
          message: 'Registration failed',
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
      }
    } catch (e) {
      emit(AuthError(
        message: _getErrorMessage(e),
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    }
  }

  // ========== Google Sign-In ==========

  Future<void> signInWithGoogle() async {
    emit(AuthLoading(isLogin: state.isLogin, showPassword: state.showPassword));

    try {
      final user = await authRepository.signInWithGoogle();

      if (user != null) {
        emit(AuthAuthenticated(
          user: user,
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
      } else {
        emit(AuthError(
          message: 'Google sign-in failed',
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
      }
    } catch (e) {
      emit(AuthError(
        message: _getErrorMessage(e),
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    }
  }

  // ========== Phone Authentication ==========

  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      emit(AuthError(
        message: 'Please enter phone number',
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
      return;
    }

    emit(AuthLoading(isLogin: state.isLogin, showPassword: state.showPassword));

    try {
      await authRepository.sendOTP(phoneController.text.trim());

      emit(OTPSent(
        phoneNumber: phoneController.text.trim(),
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    } catch (e) {
      print("this mass  "+e.toString());
      emit(AuthError(
        message: _getErrorMessage(e),
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      emit(AuthError(
        message: 'Please enter OTP code',
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
      return;
    }

    if (state is! OTPSent) return;

    emit(AuthLoading(isLogin: state.isLogin, showPassword: state.showPassword));

    try {
      final user = await authRepository.verifyOTP(
        phoneNumber: (state as OTPSent).phoneNumber,
        otp: otpController.text.trim(),
      );

      if (user != null) {
        emit(AuthAuthenticated(
          user: user,
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
        _clearControllers();
      } else {
        emit(AuthError(
          message: 'Invalid OTP code',
          isLogin: state.isLogin,
          showPassword: state.showPassword,
        ));
      }
    } catch (e) {
      emit(AuthError(
        message: _getErrorMessage(e),
        isLogin: state.isLogin,
        showPassword: state.showPassword,
      ));
    }
  }

  // ========== Sign Out ==========

  Future<void> signOut() async {
    await authRepository.signOut();
    _clearControllers();
    emit(const AuthInitial());
  }

  // ========== Utilities ==========

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    otpController.clear();
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('invalid login credentials') ||
        errorStr.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (errorStr.contains('email already registered') ||
        errorStr.contains('user_already_exists')) {
      return 'البريد الإلكتروني مسجل مسبقاً';
    } else if (errorStr.contains('weak password')) {
      return 'كلمة المرور ضعيفة';
    } else if (errorStr.contains('invalid email')) {
      return 'البريد الإلكتروني غير صحيح';
    } else if (errorStr.contains('network')) {
      return 'خطأ في الاتصال بالإنترنت';
    } else if (errorStr.contains('otp')) {
      print(errorStr.contains('otp'));
      return 'كود التحقق غير صحيح';
    }
print('حدث خطأ: ${error.toString()}');
    return 'حدث خطأ: ${error.toString()}';
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    return super.close();
  }
}
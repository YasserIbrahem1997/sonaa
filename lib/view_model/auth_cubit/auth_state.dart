import 'package:equatable/equatable.dart';
import '../../data/model/user_model.dart';

abstract class AuthState extends Equatable {
  final bool isLogin;
  final bool showPassword;
  final String selectedUserType; // ✅ جديد


  const AuthState({
    this.isLogin = true,
    this.showPassword = false,
    this.selectedUserType = 'individual', // ✅ القيمة الافتراضية

  });

  @override
  List<Object?> get props => [isLogin, showPassword, selectedUserType];
}

class AuthInitial extends AuthState {
  const AuthInitial({
    super.isLogin,
    super.showPassword,
    super.selectedUserType,
  });}

class AuthLoading extends AuthState {
  const AuthLoading({super.isLogin, super.showPassword});
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({
    required this.user,
    super.isLogin,
    super.showPassword,
  });

  @override
  List<Object?> get props => [user, isLogin, showPassword];
}

class OTPSent extends AuthState {
  final String phoneNumber;

  const OTPSent({
    required this.phoneNumber,
    super.isLogin,
    super.showPassword,
  });

  @override
  List<Object?> get props => [phoneNumber, isLogin, showPassword];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({
    required this.message,
    super.isLogin,
    super.showPassword,
    super.selectedUserType,
  });

  @override
  List<Object?> get props => [message, isLogin, showPassword, selectedUserType];
}
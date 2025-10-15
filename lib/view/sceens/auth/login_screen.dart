import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../view_model/auth_cubit/auth_cubit.dart';
import '../../../view_model/auth_cubit/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import 'phone_auth_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // عرض رسائل الخطأ
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // الانتقال للصفحة الرئيسية عند النجاح
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('مرحباً ${state.user.fullName ?? state.user.email}!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // الانتقال للصفحة الرئيسية
          Navigator.of(context).pushReplacementNamed('/home');
        }

        // الانتقال لشاشة OTP
        if (state is OTPSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: const PhoneAuthScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: Column(
                  children: [
                    Image.asset('assets/images/splash.png', height: 100),
                    const SizedBox(height: 16),
                    Text(
                      state.isLogin ? 'Welcome Back' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.isLogin
                          ? 'Sign in to continue'
                          : 'Register to get started',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFE0F7FA),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => cubit.toggleTab(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: state.isLogin
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: state.isLogin
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => cubit.toggleTab(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !state.isLogin
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: !state.isLogin
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (state.isLogin)
                      _buildLoginForm(context, state, cubit, isLoading)
                    else
                      _buildRegisterForm(context, state, cubit, isLoading),
                  ],
                ),
              ),

              // Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(
      BuildContext context,
      AuthState state,
      AuthCubit cubit,
      bool isLoading,
      ) {
    return Column(
      children: [
        CustomInput(
          label: "Email",
          hint: "Enter your email",
          controller: cubit.emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: "Password",
          hint: "Enter your password",
          controller: cubit.passwordController,
          obscureText: !state.showPassword,
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              state.showPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: cubit.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isLoading ? null : () {
              // TODO: Forgot Password
            },
            child: Text(
              "Forgot Password?",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomButton(
          text: "Sign In",
          onPressed: isLoading ? null : cubit.signInWithEmail,
        ),
        const SizedBox(height: 20),
        const Text("Or continue with", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        CustomButton(
          text: "Sign in with Google",
          onPressed: isLoading ? null : cubit.signInWithGoogle,
          isPrimary: false,
          icon: Icons.g_mobiledata,
        ),
        const SizedBox(height: 12),
        // CustomButton(
        //   text: "Sign in with Phone",
        //   onPressed: isLoading
        //       ? null
        //       : () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (_) => BlocProvider.value(
        //           value: cubit,
        //           child: const PhoneAuthScreen(),
        //         ),
        //       ),
        //     );
        //   },
        //   isPrimary: false,
        //   icon: Icons.phone,
        // ),
      ],
    );
  }

  Widget _buildRegisterForm(
      BuildContext context,
      AuthState state,
      AuthCubit cubit,
      bool isLoading,
      ) {
    return Column(
      children: [
        CustomInput(
          label: "Full Name",
          hint: "Enter your full name",
          controller: cubit.fullNameController,
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: "Email",
          hint: "Enter your email",
          controller: cubit.emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: "Phone Number (Optional)",
          hint: "Enter your phone number",
          controller: cubit.phoneController,
          keyboardType: TextInputType.phone,
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.phone, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: "Password",
          hint: "Create a password (min 6 characters)",
          controller: cubit.passwordController,
          obscureText: !state.showPassword,
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              state.showPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: cubit.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 16),
        // في login_screen.dart - داخل _buildRegisterForm بعد Full Name:
        const SizedBox(height: 16),

// ✅ اختيار نوع المستخدم
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading ? null : () => cubit.selectUserType('individual'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: state.selectedUserType == 'individual'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.selectedUserType == 'individual'
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: state.selectedUserType == 'individual'
                                  ? Colors.white
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Individual',
                              style: TextStyle(
                                color: state.selectedUserType == 'individual'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading ? null : () => cubit.selectUserType('company'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: state.selectedUserType == 'company'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.selectedUserType == 'company'
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business,
                              color: state.selectedUserType == 'company'
                                  ? Colors.white
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Company',
                              style: TextStyle(
                                color: state.selectedUserType == 'company'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: "Create Account",
          onPressed: isLoading ? null : cubit.signUpWithEmail,
        ),

        const SizedBox(height: 10),

        const SizedBox(height: 10),
        const Text(
          "By signing up, you agree to our Terms of Service and Privacy Policy",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
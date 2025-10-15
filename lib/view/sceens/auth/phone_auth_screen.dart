import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../view_model/auth_cubit/auth_cubit.dart';
import '../../../view_model/auth_cubit/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class PhoneAuthScreen extends StatelessWidget {
  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is AuthAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        final isLoading = state is AuthLoading;
        final isOTPSent = state is OTPSent;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Phone Authentication'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  isOTPSent ? 'Enter OTP Code' : 'Enter Phone Number',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isOTPSent
                      ? 'We sent a code to ${(state as OTPSent).phoneNumber}'
                      : 'We will send you a verification code',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                if (!isOTPSent) ...[
                  CustomInput(
                    label: "Phone Number",
                    hint: "+20 1234567890",
                    controller: cubit.phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: "Send OTP",
                    onPressed: isLoading ? null : cubit.sendOTP,
                  ),
                ] else ...[
                  CustomInput(
                    label: "OTP Code",
                    hint: "Enter 6-digit code",
                    controller: cubit.otpController,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: "Verify OTP",
                    onPressed: isLoading ? null : cubit.verifyOTP,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        cubit.phoneController.clear();
                        cubit.otpController.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Change Phone Number'),
                    ),
                  ),
                ],

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

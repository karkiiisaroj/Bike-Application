import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/atelier_button.dart';
import '../../widgets/atelier_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSwitchToRegister,
    required this.onForgotPassword,
    required this.onSubmit,
    required this.isLoading,
  });

  final VoidCallback onSwitchToRegister;
  final VoidCallback onForgotPassword;
  final void Function(String username, String password) onSubmit;
  final bool isLoading;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  late final TapGestureRecognizer _switchTap;
  late final TapGestureRecognizer _forgotTap;

  @override
  void initState() {
    super.initState();
    _switchTap = TapGestureRecognizer()..onTap = widget.onSwitchToRegister;
    _forgotTap = TapGestureRecognizer()..onTap = widget.onForgotPassword;
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _switchTap.dispose();
    _forgotTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WELCOME BACK',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.brass,
          ),
        ),
        const SizedBox(height: 22),
        AtelierTextField(
          label: 'Username',
          hint: 'your username',
          controller: _username,
        ),
        AtelierTextField(
          label: 'Password',
          hint: '••••••••',
          controller: _password,
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                color: AppColors.brass,
              ),
              children: [
                TextSpan(text: 'Forgot password?', recognizer: _forgotTap),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        widget.isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: AppColors.brass),
                ),
              )
            : AtelierButton(
                label: 'LOG IN',
                onPressed: () =>
                    widget.onSubmit(_username.text.trim(), _password.text),
              ),
        const SizedBox(height: 22),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 13,
                color: AppColors.muted,
              ),
              children: [
                const TextSpan(text: 'New to the Atelier? '),
                TextSpan(
                  text: 'Create an account',
                  style: const TextStyle(
                    color: AppColors.brass,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _switchTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

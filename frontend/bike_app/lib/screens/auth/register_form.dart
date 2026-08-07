import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/atelier_button.dart';
import '../../widgets/atelier_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.onSwitchToLogin,
    required this.onSubmit,
    required this.isLoading,
  });

  final VoidCallback onSwitchToLogin;
  final void Function({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  })
  onSubmit;
  final bool isLoading;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final TapGestureRecognizer _switchTap;

  @override
  void initState() {
    super.initState();
    _switchTap = TapGestureRecognizer()..onTap = widget.onSwitchToLogin;
  }

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _switchTap.dispose();
    super.dispose();
  }

  void _submit() {
    final parts = _name.text.trim().split(' ');
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    widget.onSubmit(
      username: _username.text.trim(),
      email: _email.text.trim(),
      firstName: first,
      lastName: last,
      password: _password.text,
      password2: _confirm.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CREATE YOUR ACCOUNT',
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
          hint: 'pick a username',
          controller: _username,
        ),
        AtelierTextField(
          label: 'Full Name',
          hint: 'Your name',
          controller: _name,
        ),
        AtelierTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        AtelierTextField(
          label: 'Password',
          hint: '••••••••',
          controller: _password,
          obscureText: true,
        ),
        AtelierTextField(
          label: 'Confirm Password',
          hint: '••••••••',
          controller: _confirm,
          obscureText: true,
        ),
        const SizedBox(height: 6),
        widget.isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: AppColors.brass),
                ),
              )
            : AtelierButton(label: 'CREATE ACCOUNT', onPressed: _submit),
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
                const TextSpan(text: 'Already riding with us? '),
                TextSpan(
                  text: 'Log in',
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

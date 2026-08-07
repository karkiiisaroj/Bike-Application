import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_controller.dart';
import '../../widgets/google_auth_button.dart';
import '../../theme/theme.dart';
import '../../widgets/atelier_button.dart';
import '../../widgets/atelier_text_field.dart';
import '../../widgets/auth_segmented_tabs.dart';
import '../home/home_screen.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _navigatedAfterGoogle = false;

  @override
  void initState() {
    super.initState();
    // Web's Google button fires through a stream, not a call we make
    // ourselves — start listening once when this screen mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().listenForWebGoogleSignIn();
    });
  }

  Future<void> _handleLogin(String username, String password) async {
    final auth = context.read<AuthController>();
    final ok = await auth.login(username, password);
    if (ok && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (mounted) {
      _showError(auth.errorMessage);
    }
  }

  Future<void> _handleGoogle() async {
    final auth = context.read<AuthController>();
    final ok = await auth.loginWithGoogle();
    if (ok && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (mounted) {
      _showError(auth.errorMessage);
    }
  }

  Future<void> _handleRegister({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  }) async {
    final auth = context.read<AuthController>();

    final ok = await auth.register(
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      password2: password2,
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
          backgroundColor: Colors.green,
        ),
      );

      // Switch back to Login form
      setState(() {
        _isLogin = true;
      });
    } else if (mounted) {
      _showError(auth.errorMessage);
    }
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Something went wrong.'),
        backgroundColor: AppColors.ember, // or Colors.red
      ),
    );
  }

  void _showForgotPassword() {
    final emailController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RESET YOUR PASSWORD',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppColors.brass,
              ),
            ),
            const SizedBox(height: 18),
            AtelierTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            AtelierButton(
              label: 'SEND RESET LINK',
              onPressed: () async {
                final auth = context.read<AuthController>();
                final ok = await auth.requestPasswordReset(
                  emailController.text.trim(),
                );
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'If that email is registered, a reset link is on its way.'
                            : (auth.errorMessage ?? 'Something went wrong.'),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final width = MediaQuery.of(context).size.width;
    final cardMaxWidth = width < 480 ? width - 40 : 500.0;

    // The web Google button completes via AuthController's stream
    // listener, not _handleGoogle — catch the status flip here and
    // navigate. _navigatedAfterGoogle guards against pushing twice if
    // build() runs again before the route change completes.
    if (auth.status == AuthStatus.authenticated && !_navigatedAfterGoogle) {
      _navigatedAfterGoogle = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthSegmentedTabs(
                      isLogin: _isLogin,
                      onChanged: (v) => setState(() => _isLogin = v),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _isLogin
                          ? LoginForm(
                              key: const ValueKey('login'),
                              onSwitchToRegister: () =>
                                  setState(() => _isLogin = false),
                              onForgotPassword: _showForgotPassword,
                              onSubmit: _handleLogin,
                              isLoading: auth.isLoading,
                            )
                          : RegisterForm(
                              key: const ValueKey('register'),
                              onSwitchToLogin: () =>
                                  setState(() => _isLogin = true),
                              onSubmit:
                                  ({
                                    required username,
                                    required email,
                                    required firstName,
                                    required lastName,
                                    required password,
                                    required password2,
                                  }) => _handleRegister(
                                    username: username,
                                    email: email,
                                    firstName: firstName,
                                    lastName: lastName,
                                    password: password,
                                    password2: password2,
                                  ),
                              isLoading: auth.isLoading,
                            ),
                    ), // <-- closes AnimatedSwitcher here, nothing else inside it
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 11,
                              letterSpacing: 1,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.line)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GoogleAuthButton(
                      isLoading: auth.isLoading,
                      onPressed: _handleGoogle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

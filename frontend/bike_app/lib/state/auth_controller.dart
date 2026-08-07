import 'dart:async';
import 'package:bike_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<GoogleSignInAccount?>? _googleSub;

  /// Call once at app start — checks for a saved token and, if present,
  /// tries to load the profile so the user doesn't have to log in again.
  Future<void> bootstrap() async {
    final token = await TokenStorage.accessToken;
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      user = await AuthService.fetchProfile();
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) => _run(() async {
    user = await AuthService.login(username: username, password: password);
    status = AuthStatus.authenticated;
  });

  Future<bool> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  }) => _run(() async {
    await AuthService.register(
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      password2: password2,
    );

    // Don't keep the user logged in after registration.
    user = null;
    status = AuthStatus.unauthenticated;
  });

  Future<bool> requestPasswordReset(String email) =>
      _run(() => AuthService.requestPasswordReset(email));

  Future<void> logout() async {
    await AuthService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.firstError;
      return false;
    } catch (_) {
      errorMessage =
          'Error: '
          'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() => _run(() async {
    user = await AuthService.signInWithGoogle();
    status = AuthStatus.authenticated;
  });

  /// Web's Google button fires through onCurrentUserChanged instead of
  /// a signIn() call we make ourselves — call this once, e.g. from
  /// AuthScreen's initState. Safe to call more than once; only
  /// subscribes on the first call.
  void listenForWebGoogleSignIn() {
    _googleSub ??= AuthService.googleSignIn.onCurrentUserChanged.listen((
      account,
    ) async {
      if (account == null) return;
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      try {
        // AuthService does not expose `exchangeGoogleAccount`; use the
        // existing signInWithGoogle flow instead.
        user = await AuthService.signInWithGoogle();
        status = AuthStatus.authenticated;
      } on ApiException catch (e) {
        errorMessage = e.firstError;
      } catch (e) {
        errorMessage = 'Error: $e';
      } finally {
        isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _googleSub?.cancel();
    super.dispose();
  }
}

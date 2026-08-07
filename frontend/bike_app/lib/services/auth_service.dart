import '../models/user_model.dart';
import 'api_client.dart';
import 'token_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<UserModel> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  }) async {
    final data = await ApiClient.post('/accounts/register/', {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password2': password2,
    });
    await TokenStorage.save(access: data['access'], refresh: data['refresh']);
    return UserModel.fromJson(data['user']);
  }

  static Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final data = await ApiClient.post('/accounts/login/', {
      'username': username,
      'password': password,
    });
    await TokenStorage.save(access: data['access'], refresh: data['refresh']);
    return UserModel.fromJson(data['user']);
  }

  static Future<void> logout() async {
    final refresh = await TokenStorage.refreshToken;
    if (refresh != null) {
      try {
        await ApiClient.post('/accounts/logout/', {
          'refresh': refresh,
        }, auth: true);
      } catch (_) {}
    }
    await TokenStorage.clear();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  static Future<void> requestPasswordReset(String email) async {
    await ApiClient.post('/accounts/password-reset/', {'email': email});
  }

  static Future<void> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    await ApiClient.post('/accounts/password-reset-confirm/', {
      'uid': uid,
      'token': token,
      'new_password': newPassword,
    });
  }

  static Future<UserModel> fetchProfile() async {
    final data = await ApiClient.get('/accounts/profile/');
    return UserModel.fromJson(data);
  }

  static Future<UserModel> updateProfile(Map<String, dynamic> patch) async {
    final data = await ApiClient.patch('/accounts/profile/', patch);
    return UserModel.fromJson(data);
  }

  static const _webClientId =
      '344178183345-ppus2ol0ng0mia71e9v3qrr76t0mrgqq.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: kIsWeb ? null : _webClientId,
  );

  static GoogleSignIn get googleSignIn => _googleSignIn;

  /// Same flow on every platform — no renderButton(), no manual plugin
  /// init. Uses the access_token (which Google reliably returns
  /// everywhere), verified server-side against Google's userinfo API.
  static Future<UserModel> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw ApiException(0, {'detail': 'Google sign-in was cancelled.'});
    }
    final googleAuth = await account.authentication;
    final accessToken = googleAuth.accessToken;
    if (accessToken == null) {
      throw ApiException(0, {'detail': 'Could not get a Google access token.'});
    }

    final data = await ApiClient.post('/accounts/google/', {
      'access_token': accessToken,
    });
    await TokenStorage.save(access: data['access'], refresh: data['refresh']);
    return UserModel.fromJson(data['user']);
  }
}

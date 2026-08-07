import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  /// Android emulator can't see "localhost" as the host machine — it needs
  /// 10.0.2.2. iOS simulator, web, and desktop can all use 127.0.0.1.
  /// Testing on a REAL device? Replace both with your machine's LAN IP,
  /// e.g. 'http://192.168.1.10:8000/api'.
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }
}

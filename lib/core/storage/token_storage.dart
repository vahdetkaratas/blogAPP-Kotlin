import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  
  // Cache for synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  bool _isInitialized = false;

  TokenStorage({required SharedPreferences sharedPreferences, required FlutterSecureStorage secureStorage}) 
      : _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage;

  Future<void> init() async {
    // Prefer secure storage; fall back to SharedPreferences if empty
    final secureAccess = await _secureStorage.read(key: _accessTokenKey);
    final secureRefresh = await _secureStorage.read(key: _refreshTokenKey);
    _cachedAccessToken = secureAccess ?? _sharedPreferences.getString(_accessTokenKey);
    _cachedRefreshToken = secureRefresh ?? _sharedPreferences.getString(_refreshTokenKey);
    _isInitialized = true;
  }

  // Synchronous method for router redirects
  bool hasTokenSync() {
    if (!_isInitialized) {
      return false;
    }
    return _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;
  }

  // Get access token
  String? getAccessToken() {
    if (!_isInitialized) {
      return null;
    }
    return _cachedAccessToken;
  }

  // Get refresh token
  String? getRefreshToken() {
    if (!_isInitialized) {
      return null;
    }
    return _cachedRefreshToken;
  }

  // Set both tokens
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Write to secure storage
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    // Also mirror to SharedPreferences for legacy compatibility
    await _sharedPreferences.setString(_accessTokenKey, accessToken);
    await _sharedPreferences.setString(_refreshTokenKey, refreshToken);
    
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
  }

  // Legacy methods for backward compatibility
  Future<void> saveToken(String token) async {
    await setTokens(accessToken: token, refreshToken: '');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _sharedPreferences.setString(_refreshTokenKey, refreshToken);
    _cachedRefreshToken = refreshToken;
  }

  Future<String?> getToken() async {
    return getAccessToken();
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _sharedPreferences.remove(_accessTokenKey);
    await _sharedPreferences.remove(_refreshTokenKey);
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
  }

  // Legacy method for backward compatibility
  Future<void> clearToken() async {
    await clear();
  }

  Future<bool> hasToken() async {
    return hasTokenSync();
  }
}

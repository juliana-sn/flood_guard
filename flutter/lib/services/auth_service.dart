import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  Map<String, dynamic>? _user;
  bool _checked = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get checked => _checked;

  Future<void> checkSession() async {
    final token = await ApiClient.getToken();
    _checked = true;
    if (token == null) {
      _user = null;
      notifyListeners();
      return;
    }
    // Token existe — considera sessão ativa (valida no próximo request)
    _user = {'token': token};
    notifyListeners();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.signup(name: name, email: email, password: password);
    _user = data['user'] as Map<String, dynamic>?;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final data = await ApiClient.login(email: email, password: password);
    _user = data['user'] as Map<String, dynamic>?;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiClient.logout();
    _user = null;
    notifyListeners();
  }
}
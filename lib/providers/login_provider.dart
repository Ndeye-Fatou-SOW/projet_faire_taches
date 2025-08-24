import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(BuildContext context, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email.trim(), password.trim());

      final data = response['data'];

      if (data != null && data['account_id'] != null) {
        final accountId = int.tryParse(data['account_id'].toString());
        final emailFromApi = data['email'] ?? email;

        if (accountId != null) {
          await AuthService.saveUserSession(emailFromApi, accountId);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("username", emailFromApi);
          await prefs.setInt("account_id", accountId);

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        } else {
          _errorMessage = 'Réponse invalide du serveur';
        }
      } else {
        _errorMessage = response['error'] ?? 'Email ou mot de passe incorrect';
      }
    } catch (e) {
      _errorMessage = 'Erreur : ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}

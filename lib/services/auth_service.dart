import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _emailKey = 'email';
  static const String _accountIdKey = 'account_id';

  static Future<void> saveUserSession(String email, int accountId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_emailKey, email);
  await prefs.setInt(_accountIdKey, accountId);
  print('Session saved: email=$email, accountId=$accountId');
}


  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_accountIdKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<int?> getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accountIdKey);
  }

  static Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final hasEmail = prefs.containsKey(_emailKey);
  final hasAccountId = prefs.containsKey(_accountIdKey);
 // print('isLoggedIn check: hasEmail=$hasEmail, hasAccountId=$hasAccountId');
  return hasEmail && hasAccountId;
}

   
  static const _tokenKey = 'auth_token';

  // Sauvegarder le token après le login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token (ce que réclame getToken)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token (utile pour logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // // Vérifier si l'utilisateur est connecté
  // static Future<bool> isLoggedIn() async {
  //   final token = await getToken();
  //   return token != null;
  // }

 
  


}

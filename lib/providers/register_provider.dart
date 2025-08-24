import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<Map<String, dynamic>> register() async {
    errorMessage = null;
    notifyListeners();

    if (emailController.text.trim().isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      errorMessage = "Veuillez entrer un email valide";
      notifyListeners();
      return {"success": false, "error": errorMessage};
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      errorMessage = "Le mot de passe doit contenir au moins 6 caractères";
      notifyListeners();
      return {"success": false, "error": errorMessage};
    }

    if (confirmPasswordController.text != passwordController.text) {
      errorMessage = "Les mots de passe ne correspondent pas";
      notifyListeners();
      return {"success": false, "error": errorMessage};
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      isLoading = false;
      notifyListeners();

      if (response['data'] != null &&
          response['data'].toString().toLowerCase().contains('reussie')) {
        return {"success": true, "data": response['data']};
      } else {
        errorMessage = response['error'] ?? "Une erreur est survenue";
        notifyListeners();
        return {"success": false, "error": errorMessage};
      }
    } catch (e) {
      isLoading = false;
      errorMessage = "Erreur : ${e.toString()}";
      notifyListeners();
      return {"success": false, "error": errorMessage};
    }
  }
}

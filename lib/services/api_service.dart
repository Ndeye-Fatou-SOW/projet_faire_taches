 import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';
import 'dart:async';
//192.168.1.119 wifi de daouda 
//wifi maison  192.168.1.8
class ApiService {
  static const String baseUrl = 'http://192.168.1.8/todo/';

   
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 100)); // Timeout de 5s
          print("Réponse brute du serveur : ${response.body}"); // <== Ajoute cette ligne


      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Erreur serveur : ${response.statusCode}'};
      }
    } on http.ClientException catch (_) {
      return {'error': 'Impossible de se connecter au serveur'};
    } on FormatException catch (_) {
      return {'error': 'Réponse serveur invalide'};
    } on TimeoutException catch (_) {
      return {'error': 'Connexion trop lente'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }


  // static Future<List<Todo>> getTodos(int accountId) async {
  //   final response = await http.post(
  //     Uri.parse('${baseUrl}todos'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'account_id': accountId}),
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = jsonDecode(response.body);
  //     return data.map((item) => Todo.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Erreur lors du chargement des tâches');
  //   }
  // }
  static Future<List<Todo>> getTodos(int accountId) async {
  final response = await http.post(
    Uri.parse('${baseUrl}todos'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'account_id': accountId}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body); // <-- récupérer le Map
    final List<dynamic> data = json['data']; // <-- extraire la vraie liste
    return data.map((item) => Todo.fromJson(item)).toList();
  } else {
    throw Exception('Erreur lors du chargement des tâches');
  }
}


  static Future<bool> insertTodo( Todo todo, int accountId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}inserttodo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account_id': accountId,
        'date': todo.date.toIso8601String(),
        'todo': todo.todo,
        'done': todo.done ? 1 : 0, 
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse('${baseUrl}updatetodo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'todo_id': todo.id,
        'date': todo.date.toIso8601String(),
        'todo': todo.todo,
        'done': todo.done ? 1 : 0, 
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteTodo(int todoId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}deletetodo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'todo_id': todoId}),
    );
    return response.statusCode == 200;
  }

    static Future<Map<String, dynamic>> register(String email, String password) async {
  final response = await http.post(
    Uri.parse('${baseUrl}register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Erreur lors de l’inscription');
  }
}

  
}

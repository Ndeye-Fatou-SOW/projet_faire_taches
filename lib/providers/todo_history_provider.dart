import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class TodoHistoryProvider extends ChangeNotifier {
  List<Todo> todos = [];
  List<Todo> filteredTodos = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTodos(int accountId) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await ApiService.getTodos(accountId);
      todos = result.where((t) => t.done).toList(); // seulement les tâches accomplies
      filteredTodos = todos;

    } catch (e) {
      errorMessage = "Erreur lors du chargement : ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id, int accountId) async {
    final success = await ApiService.deleteTodo(id);
    if (success) {
      await loadTodos(accountId);
    }
  }

  void searchTodos(String query) {
    if (query.isEmpty) {
      filteredTodos = todos;
    } else {
      filteredTodos = todos.where((todo) {
        return todo.todo.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}

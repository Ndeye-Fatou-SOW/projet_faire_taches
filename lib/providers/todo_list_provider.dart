import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class TodoListProvider extends ChangeNotifier {
  List<Todo> todos = [];
  List<Todo> filteredTodos = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTodos(int accountId) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await ApiService.getTodos(accountId);
      todos = result.where((t) => !t.done).toList(); // tâches non accomplies
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

  Future<void> markAsDone(Todo todo, int accountId) async {
    final updatedTodo = Todo(
      id: todo.id,
      accountId: todo.accountId,
      todo: todo.todo,
      date: todo.date,
      done: true,
    );
    final success = await ApiService.updateTodo(updatedTodo);
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

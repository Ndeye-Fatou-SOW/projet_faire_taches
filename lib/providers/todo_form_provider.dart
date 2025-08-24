import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../services/local_database_service.dart';

class TodoFormProvider extends ChangeNotifier {
  Todo? todo;
  int accountId;

  final TextEditingController todoController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool done = false;

  bool isLoading = false;
  String? errorMessage;

  TodoFormProvider({this.todo, required this.accountId}) {
    if (todo != null) {
      todoController.text = todo!.todo;
      selectedDate = todo!.date;
      done = todo!.done;
    }
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setDone(bool value) {
    done = value;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setDate(picked);
    }
  }

  Future<bool> saveTodo() async {
    final todoText = todoController.text.trim();
    if (todoText.isEmpty) return false;

    final newTodo = Todo(
      accountId: todo?.accountId ?? accountId,
      date: selectedDate,
      todo: todoText,
      done: done,
      id: todo?.id,
      isSynced: true,
    );

    isLoading = true;
    notifyListeners();

    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        // Hors-ligne → Sauvegarde locale
        newTodo.isSynced = false;
        await LocalDbService.insertTodo(newTodo);
        print('Tâche enregistrée hors-ligne');
        return true;
      } else {
        // En ligne → API + synchronisation locale
        bool success;
        if (todo == null) {
          success = await ApiService.insertTodo(newTodo, accountId);
        } else {
          success = await ApiService.updateTodo(newTodo);
        }

        if (success) {
          newTodo.isSynced = true;
          await LocalDbService.insertTodo(newTodo);
          print('Tâche enregistrée en ligne');
          return true;
        }
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

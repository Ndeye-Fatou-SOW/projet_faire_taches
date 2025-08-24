import 'package:flutter/material.dart';
//import 'package:projet_todo_m1/providers/todo_form_provider.dart';
import 'package:provider/provider.dart';
//import '../models/todo.dart';
import '../pages/todo_form.dart';
import '../providers/todo_list_provider.dart';

class TodoListPage extends StatelessWidget {
  final int accountId;
  const TodoListPage({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = TodoListProvider();
        provider.loadTodos(accountId); // 🔥 charge dès l’ouverture
        return provider;
      },
      child: Consumer<TodoListProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Liste des tâches",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.cyanAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              elevation: 4,
            ),
            body: Column(
              children: [
                // 🔎 Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Rechercher une tâche...',
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    onChanged: provider.searchTodos,
                  ),
                ),
                // 📋 Liste des tâches
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                          ? Center(
                              child: Text(
                                provider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                dataRowHeight: 60,
                                headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
                                columns: const [
                                  DataColumn(label: Text("ID")),
                                  DataColumn(label: Text("Tâche")),
                                  DataColumn(label: Text("Date")),
                                  DataColumn(label: Text("Modifier")),
                                  DataColumn(label: Text("Supprimer")),
                                  DataColumn(label: Text("Accomplir")),
                                ],
                                rows: provider.filteredTodos.map((todo) {
                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>(
                                        (states) => todo.done ? Colors.green[50] : null),
                                    cells: [
                                      DataCell(Text(todo.id?.toString() ?? "")),
                                      DataCell(Text(
                                        todo.todo,
                                        style: TextStyle(
                                          decoration: todo.done
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      )),
                                      DataCell(Text(todo.date.toLocal().toString().split(' ')[0])),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => TodoFormPage(
                                                  todo: todo,
                                                  accountId: accountId,
                                                ),
                                              ),
                                            ).then((_) => provider.loadTodos(accountId));
                                          },
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => provider.deleteTodo(todo.id!, accountId),
                                        ),
                                      ),
                                      DataCell(
                                        Radio<bool>(
                                          value: true,
                                          groupValue: todo.done,
                                          onChanged: (_) => provider.markAsDone(todo, accountId),
                                          activeColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


 
 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_form_provider.dart';
import '../pages/Todo_Liste_Page.dart';
import '../pages/Todo_History_Page.dart';

class TodoFormPage extends StatelessWidget {
  final int accountId;
  final dynamic todo;

  const TodoFormPage({Key? key, this.todo, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoFormProvider(todo: todo, accountId: accountId),
      child: Consumer<TodoFormProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(provider.todo == null ? 'Nouvelle tâche' : 'Modifier la tâche'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.cyanAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.list),
                                label: const Text("Liste des tâches"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TodoListPage(accountId: accountId),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.history),
                                label: const Text("Historique"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TodoHistoryPage(accountId: accountId),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Formulaire
                        TextField(
                          controller: provider.todoController,
                          decoration: const InputDecoration(labelText: 'Tâche à réaliser'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text("Date : ${provider.selectedDate.toLocal().toString().split(' ')[0]}"),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => provider.pickDate(context),
                            ),
                          ],
                        ),
                         CheckboxListTile(
  title: const Text('Tâche accomplie'),
  value: provider.done,
  onChanged: (bool? value) {
    if (value != null) {
      provider.setDone(value);
    }
  },
),

                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success = await provider.saveTodo();
                              if (success && context.mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text("Enregistrer"),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}


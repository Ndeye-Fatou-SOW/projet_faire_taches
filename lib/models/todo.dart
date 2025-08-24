 class Todo {
  int? localId; // ID local (SQLite)
  int? id; // ID serveur (todo_id)
  int? accountId;
  String todo;
  DateTime date;
  bool done;
  bool isSynced; // false = pas encore synchronisé
  bool isDeleted; // true = marqué pour suppression

  Todo({
    this.localId,
    this.id,
    this.accountId,
    required this.todo,
    required this.date,
    this.done = false,
    this.isSynced = false,
    this.isDeleted = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['todo_id'],
      accountId: json['account_id'],
      todo: json['todo'],
      date: DateTime.tryParse(json['date']) ?? DateTime.now(),
      done: json['done'] == 1,
      isSynced: true, // vient du serveur => déjà synchro
      isDeleted: json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'todo_id': id,
    'account_id': accountId,
    'todo': todo,
    'date': date.toIso8601String(),
    'done': done ? 1 : 0,
    'is_deleted': isDeleted ? 1 : 0,
  };

  Map<String, dynamic> toLocalJson() => {
    'local_id': localId,
    'todo_id': id,
    'account_id': accountId,
    'todo': todo,
    'date': date.toIso8601String(),
    'done': done ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'is_deleted': isDeleted ? 1 : 0,
  };

  factory Todo.fromLocalJson(Map<String, dynamic> json) {
    return Todo(
      localId: json['local_id'],
      id: json['todo_id'],
      accountId: json['account_id'],
      todo: json['todo'],
      date: DateTime.tryParse(json['date']) ?? DateTime.now(),
      done: json['done'] == 1,
      isSynced: json['is_synced'] == 1,
      isDeleted: json['is_deleted'] == 1,
    );
  }
}


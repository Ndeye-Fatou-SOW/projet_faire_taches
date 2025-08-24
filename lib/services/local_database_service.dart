import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class LocalDbService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;

    String path = join(await getDatabasesPath(), 'todos.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            local_id INTEGER PRIMARY KEY AUTOINCREMENT,
            todo_id INTEGER,
            account_id INTEGER,
            todo TEXT,
            date TEXT,
            done INTEGER,
            is_synced INTEGER,
            is_deleted INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> insertTodo(Todo todo) async {
    await init();
    return await _db!.insert('todos', todo.toLocalJson());
  }

  static Future<List<Todo>> getTodos(int accountId) async {
    await init();
    final List<Map<String, dynamic>> maps = await _db!.query(
      'todos',
      where: 'account_id = ? AND is_deleted = 0',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromLocalJson(maps[i]));
  }

  static Future<List<Todo>> getUnsyncedTodos() async {
    await init();
    final List<Map<String, dynamic>> maps =
        await _db!.query('todos', where: 'is_synced = 0');
    return List.generate(maps.length, (i) => Todo.fromLocalJson(maps[i]));
  }

  static Future<int> updateTodo(Todo todo) async {
    await init();
    return await _db!.update(
      'todos',
      todo.toLocalJson(),
      where: 'local_id = ?',
      whereArgs: [todo.localId],
    );
  }

  static Future<int> deleteTodoLocal(int localId) async {
    await init();
    return await _db!.delete('todos', where: 'local_id = ?', whereArgs: [localId]);
  }
}

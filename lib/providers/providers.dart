import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// import des providers
import 'login_provider.dart';
import 'register_provider.dart';
import 'home_provider.dart';
import 'todo_list_provider.dart';
import 'todo_history_provider.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
      ChangeNotifierProvider<RegisterProvider>(create: (_) => RegisterProvider()),
      ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
      ChangeNotifierProvider<TodoListProvider>(create: (_) => TodoListProvider()),
      ChangeNotifierProvider<TodoHistoryProvider>(create: (_) => TodoHistoryProvider()),
    ];
  }
}

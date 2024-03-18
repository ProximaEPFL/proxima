import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/todo_model.dart";

class TodosViewModel extends Notifier<List<TodoItem>> {
  @override
  List<TodoItem> build() {
    return [
      TodoItem(
        id: "1",
        name: "hey",
        dueDate: DateTime.now(),
        status: TodoStatus.done,
      ),
    ];
  }

  TodoItem getTodo(String todoId) {
    return state.firstWhere((t) => t.id == todoId);
  }

  void addTodo(TodoItem todo) {
    state = [...state, todo];
  }

  void removeTodo(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id != todoId) todo,
    ];
  }

  void updateTodo(String todoId, TodoItem newTodo) {
    state = [
      for (final todo in state)
        if (todo.id == todoId) newTodo else todo,
    ];
  }
}

final todosProvider = NotifierProvider<TodosViewModel, List<TodoItem>>(() {
  return TodosViewModel();
});

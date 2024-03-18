import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:nanoid/nanoid.dart";

import "package:proxima/models/todo_model.dart";
import "package:proxima/viewmodels/todo_viewmodel.dart";
import "package:proxima/views/components/todo_view.dart";
import "package:proxima/views/navigation/routes.dart";

class OverviewPage extends HookConsumerWidget {
  static const listKey = Key("list");
  static const addKey = Key("add");

  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Example Todo Flutter"),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView(
        key: listKey,
        children: [
          for (final todo in todos) TodoView(item: todo),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: addKey,
        onPressed: () {
          final newItem = TodoItem(
            id: nanoid(),
            name: "",
            dueDate: DateTime.now(),
            status: TodoStatus.created,
          );
          ref.read(todosProvider.notifier).addTodo(newItem);
          Navigator.pushNamed(
            context,
            Routes.editTodo.name,
            arguments: newItem.id,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

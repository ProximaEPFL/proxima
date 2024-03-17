import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/todo_viewmodel.dart";

class TodoEditPage extends HookConsumerWidget {
  static const deleteKey = Key("delete");

  final String itemId;

  const TodoEditPage({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(todosProvider.notifier);
    final todo = viewModel.getTodo(itemId);

    final nameController = useTextEditingController(text: todo.name);
    final dueDate = useState(todo.dueDate);
    final status = useState(todo.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Todo Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        child: Center(
          child: Column(
            children: [
              Text("Todo Item ID: $itemId"),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Name"),
                  hintText: "Item's name",
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      dueDate.value = await showDatePicker(
                            context: context,
                            initialDate: dueDate.value,
                            firstDate: DateTime(2015, 8),
                            lastDate: DateTime(2101),
                          ) ??
                          dueDate.value;
                    },
                    child: Text(dueDate.value.toString().split(" ").first),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      status.value = status.value.rotated;
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(status.value.icon),
                        const SizedBox(width: 10),
                        Text(status.value.text),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final updated = todo.copyWith(
                    name: nameController.text,
                    dueDate: dueDate.value,
                    status: status.value,
                  );

                  viewModel.updateTodo(itemId, updated);
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                key: deleteKey,
                onPressed: () {
                  viewModel.removeTodo(itemId);
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text("Delete"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

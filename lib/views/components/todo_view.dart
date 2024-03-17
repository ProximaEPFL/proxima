import "package:flutter/material.dart";
import "package:proxima/models/todo_model.dart";
import "package:proxima/views/navigation/routes.dart";

class TodoView extends StatelessWidget {
  final TodoItem item;

  const TodoView({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.status.icon),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.name),
          Text(item.dueDate.toString().split(" ").first),
        ],
      ),
      trailing: IconButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.editTodo.name,
            arguments: item.id,
          );
        },
        icon: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

import "package:flutter/material.dart";

enum TodoStatus {
  created("Created", Icons.file_open_outlined),
  statred("Started", Icons.pending_outlined),
  done("Finished", Icons.check);

  final String text;
  final IconData icon;

  const TodoStatus(this.text, this.icon);

  TodoStatus get rotated =>
      TodoStatus.values[(index + 1) % TodoStatus.values.length];
}

class TodoItem {
  final String id;
  final String name;
  final DateTime dueDate;
  final TodoStatus status;

  const TodoItem({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.status,
  });

  TodoItem copyWith({
    String? name,
    DateTime? dueDate,
    TodoStatus? status,
  }) {
    return TodoItem(
      id: id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}

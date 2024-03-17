import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/todo_model.dart";

void main() {
  group("Todo Model", () {
    final todo = TodoItem(
      id: "testId",
      name: "My Item",
      dueDate: DateTime(2024),
      status: TodoStatus.created,
    );

    test("TodoItem correct initialization", () {
      expect(todo.id, "testId");
    });

    test("TodoItem correct copy", () {
      final updated = todo.copyWith(name: "New name");

      expect(updated.id, "testId");
      expect(updated.dueDate, DateTime(2024));

      expect(updated.name, "New name");
    });

    test("TodoItem correct copy with", () {
      final updated = todo.copyWith(name: "New name");

      expect(updated.id, "testId");
      expect(updated.dueDate, DateTime(2024));

      expect(updated.name, "New name");
    });

    test("TodoItem correct rotation", () {
      final rotated = todo.status.rotated;
      expect(rotated, TodoStatus.statred);

      final fullRotation = todo.status.rotated.rotated.rotated;
      expect(fullRotation, todo.status);
    });
  });
}

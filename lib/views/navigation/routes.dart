import "package:flutter/material.dart";

import "package:proxima/views/routes/overview.dart";
import "package:proxima/views/routes/todo_edit_page.dart";

enum Routes {
  overview("overview"),
  editTodo("editTodo");

  final String name;

  const Routes(this.name);

  static Routes parse(String name) {
    return Routes.values.firstWhere((r) => r.name == name);
  }

  Widget page(Object? args) {
    switch (this) {
      case overview:
        return const OverviewPage();
      case editTodo:
        return TodoEditPage(itemId: args as String);
    }
  }
}

Route generateRoute(RouteSettings settings) {
  final route = Routes.parse(settings.name ?? Routes.overview.name);
  return MaterialPageRoute(builder: (_) => route.page(settings.arguments));
}

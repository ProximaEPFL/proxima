import "package:flutter/material.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login/login_page.dart";
import "package:proxima/views/pages/new_post_page.dart";

enum Routes {
  home("home"),
  login("login"),
  newPost("new post"),
  createAccount("createAccount");

  final String name;

  const Routes(this.name);

  static Routes parse(String name) {
    return Routes.values.firstWhere((r) => r.name == name);
  }

  Widget page(Object? args) {
    switch (this) {
      case home:
        return const HomePage();
      case login:
        return const LoginPage();
      case newPost:
        return const NewPostPage();
      case createAccount:
        return const CreateAccountPage();
    }
  }
}

Route generateRoute(RouteSettings settings) {
  final route = Routes.parse(settings.name!);
  return MaterialPageRoute(builder: (_) => route.page(settings.arguments));
}

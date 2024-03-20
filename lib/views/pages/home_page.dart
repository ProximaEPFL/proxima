import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_viewmodel.dart";

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    // TODO (gruvw) add logout button
    // TODO (gruvw) if user becomes null redirect

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page :)"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, ${user?.email}"),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: ref.read(userProvider.notifier).signOut,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

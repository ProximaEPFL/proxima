import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class CreateAccountPage extends HookConsumerWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create your Proxima account"),
      ),
      body: const Center(child: Text("Create account page")),
    );
  }
}

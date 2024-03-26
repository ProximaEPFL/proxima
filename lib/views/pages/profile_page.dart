import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: UserInfos(theme: theme),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.tertiaryContainer,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CentauriPoints(theme: theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CentauriPoints extends HookConsumerWidget {
  const CentauriPoints({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      width: 380,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          Text("Centauri Points:", style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class UserInfos extends HookConsumerWidget {
  const UserInfos({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage("https://via.placeholder.com/150"),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Profile", style: theme.textTheme.titleMedium),
            Text("User Profile", style: theme.textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}

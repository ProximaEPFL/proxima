import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/profile_view_model.dart";

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserData = ref.watch(profileProvider);

    final theme = Theme.of(context);

    var itemList = <InfoCard>[];

    for (var i = 0; i < 5; i++) {
      itemList.add(
        InfoCard(
          theme: theme,
        ),
      );
    }

    return switch (asyncUserData) {
      AsyncData(:final value) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: UserInfos(theme: theme, userEmail: value.user.email),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    CentauriPoints(theme: theme),
                    const SizedBox(height: 15),
                    LazyCardRow(
                      theme: theme,
                      itemList: itemList,
                      title: "Your badges:",
                    ),
                    const SizedBox(height: 15),
                    LazyCardColumn(
                      theme: theme,
                      itemList: itemList,
                      title: "Your posts:",
                    ),
                    const SizedBox(height: 15),
                    LazyCardColumn(
                      theme: theme,
                      itemList: itemList,
                      title: "Your comments:",
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      AsyncError(:final error) => Text(
          "Error: $error",
        ),
      _ => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}

class LazyCardColumn extends StatelessWidget {
  const LazyCardColumn({
    super.key,
    required this.theme,
    required this.itemList,
    required this.title,
  });

  final ThemeData theme;
  final List<Widget> itemList;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 275,
      width: 380,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.vertical,
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return itemList[index];
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LazyCardRow extends StatelessWidget {
  const LazyCardRow({
    super.key,
    required this.theme,
    required this.itemList,
    required this.title,
  });

  final ThemeData theme;
  final List<Widget> itemList;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 380,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.horizontal,
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return itemList[index];
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CentauriPoints extends StatelessWidget {
  const CentauriPoints({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 380,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: 3),
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 5),
          //TODO: get the centauri points from the viewmodel
          Text("Centauri points:", style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class UserInfos extends StatelessWidget {
  const UserInfos({
    super.key,
    required this.theme,
    required this.userEmail,
  });

  final ThemeData theme;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          //TODO: get the image from the viewmodel
          //backgroundImage: AssetImage("assets/images/user.png" ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //TODO: get the profile info from the viewmodel
              Text(
                userEmail ?? "averylongemailjusttocheckthatitfades",
                style: theme.textTheme.titleSmall,
                overflow: TextOverflow.fade,
              ),
              Text(
                "User Profile",
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

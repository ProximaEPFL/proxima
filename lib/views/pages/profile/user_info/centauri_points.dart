import "package:flutter/material.dart";

/// This widget is used to display the centauri points in the profile page
class CentauriPoints extends StatelessWidget {
  static const centauriPointsKey = Key("centauri points");
  const CentauriPoints({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: centauriPointsKey,
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
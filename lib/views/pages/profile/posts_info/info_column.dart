import "package:flutter/material.dart";

/// This widget defines the style of the columns in the profile page,
/// such as the posts and comments columns
class InfoColumn extends StatelessWidget {
  static const infoColumnKey = Key("info column");
  const InfoColumn({
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
      key: infoColumnKey,
      height: 412,
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
              style: theme.textTheme.titleMedium,
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

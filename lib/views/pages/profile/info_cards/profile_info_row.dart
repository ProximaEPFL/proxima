import "package:flutter/material.dart";

/// This widget defines the style of the rows in the profile page,
/// such as the badges row
class ProfileInfoRow extends StatelessWidget {
  static const infoRowKey = Key("infoRow");

  static const _rowHeight = 100.0;

  const ProfileInfoRow({
    super.key,
    required this.title,
    required this.itemList,
  });

  final String title;
  final List<Widget> itemList;

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        scrollDirection: Axis.horizontal,
        children: itemList,
      ),
    );

    final rowTitle = Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );

    return SizedBox(
      key: infoRowKey,
      height: _rowHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowTitle,
          content,
        ],
      ),
    );
  }
}

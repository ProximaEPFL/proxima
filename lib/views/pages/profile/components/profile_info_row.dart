import "package:flutter/material.dart";

/// This widget defines the style of the rows in the profile page,
/// such as the badges row
class InfoRow extends StatelessWidget {
  static const infoRowKey = Key("infoRow");

  static const _rowHeight = 100.0;
  static const _separator = SizedBox(width: 10);

  const InfoRow({
    super.key,
    required this.title,
    required this.itemList,
  });

  final String title;
  final List<Widget> itemList;

  @override
  Widget build(BuildContext context) {
    const decoration = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    final content = Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        scrollDirection: Axis.horizontal,
        itemCount: itemList.length,
        itemBuilder: (BuildContext context, int index) => itemList[index],
        separatorBuilder: (BuildContext context, int index) => _separator,
      ),
    );

    final rowTitle = Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );

    return Container(
      key: infoRowKey,
      height: _rowHeight,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowTitle,
          const SizedBox(height: 5),
          content,
        ],
      ),
    );
  }
}

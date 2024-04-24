import "package:flutter/material.dart";

/// This widget defines the style of the columns in the profile page,
/// such as the posts and comments columns
class ProfileInfoColumn extends StatelessWidget {
  const ProfileInfoColumn({
    super.key,
    required this.itemList,
    required this.columnKey,
  });

  static const _separator = SizedBox(height: 10);

  final List<Widget> itemList;
  final Key columnKey;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: columnKey,
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.vertical,
      itemCount: itemList.length,
      itemBuilder: (BuildContext context, int index) => itemList[index],
      separatorBuilder: (BuildContext context, int index) => _separator,
    );
  }
}

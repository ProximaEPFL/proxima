import "package:flutter/material.dart";
import "package:proxima/utils/ui/types.dart";

/// This widget defines the style of the columns in the profile page,
/// such as the posts and comments columns
class ProfileInfoColumn extends StatelessWidget {
  static const _separator = SizedBox(height: 10);

  const ProfileInfoColumn({
    super.key,
    required this.itemList,
    this.onRefresh,
  });

  final List<Widget> itemList;
  final FutureVoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.vertical,
      itemCount: itemList.length,
      itemBuilder: (BuildContext context, int index) => itemList[index],
      separatorBuilder: (BuildContext context, int index) => _separator,
    );

    return onRefresh != null
        ? RefreshIndicator(onRefresh: onRefresh!, child: list)
        : list;
  }
}

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
    this.emptyInfoText,
  });

  final List<Widget> itemList;
  final FutureVoidCallback? onRefresh;
  final String? emptyInfoText;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(8);

    final list = ListView.separated(
      padding: padding,
      scrollDirection: Axis.vertical,
      itemCount: itemList.length,
      itemBuilder: (BuildContext context, int index) => itemList[index],
      separatorBuilder: (BuildContext context, int index) => _separator,
    );

    final emptyInfo = ListView(
      padding: padding,
      scrollDirection: Axis.vertical,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(emptyInfoText.toString()),
          ),
        ),
      ],
    );

    final content =
        emptyInfoText != null && itemList.isEmpty ? emptyInfo : list;

    return onRefresh != null
        ? RefreshIndicator(onRefresh: onRefresh!, child: content)
        : content;
  }
}

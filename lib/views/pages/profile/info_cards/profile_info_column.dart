import "package:flutter/material.dart";
import "package:proxima/utils/types.dart";

/// This widget defines the style of the columns in the profile page,
/// such as the posts and comments columns
class ProfileInfoColumn extends StatelessWidget {
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
    // Padding between the tabs and the content
    const padding = EdgeInsets.all(8);

    final list = ListView(
      padding: padding,
      scrollDirection: Axis.vertical,
      children: itemList,
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

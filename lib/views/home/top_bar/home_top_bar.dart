import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/filter_widgets/timeline_filter/timeline_filter_dropdown.dart";

/*
  This widget is the top bar of the home page
  It contains the timeline filters and the user profile picture
*/
class HomeTopBar extends HookConsumerWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimeLineFiltersDropDown(),
          CircleAvatar(
            child: Text("PR"),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

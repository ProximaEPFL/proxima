import "package:flutter/material.dart";
import "package:proxima/utils/ui/types.dart";
import "package:proxima/views/components/loading_icon_button.dart";
import "package:proxima/views/pages/profile/info_cards/profile_info_pop_up.dart";

/// Info card for the profile page (post or comment)
class ProfileInfoCard extends StatelessWidget {
  static const infoCardKey = Key("profileInfoCard");

  static const _borderRadius = BorderRadius.all(Radius.circular(10));
  static const _cardHeight = 80.0;

  const ProfileInfoCard({
    super.key,
    required this.content,
    required this.onDelete,
    this.title,
    this.shadow,
  });

  final String content;
  final FutureVoidCallback onDelete;
  final String? title;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final decoration = BoxDecoration(
      color: themeData.colorScheme.secondaryContainer,
      borderRadius: _borderRadius,
      boxShadow: [if (shadow != null) shadow!],
    );

    final potentialTitle = title != null
        ? Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: themeData.textTheme.titleSmall,
          )
        : null;

    final cardContent = ListTile(
      title: potentialTitle,
      subtitle: Text(
        content,
        style: themeData.textTheme.bodySmall,
        maxLines: title == null ? 3 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: DeleteButton(onClick: onDelete),
    );

    final fullViewButton = InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProfileInfoPopUp(
            title: title,
            content: content,
            onDelete: onDelete,
          );
        },
      ),
      child: Center(
        child: cardContent,
      ),
    );

    return Container(
      key: infoCardKey,
      height: _cardHeight,
      decoration: decoration,
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: _borderRadius,
        color: Colors.transparent,
        child: fullViewButton,
      ),
    );
  }
}

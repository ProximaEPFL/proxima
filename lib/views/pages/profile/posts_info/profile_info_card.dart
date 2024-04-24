import "package:flutter/material.dart";
import "package:proxima/views/pages/profile/posts_info/profile_info_pop_up.dart";

/// Info card for the profile page (post or comment)
class ProfileInfoCard extends StatelessWidget {
  static const infoCardPostKey = Key("profileInfoCard");

  static const _borderRadius = BorderRadius.all(Radius.circular(10));

  const ProfileInfoCard({
    super.key,
    required this.content,
    required this.onDelete,
    this.title,
    this.shadow,
  });

  final String content;
  final VoidCallback onDelete;
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

    final deleteButton = IconButton(
      icon: const Icon(Icons.delete, size: 32),
      onPressed: onDelete,
    );

    final cardContent = ListTile(
      title: potentialTitle,
      subtitle: Text(
        content,
        style: themeData.textTheme.bodySmall,
        maxLines: title == null ? 3 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: deleteButton,
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
      key: infoCardPostKey,
      width: 54,
      height: 80,
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

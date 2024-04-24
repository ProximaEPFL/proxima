import "package:flutter/material.dart";
import "package:proxima/views/pages/profile/posts_info/profile_info_pop_up.dart";

//info card for the comments
class InfoCardComment extends StatelessWidget {
  static const infoCardCommentKey = Key("infoCardComment");

  static const borderRadius = BorderRadius.all(Radius.circular(10));

  const InfoCardComment({
    super.key,
    required this.shadow,
    required this.comment,
  });

  final BoxShadow shadow;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: infoCardCommentKey,
      width: 54,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: borderRadius,
        boxShadow: [shadow],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: borderRadius,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return ProfileInfoPopUp(
                description: comment,
                onDelete: () {
                  // TODO comment deletion
                },
              );
            },
          ),
          child: Center(
            child: ListTile(
              title: Text(
                comment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 32,
                ),
                //TODO: add the delete function
                onPressed: null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

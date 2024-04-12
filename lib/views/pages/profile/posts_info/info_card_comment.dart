import "package:flutter/material.dart";

//info card for the comments
class InfoCardComment extends StatelessWidget {
  static const infoCardCommentKey = Key("infoCardComment");

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
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [shadow],
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
    );
  }
}

import "package:flutter/material.dart";

//info card for the posts
class InfoCardPost extends StatelessWidget {
  static const cardKey = Key("card");

  const InfoCardPost({
    super.key,
    required this.shadow,
  });

  final BoxShadow shadow;
  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      width: 54,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [shadow],
      ),
      child: Center(
        child: ListTile(
          title: //TODO: replace with real data
              Text(
            "Post Title",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            "My super post that talks about something that is super cool and is located in a super spot",
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const IconButton(
            icon: Icon(
              Icons.delete,
              size: 32,
            ),
            // TODO : add the logic for deleting a post
            onPressed: null,
          ),
        ),
      ),
    );
  }
}

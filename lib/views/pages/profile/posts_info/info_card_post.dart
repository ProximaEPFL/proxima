import "package:flutter/material.dart";

//info card for the posts
class InfoCardPost extends StatelessWidget {
  static const cardKey = Key("card");

  const InfoCardPost({
    super.key,
    required this.shadow,
    required this.title,
    required this.description,
  });

  final BoxShadow shadow;
  final String title;
  final String description;

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
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            description,
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

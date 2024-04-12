import "package:flutter/material.dart";

//info card for the posts
class InfoCardPost extends StatelessWidget {
  static const cardKey = Key("card");

  static const borderRadius = BorderRadius.all(Radius.circular(10));

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
        borderRadius: borderRadius,
        boxShadow: [shadow],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: borderRadius,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => {},
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
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 32,
                ),
                // TODO : add the logic for deleting a post
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}

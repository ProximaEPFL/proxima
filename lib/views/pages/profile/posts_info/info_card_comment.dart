import "package:flutter/material.dart";

//info card for the badges
class InfoCardComment extends StatelessWidget {
  static const cardKey = Key("card");

  const InfoCardComment({
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
          //TODO: replace with real data
          title: Text(
            "Here is a super comment on a super post that talks about something that is super cool and is located in a super spot that is very cosy and nice",
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

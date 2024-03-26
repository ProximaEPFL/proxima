import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home/posts/post_card/post_card.dart";

/*
  This widget is the feed of the home page
  It contains the posts
*/
class HomeFeed extends HookConsumerWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: const [
        PostCard(
          title: "First post",
          description:
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut congue gravida justo, ut pharetra tortor sollicitudin sit amet. Etiam eu vulputate sapien, nec dictum neque. Curabitur ullamcorper ipsum quis tellus porttitor suscipit. Aliquam in ipsum eget massa auctor bibendum. Maecenas rutrum sem tortor. Nam rutrum posuere interdum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus elementum augue odio, ac vehicula metus finibus sed. Etiam accumsan pellentesque libero sed gravida. Etiam blandit lacinia quam, vitae tempus purus ultrices id.",
          votes: 100,
          commentNumber: 5,
          posterUsername: "Proxima",
        ),
        PostCard(
          title: "Second post",
          description:
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut congue gravida justo, ut pharetra tortor sollicitudin sit amet. Etiam eu vulputate sapien.",
          votes: 10,
          commentNumber: 5,
          posterUsername: "Proxima",
        ),
        PostCard(
          title: "Third post",
          description: "Crazy post",
          votes: 93213,
          commentNumber: 829,
          posterUsername: "Proxima",
        ),
      ],
    );
  }
}

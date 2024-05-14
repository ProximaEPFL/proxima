import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";
import "package:proxima/views/components/content/post_votes.dart";
import "package:proxima/views/components/content/publication_header.dart";
import "package:proxima/views/components/feedback/centauri_snack_bar.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/content/feed/components/comment_count.dart";

/// This widget is used to display the post card in the home feed.
/// It contains the post title, description, votes, comments
/// and the user (profile picture and username).
/// On click, the corresponding challenge (if it exists), is marked as completed.
class PostCard extends ConsumerWidget {
  static const postCardKey = Key("postCard");
  static const postCardTitleKey = Key("postCardTitle");
  static const postCardDescriptionKey = Key("postCardDescription");
  static const postCardVotesKey = Key("postCardVotes");
  static const postCardCommentsNumberKey = Key("postCardCommentsNumber");
  static const postCardUserKey = Key("postCardUser");

  final PostDetails postDetails;

  const PostCard({
    super.key,
    required this.postDetails,
  });

  void _onPostSelect(
    BuildContext context,
    PostDetails post,
    WidgetRef ref,
  ) async {
    Navigator.pushNamed(context, Routes.post.name, arguments: post);
    final scaffoldMessengerState = ScaffoldMessenger.of(context);

    int? pointsAwarded = await ref
        .read(challengeViewModelProvider.notifier)
        .completeChallenge(post.postId);
    if (pointsAwarded != null) {
      scaffoldMessengerState
          .showSnackBar(CentauriSnackBar(value: pointsAwarded));
      await ref.read(postsFeedViewModelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postBody = ListTile(
      title: Text(
        key: postCardTitleKey,
        postDetails.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        key: postCardDescriptionKey,
        postDetails.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 7,
      ),
    );

    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PostVotes(
            key: postCardVotesKey,
            postId: postDetails.postId,
          ),
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () => _onPostSelect(context, postDetails, ref),
            child: CommentCount(
              key: postCardCommentsNumberKey,
              count: postDetails.commentNumber,
            ),
          ),
        ],
      ),
    );

    late final RoundedRectangleBorder? cardShape;
    if (postDetails.isChallenge) {
      final colorScheme = Theme.of(context).colorScheme;
      cardShape = RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      );
    } else {
      cardShape = null;
    }

    return Card(
      //Note: This card has two onTap actions, one for the card and one for the comment widget.
      key: postCardKey,
      clipBehavior: Clip.hardEdge,
      shape: cardShape,
      child: InkWell(
        onTap: () => _onPostSelect(context, postDetails, ref),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: PublicationHeader(
                key: postCardUserKey,
                posterUsername: postDetails.ownerDisplayName,
                posterUid: postDetails.ownerUid,
                publicationDate: postDetails.publicationDate,
              ),
            ),
            postBody,
            postBottomBar,
          ],
        ),
      ),
    );
  }
}

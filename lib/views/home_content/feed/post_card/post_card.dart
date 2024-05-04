import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/views/home_content/feed/post_card/comment_widget.dart";
import "package:proxima/views/home_content/feed/post_card/post_header_widget.dart";
import "package:proxima/views/home_content/feed/post_card/votes_widget.dart";
import "package:proxima/views/navigation/routes.dart";

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

  final PostOverview postOverview;

  const PostCard({
    super.key,
    required this.postOverview,
  });

  void _onPostSelect(
    BuildContext context,
    PostOverview post,
    WidgetRef ref,
  ) async {
    Navigator.pushNamed(context, Routes.post.name, arguments: post);
    bool challengeCompleted = await ref
        .read(challengeProvider.notifier)
        .completeChallenge(post.postId);
    if (challengeCompleted) {
      // TODO show something to the user, points were awarded
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postBody = ListTile(
      title: Text(
        key: postCardTitleKey,
        postOverview.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        key: postCardDescriptionKey,
        postOverview.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 7,
      ),
    );

    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VotesWidget(
            key: postCardVotesKey,
            postId: postOverview.postId,
          ),
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () => _onPostSelect(context, postOverview, ref),
            child: CommentWidget(
              key: postCardCommentsNumberKey,
              commentNumber: postOverview.commentNumber,
            ),
          ),
        ],
      ),
    );

    late final RoundedRectangleBorder? cardShape;
    if (postOverview.isChallenge) {
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
        onTap: () => _onPostSelect(context, postOverview, ref),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: PostHeaderWidget(
                key: postCardUserKey,
                posterUsername: postOverview.ownerDisplayName,
                publicationDate: postOverview.publicationDate,
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

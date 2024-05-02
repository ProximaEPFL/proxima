import "package:proxima/models/ui/comment_post.dart";

import "datetime.dart";

final List<CommentPost> testComments = [
  CommentPost(
    content:
        "I totally agree! It's the little things in life that make all the difference.",
    ownerDisplayName: "SunnySkyWalker",
    publicationDate: publicationDate1,
  ),
  CommentPost(
    content:
        "Just what I needed to read today. Sometimes, simplicity is key to happiness.",
    ownerDisplayName: "BookishBee",
    publicationDate: publicationDate1,
  ),
  CommentPost(
    content:
        "Love this reminder! I try to start each day with a grateful heart.",
    ownerDisplayName: "MilesOfSmiles",
    publicationDate: publicationDate1,
  ),
  CommentPost(
    content:
        "Couldn't agree more! Walking my dog and enjoying nature always lifts my mood.",
    ownerDisplayName: "SimpleJoys247",
    publicationDate: publicationDate1,
  ),
  CommentPost(
    content:
        "This is so true. Just being outdoors makes me feel at peace and genuinely happy.",
    ownerDisplayName: "HappyHiker42",
    publicationDate: publicationDate1,
  ),
];

final List<CommentPost> unequalComments = [
  CommentPost(
    content: "content1",
    ownerDisplayName: "username1",
    publicationDate: publicationDate1,
  ),
  // Different content
  CommentPost(
    content: "content2",
    ownerDisplayName: "username1",
    publicationDate: publicationDate1,
  ),
  // Different ownerDisplayName
  CommentPost(
    content: "content1",
    ownerDisplayName: "username2",
    publicationDate: publicationDate1,
  ),

  // Different publicationTime
  CommentPost(
    content: "content1",
    ownerDisplayName: "username1",
    publicationDate: publicationDate1.add(const Duration(days: 1)),
  ),
];

import "package:proxima/models/ui/comment_post.dart";

import "timestamp.dart";

final List<CommentPost> testComments = [
  CommentPost(
    content:
        "I totally agree! It's the little things in life that make all the difference.",
    ownerDisplayName: "SunnySkyWalker",
    publicationTime: fakeTimestamp,
  ),
  CommentPost(
    content:
        "Just what I needed to read today. Sometimes, simplicity is key to happiness.",
    ownerDisplayName: "BookishBee",
    publicationTime: fakeTimestamp,
  ),
  CommentPost(
    content:
        "Love this reminder! I try to start each day with a grateful heart.",
    ownerDisplayName: "MilesOfSmiles",
    publicationTime: fakeTimestamp,
  ),
  CommentPost(
    content:
        "Couldn't agree more! Walking my dog and enjoying nature always lifts my mood.",
    ownerDisplayName: "SimpleJoys247",
    publicationTime: fakeTimestamp,
  ),
  CommentPost(
    content:
        "This is so true. Just being outdoors makes me feel at peace and genuinely happy.",
    ownerDisplayName: "HappyHiker42",
    publicationTime: fakeTimestamp,
  ),
];

final List<CommentPost> unequalComments = [
  CommentPost(
    content: "content1",
    ownerDisplayName: "username1",
    publicationTime: fakeTimestamp,
  ),
  // Different content
  CommentPost(
    content: "content2",
    ownerDisplayName: "username1",
    publicationTime: fakeTimestamp,
  ),
  // Different ownerDisplayName
  CommentPost(
    content: "content1",
    ownerDisplayName: "username2",
    publicationTime: fakeTimestamp,
  ),
];

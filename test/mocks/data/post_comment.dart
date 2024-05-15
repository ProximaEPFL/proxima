import "package:proxima/models/ui/comment_details.dart";

import "datetime.dart";

final List<CommentDetails> testComments = [
  CommentDetails(
    content:
        "I totally agree! It's the little things in life that make all the difference.",
    ownerDisplayName: "SunnySkyWalker",
    ownerUsername: "SunnySkyWalkerUsername",
    ownerCentauriPoints: 12,
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "Just what I needed to read today. Sometimes, simplicity is key to happiness.",
    ownerDisplayName: "BookishBee",
    ownerUsername: "BookishBeeUsername",
    ownerCentauriPoints: 123,
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "Love this reminder! I try to start each day with a grateful heart.",
    ownerDisplayName: "MilesOfSmiles",
    ownerUsername: "MilesOfSmilesUsername",
    ownerCentauriPoints: 12333,
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "Couldn't agree more! Walking my dog and enjoying nature always lifts my mood.",
    ownerDisplayName: "SimpleJoys247",
    ownerUsername: "SimpleJoys247Username",
    ownerCentauriPoints: 1729,
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "This is so true. Just being outdoors makes me feel at peace and genuinely happy.",
    ownerDisplayName: "HappyHiker42",
    ownerUsername: "HappyHiker42Username",
    ownerCentauriPoints: 31415,
    publicationDate: publicationDate1,
  ),
];

final List<CommentDetails> unequalComments = [
  CommentDetails(
    content: "content1",
    ownerDisplayName: "username1",
    ownerUsername: "username1username",
    ownerCentauriPoints: 2,
    publicationDate: publicationDate1,
  ),
  // Different content
  CommentDetails(
    content: "content2",
    ownerDisplayName: "username1",
    ownerUsername: "username1username",
    ownerCentauriPoints: 0,
    publicationDate: publicationDate1,
  ),
  // Different ownerDisplayName
  CommentDetails(
    content: "content1",
    ownerDisplayName: "username2",
    ownerUsername: "username2username",
    ownerCentauriPoints: 2,
    publicationDate: publicationDate1,
  ),

  // Different publicationTime
  CommentDetails(
    content: "content1",
    ownerDisplayName: "username1",
    ownerUsername: "username1username",
    ownerCentauriPoints: 2,
    publicationDate: publicationDate1.add(const Duration(days: 1)),
  ),
];

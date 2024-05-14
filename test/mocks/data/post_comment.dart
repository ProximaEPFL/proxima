import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/comment_details.dart";

import "datetime.dart";

final List<CommentDetails> testComments = [
  CommentDetails(
    content:
        "I totally agree! It's the little things in life that make all the difference.",
    ownerDisplayName: "SunnySkyWalker",
    ownerUid: const UserIdFirestore(value: "SunnySkyWalker"),
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "Just what I needed to read today. Sometimes, simplicity is key to happiness.",
    ownerDisplayName: "BookishBee",
    ownerUid: const UserIdFirestore(value: "BookishBee"),
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "Love this reminder! I try to start each day with a grateful heart.",
    ownerDisplayName: "MilesOfSmiles",
    ownerUid: const UserIdFirestore(value: "MilesOfSmiles"),
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "Couldn't agree more! Walking my dog and enjoying nature always lifts my mood.",
    ownerDisplayName: "SimpleJoys247",
    ownerUid: const UserIdFirestore(value: "SimpleJoys247"),
    publicationDate: publicationDate1,
  ),
  CommentDetails(
    content:
        "This is so true. Just being outdoors makes me feel at peace and genuinely happy.",
    ownerDisplayName: "HappyHiker42",
    ownerUid: const UserIdFirestore(value: "HappyHiker42"),
    publicationDate: publicationDate1,
  ),
];

final List<CommentDetails> unequalComments = [
  CommentDetails(
    content: "content1",
    ownerDisplayName: "username1",
    ownerUid: const UserIdFirestore(value: "username1"),
    publicationDate: publicationDate1,
  ),
  // Different content
  CommentDetails(
    content: "content2",
    ownerDisplayName: "username1",
    ownerUid: const UserIdFirestore(value: "username1"),
    publicationDate: publicationDate1,
  ),
  // Different ownerDisplayName
  CommentDetails(
    content: "content1",
    ownerDisplayName: "username2",
    ownerUid: const UserIdFirestore(value: "username2"),
    publicationDate: publicationDate1,
  ),

  // Different publicationTime
  CommentDetails(
    content: "content1",
    ownerDisplayName: "username1",
    ownerUid: const UserIdFirestore(value: "username1"),
    publicationDate: publicationDate1.add(const Duration(days: 1)),
  ),
];

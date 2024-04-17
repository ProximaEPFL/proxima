/// A class representing the internal storage of the subcollection of voters
/// in a post or comment document in Firestore.
class VoteFirestore {
  /// The name of the subcollection where the voters are stored
  static const votersSubCollectionName = "voters";

  /// The field that stores the upvote state of the user
  final bool hasUpvoted;
  static const hasUpvotedField = "hasUpvoted";

  VoteFirestore({
    required this.hasUpvoted,
  });

  /// This method will create an instance of [VoteFirestore] from the
  /// data [data] that comes from firestore
  factory VoteFirestore.fromDbData(Map<String, dynamic> data) {
    return VoteFirestore(
      hasUpvoted: data[hasUpvotedField],
    );
  }

  /// This method will convert the [VoteFirestore] instance to a Map
  /// that can be stored in Firestore
  Map<String, dynamic> toDbData() {
    return {
      hasUpvotedField: hasUpvoted,
    };
  }

  @override
  int get hashCode => hasUpvoted.hashCode;

  @override
  bool operator ==(Object other) =>
      other is VoteFirestore && other.hasUpvoted == hasUpvoted;
}

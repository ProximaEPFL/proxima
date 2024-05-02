import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";

/// This class represents a comment in the firestore database
@immutable
class CommentFirestore {
  // This is thhe subcollection in which the comments are stored whithin
  // a post document
  static const String subCollectionName = "comments";

  // This is the firestore document id of the comment and thus it is
  // not stored in a field
  final CommentIdFirestore id;

  final CommentData data;

  const CommentFirestore({
    required this.id,
    required this.data,
  });

  // This method will create an instance of [CommentFirestore] from the
  // document snapshot [docSnap] that comes from firestore
  factory CommentFirestore.fromDb(DocumentSnapshot docSnap) {
    if (!docSnap.exists) {
      throw Exception("Comment document does not exist");
    }

    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return CommentFirestore(
        id: CommentIdFirestore(value: docSnap.id),
        data: CommentData.fromDbData(data),
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException("Cannot parse comment document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentFirestore && other.id == id && other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, data);
}
